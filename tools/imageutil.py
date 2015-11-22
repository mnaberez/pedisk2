import math

class DiskImage(object):
    '''Low-level manipulation of PEDISK disk image data.  Seek to track/
    sector positions with boundary checks and read/write raw data in the
    image.  This class is abstract.'''
    SECTOR_SIZE = 128
    TRACKS = None  # override in subclass
    SECTORS = None  # override in subclass

    def __init__(self):
        self.TOTAL_SIZE = self.SECTOR_SIZE * self.SECTORS * self.TRACKS
        self.data = bytearray(b'\xE5' * self.TOTAL_SIZE)
        self.home()

    def home(self):
        '''Seek to the first sector of the first track'''
        self.seek(track=0, sector=1)

    def seek(self, track, sector):
        '''Seek to the given track/sector position.  As with the IBM 3740
        numbering, tracks are 0-based, sectors are 1-based.'''
        self._validate_ts(track, sector)
        self.track = track
        self.sector = sector
        self.sector_offset = 0
        self.data_offset = (
            (track * self.SECTORS * self.SECTOR_SIZE) +
            ((sector - 1) * self.SECTOR_SIZE)
            )

    def write(self, data):
        '''Write a bytearray of arbitrary length starting at the current
        position.  The data can span sectors and tracks.  Track/sector is
        advanced past the data written.  Raises an error if the data
        exceeds the end of the image.'''
        wrapped = False
        for d in data:
            if wrapped:
                raise ValueError("Wrote past end of disk")
            self.data[self.data_offset] = d
            wrapped = self._incr()

    def read(self, numbytes):
        '''Read a bytearray of arbitrary length starting at the current
        position.  The data can span sectors and tracks.  Track/sector is
        advanced past the data read.  Raises an error if the data exceeds
        the end of the image.'''
        wrapped = False
        data = bytearray()
        for n in range(numbytes):
            if wrapped:
                raise ValueError("Read past end of disk")
            d = self.data[self.data_offset]
            data.append(d)
            wrapped = self._incr()
        return data

    def peek(self, numbytes):
        '''Read a bytearray of arbitrary length starting at the current
        position as read() does, but leave all pointers unchanged.'''
        start = self.data_offset
        end = start + numbytes
        data = self.data[start:end]
        if len(data) != numbytes:
            raise ValueError("Read past end of disk")
        return data

    def _validate_ts(self, track, sector):
        '''Raise ValueError if track/sector is out of range'''
        if (track < 0) or (track >= self.TRACKS):
            msg = 'Track %r not in range 0-%d' % (track, self.TRACKS-1)
            raise ValueError(msg)
        if (sector < 1) or (sector > self.SECTORS):
            msg = 'Sector %r not in range 1-%d' % (sector, self.SECTORS)
            raise ValueError(msg)

    def _incr(self):
        '''Increment the current track, sector, and image position pointers
        by one byte.  Returns True if wrapped around the disk.'''
        wrapped = False
        self.data_offset += 1
        self.sector_offset += 1
        if self.sector_offset == self.SECTOR_SIZE:
            self.sector_offset = 0
            self.sector += 1
            if self.sector > self.SECTORS:
                self.sector = 1
                self.track += 1
                if self.track == self.TRACKS:
                    wrapped = True
                    self.data_offset = 0
                    self.track = 0
                    self.sector = 1
        return wrapped

class FiveInchDiskImage(DiskImage):
    '''5.25" disk'''
    TRACKS = 41 # tracks numbered 0-40
    SECTORS = 28 # sectors per track numbered 1-28

class EightInchDiskImage(DiskImage):
    '''8" disk'''
    TRACKS = 77 # tracks numbered 0-76
    SECTORS = 26 # sectors per track numbered 1-26

class Filesystem(object):
    '''High-level manipulation of the filesystem on a PEDISK disk image'''

    def __init__(self, image):
        '''image is a DiskImage object'''
        self.image = image

    def format(self, diskname):
        '''Completely erase the disk image and write an empty directory'''
        self._validate_diskname(diskname)

        # initialize the entire image to 0xE5
        self.image.home()
        self.image.write(b'\xe5' * self.image.TOTAL_SIZE)

        # write directory header (16 bytes)
        self.image.home()
        self.image.write(diskname.ljust(8, b'\x20')) # 8 bytes
        self.image.write(b'\x00') # number of used files (includes deleted)
        self.image.write(b'\x00') # next open track (track 0)
        self.image.write(b'\x09') # next open sector (sector 9)
        self.image.write(b'\x20' * 5) # 5 unused bytes, always 0x20

        # write directory entries (63 entries of 16 bytes each)
        self.image.write(b'\xff' * 63 * 16)

    @property
    def next_free_ts(self):
        '''Read the directory header and return the next available track
        and sector where a new file can be stored.  This can be an invalid
        sector if the disk is full.  Returns (track, sector).'''
        self.image.home()
        self.image.read(8) # skip diskname
        self.image.read(1) # skip number of files
        return tuple(self.image.read(2))

    @property
    def num_used_entries(self):
        '''Read the directory header and return the number of file entries
        used (includes deleted).'''
        self.image.home()
        self.image.read(8) # skip diskname
        return self.image.read(1)[0]

    def _seek_to_free_entry(self):
        '''Seek to the next free directory entry.  Raises an
        error if no more entries are available.'''
        self.image.home()
        self.image.read(16) # skip past directory header
        for i in range(63):
            if self.image.peek(1) == b'\xFF': # first byte of filename
                return
            self.image.read(16) # advance to next entry
        raise ValueError('Disk full: no entries left in directory')

    @property
    def num_free_entries(self):
        '''Read the directory header and return the number of directory
        entries available for new files.'''
        return max(0, 63 - self.num_used_entries)

    @property
    def num_free_sectors(self):
        '''Read the directory header and return the number of sectors
        available for new files.  If the next free track/sector in the
        directory header is invalid, 0 is returned.'''
        track, sector = self.next_free_ts

        # pedisk may set track out of range if it fills the entire disk
        if (track >= self.image.TRACKS):
            return 0
        if (sector < 1) or (sector > self.image.SECTORS):
            return 0

        # start with 1 (this is the sector return by next_free_ts)
        free_sectors = 1

        # add all the higher sectors on the same track
        free_sectors += self.image.SECTORS - sector

        # add all the sectors on all the higher tracks
        num_empty_tracks = self.image.TRACKS - track - 1
        free_sectors += num_empty_tracks * self.image.SECTORS

        return free_sectors

    @property
    def num_free_bytes(self):
        '''Read the directory header and return the number of bytes
        available for new files.  If the next free track/sector in the
        directory header is invalid, 0 is returned.'''
        return self.num_free_sectors * self.image.SECTOR_SIZE

    @property
    def diskname(self):
        '''Read the directory header and return the name of the disk'''
        self.image.home()
        return self.image.read(8)

    def rename_disk(self, diskname):
        '''Rename the disk'''
        self._validate_diskname(diskname)
        self.image.home()
        self.image.write(diskname.ljust(8, b'\x20'))

    def _validate_diskname(self, diskname):
        if len(diskname) > 8:
            msg = 'Disk name %r is too long, limit is 8 bytes' % diskname
            raise ValueError(msg)

    def list_dir(self):
        '''Read the directory and return a list of active filenames'''
        return [ e.filename for e in self.read_dir() if e.active ]

    def read_dir(self):
        '''Read the directory and return all entries.  This includes
        deleted and unused entries.'''
        self.image.home()
        self.image.read(16) # skip directory header
        entries = []
        for i in range(63):
            data = self.image.read(16)
            entry = DirectoryEntry.from_bytes(data)
            entries.append(entry)
        return entries

    def read_entry(self, filename):
        '''Read the directory and return the entry for the given filename.
        The entry can be a deleted or unused one.  An exception is raised
        if the file is not found'''
        filename = filename.ljust(6, b'\x20')
        for entry in self.read_dir():
            if entry.filename == filename:
                return entry
        raise ValueError("File %r not found" % filename)

    def file_exists(self, filename):
        '''Read the directory and return True if the given filename
        already exists as an active filename'''
        return filename.ljust(6, b'\x20') in self.list_dir()

    def read_file(self, filename):
        '''Read the contents of the file with the given filename.  An
        exception is raised if the file is not found.'''
        entry = self.read_entry(filename)
        self.image.seek(track=entry.track, sector=entry.sector)
        if entry.filetype == FileTypes.LD:
            size = entry.sector_count * self.image.SECTOR_SIZE
            return self.image.read(size)
        else:
            return self.image.read(entry.size)

    def write_file(self, filename, filetype, data,
                    load_address, entry_address=None):
        if self.file_exists(filename):
            raise ValueError('File %r already exists' % filename)

        if len(data) > self.num_free_bytes:
            msg = ('Disk full: data is %d bytes, free space is only '
                   '%d bytes' % (len(data), self.num_free_bytes))
            raise ValueError(msg)

        # pedisk abuses the size field as the entry address on type LD only
        if filetype == FileTypes.LD:
            if entry_address is None:
                raise ValueError("Entry address is required for type LD")
            size_or_entry = entry_address
        else:
            size_or_entry = len(data)

        # find location for new file
        track, sector = self.next_free_ts

        # find number of sectors required for file
        sector_count = len(data) / float(self.image.SECTOR_SIZE)
        sector_count = int(math.ceil(sector_count))

        # write directory entry
        self._seek_to_free_entry()
        entry = DirectoryEntry(
            filename=filename,
            size=size_or_entry,
            load_address=load_address,
            filetype=filetype,
            track=track,
            sector=sector,
            sector_count=sector_count
            )
        self.image.write(entry.to_bytes())

        # write file padded with 0xE5 so it completely fills the sectors
        data = data.ljust(sector_count * self.image.SECTOR_SIZE, b'\xe5')
        self.image.seek(track, sector)
        self.image.write(data)

        # find the next free track/sector after the file we just wrote
        if self.image.track < track:
            # we wrote the very last sector on disk and the pointer wrapped.
            # there's not another free t/s, so we choose an invalid one
            # (last track + 1), which seems to be what the pedisk does also.
            track, sector = self.image.TRACKS, 1
        else:
            track, sector = self.image.track, self.image.sector

        # update directory header
        used_entries = len(self.list_dir())
        self.image.home()
        self.image.read(8) # skip disk name
        self.image.write(bytearray([used_entries, track, sector]))

def _low_high(num):
    '''Split an unsigned 16-bit number into two 8-bit numbers: (low, high)'''
    if num < 0 or num > 65535:
        raise ValueError('Expected 0-65535, got %r' % num)
    low = num & 0xFF
    high = num >> 8
    return low, high

class FileTypes(object):
    '''File types supported by the PEDISK file system'''
    SEQ = 0x00
    IND = 0x01
    ISM = 0x02
    BAS = 0x03
    ASM = 0x04
    LD  = 0x05
    TXT = 0x06
    OBJ = 0x07

    @classmethod
    def name_of(klass, number):
        '''Get the string name for a file type (e.g. "BAS" for 3)'''
        for k, v in klass.__dict__.items():
            if not k.startswith('_') and v == number:
                return k
        raise IndexError('File type number not found: %r' % number)

class DirectoryEntry(object):
    def __init__(self, filename, filetype, size,
                 load_address, track, sector, sector_count):
        self.filename = filename            # $00-$05: 6 bytes
        self.size = size                    # $06-$07: 2 bytes
        self.load_address = load_address    # $08-$09: 2 bytes
        self.filetype = filetype            # $0A:     1 byte
                                            # $0B:     1 byte (unused)
        self.track = track                  # $0C:     1 byte track
        self.sector = sector                # $0D:     1 byte sector
        self.sector_count = sector_count    # $0E-0F:  2 bytes sector count
                                            #          = 16 bytes total
    @classmethod
    def from_bytes(klass, data):
        return klass(
            filename=data[0:6],
            size=data[6] + (data[7] << 8),
            load_address=data[8] + (data[9] << 8),
            filetype=data[10],
            track=data[12],
            sector=data[13],
            sector_count=data[14] + (data[15] << 8)
            )

    def to_bytes(self):
        self._validate()
        data = bytearray()
        data.extend(self.filename.ljust(6, b'\x20'))
        data.extend(_low_high(self.size))
        data.extend(_low_high(self.load_address))
        data.append(self.filetype)
        data.append(0x20) # unused byte, always 0x20
        data.extend([self.track, self.sector])
        data.extend(_low_high(self.sector_count))
        return data

    @property
    def entry_address(self):
        return self.size  # size is abused for entry_address on type LD only

    @property
    def active(self):
        return self.filename[0] != 0xFF

    def _validate(self):
        if len(self.filename) < 1 or len(self.filename) > 6:
            msg = ('Invalid filename: %r is not between '
                   '1 and 6 bytes' % self.filename)
            raise ValueError(msg)
