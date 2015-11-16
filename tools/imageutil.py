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
    def next_open_ts(self):
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
