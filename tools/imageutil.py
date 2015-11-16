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
        self.track = 0
        self.sector = 1
        self.sector_offset = 0
        self.data_offset = 0
        while (self.track != track) or (self.sector != sector):
            self._incr()

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
            self.track += 1
            self.sector = 1
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
        if len(diskname) > 8:
            msg = 'Disk name %r is too long, limit is 8 bytes' % diskname
            raise ValueError(msg)

        # pad diskname with spaces if less than 8 bytes
        while len(diskname) < 8:
            diskname += b'\x20'

        # initialize the entire image to 0xE5
        self.image.home()
        self.image.write(b'\xe5' * self.image.TOTAL_SIZE)

        # write directory header (16 bytes)
        self.image.home()
        self.image.write(diskname) # 8 bytes
        self.image.write(b'\x00') # number of used files (includes deleted)
        self.image.write(b'\x00') # next open track (track 0)
        self.image.write(b'\x09') # next open sector (sector 9)
        self.image.write(b'\x20' * 5) # 5 unused bytes, always 0x20

        # write 63 directory entries (16 bytes each)
        for i in range(63):
            self.image.write(b'\xff' * 16)

    @property
    def next_free_ts(self):
        '''Read the directory header and return the next available track
        and sector where a new file can be stored.  Raises if the directory
        header is invalid.  Returns (track, sector).'''
        self.image.seek(track=0, sector=1)
        self.image.read(8) # skip diskname
        self.image.read(1) # skip number of files

        # check track in range of image
        track = ord(self.image.read(1))
        if track > (self.image.TRACKS - 1):
            msg = ('Directory invalid: next available track %d '
                   'not in range 0-%d' % (track, self.image.TRACKS - 1))
            raise ValueError(msg)

        # check sector in range of image
        sector = ord(self.image.read(1))
        if (sector < 1) or (sector > self.image.SECTORS):
            msg = ('Directory invalid: next available sector %d '
                   'not in range 1-%d' % (sector, self.image.SECTORS))
            raise ValueError(msg)

        # check (track, sector) is not in the directory area
        if (track == 0) and (sector < 9):
            msg = ('Directory invalid: next available track %d, sector %d '
                   'is inside the directory area' % (track, sector))
            raise ValueError(msg)

        return track, sector

    @property
    def num_used_entries(self):
        '''Read the directory header and return the number of file entries
        used (includes deleted).'''
        self.image.seek(track=0, sector=1)
        self.image.read(8) # skip diskname
        entries_used = ord(self.image.read(1))

        if entries_used > 63:
            msg = ('Directory invalid: directory entry count byte of %d '
                   'not in range 0-63' % entries_used)
            raise ValueError(msg)

        return entries_used

    @property
    def num_free_entries(self):
        '''Read the directory header and return the number of directory
        entries available for new files.'''
        return 63 - self.num_used_entries

    @property
    def num_free_sectors(self):
        '''Read the directory header and return the number of sectors
        available for new files'''
        track, sector = self.next_free_ts

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
        available for new files'''
        return self.num_free_sectors * self.image.SECTOR_SIZE

    def write_ld_file(self, filename, load_address, entry_address, data):
        '''Write a new LD file to the disk'''
        if len(filename) < 1 or len(filename) > 6:
            msg = ('Invalid file: filename %r, must be between '
                   '1 and 6 bytes' % filename)
            raise ValueError(msg)

        # pad filename with spaces if less than 6 bytes
        while len(filename) < 6:
            filename += b'\x20'

        # check if load address is sane
        if (load_address < 0) or (load_address > 0xFFFF):
            raise ValueError("Invalid load address")

        # check if file will fit on disk
        if len(data) > self.num_free_bytes:
            msg = ('Disk full: data is %d bytes, free space is only '
                   '%d bytes' % (len(data), self.num_free_bytes))
            raise ValueError(msg)

        # check if file will fit in directory
        if self.num_free_entries == 0:
            raise ValueError('Disk full: no entries left in directory')

        # find location for new file
        track, sector = self.next_free_ts

        # find number of sectors required for file
        sector_count = len(data) / float(self.image.SECTOR_SIZE)
        sector_count = int(math.ceil(sector_count))

        # seek to next available entry in the directory
        used_entries = self.num_used_entries
        self.image.home()
        self.image.read(16) # skip past directory header
        for i in range(used_entries):
            self.image.read(16) # skip past used entry

        # write directory entry:
        # filename
        self.image.write(filename)
        # entry address
        entry_lo = entry_address & 0xFF
        self.image.write(bytearray([entry_lo]))
        entry_hi = entry_address >> 8
        self.image.write(bytearray([entry_hi]))
        # load address
        load_lo = load_address & 0xFF
        self.image.write(bytearray([load_lo]))
        load_hi = load_address >> 8
        self.image.write(bytearray([load_hi]))
        # file type (0x05 = LD)
        self.image.write(b'\x05')
        # unused byte
        self.image.write(b'\x20')
        # track number
        self.image.write(bytearray([track]))
        # sector number
        self.image.write(bytearray([sector]))
        # sector count
        count_lo = sector_count & 0xFF
        self.image.write(bytearray([count_lo]))
        count_hi = sector_count >> 8
        self.image.write(bytearray([count_hi]))

        # pad data with 0xE5 so it completely fills the sectors
        while len(data) < (sector_count * self.image.SECTOR_SIZE):
            data += b'xe5'

        # write file data
        self.image.seek(track, sector)
        self.image.write(data)

        # next free track/sector after the file we just wrote
        track = self.image.track
        sector = self.image.sector

        # update used entry count and next free track/sector
        used_entries += 1
        self.image.home()
        self.image.read(8) # skip disk name
        # used entries
        self.image.write(bytearray([used_entries]))
        # next open track
        self.image.write(bytearray([track]))
        # next open sector
        self.image.write(bytearray([sector]))
