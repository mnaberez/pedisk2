import sys
import unittest

import imageutil

class DiskImageTests(unittest.TestCase):

    # __init__

    def test_ctor_sets_pos_at_start_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.data_offset, 0)
        self.assertEqual(img.sector_offset, 0)

    def test_ctor_initalizes_disk_to_0xe5(self):
        img = imageutil.FiveInchDiskImage()
        self.assertEqual(len(img.data), img.TOTAL_SIZE)
        data = bytearray(b'\xe5' * img.TOTAL_SIZE)
        self.assertEqual(img.read(img.TOTAL_SIZE), data)

    # home

    def test_home_seeks_to_first_sector_of_first_track(self):
        img = imageutil.FiveInchDiskImage()
        img.read(5000)
        self.assertNotEqual(img.track, 0)
        self.assertNotEqual(img.sector, 1)
        img.home()
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 0)

    # seek

    def test_seek_raises_for_track_too_low(self):
        img = imageutil.FiveInchDiskImage()
        try:
            img.seek(track=-1, sector=1)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0], 'Track -1 not in range 0-40')

    def test_seek_raises_for_track_too_high(self):
        img = imageutil.FiveInchDiskImage()
        try:
            img.seek(track=41, sector=1)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0], 'Track 41 not in range 0-40')

    def test_seek_raises_for_sector_too_low(self):
        img = imageutil.FiveInchDiskImage()
        try:
            img.seek(track=0, sector=0)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0], 'Sector 0 not in range 1-28')

    def test_seek_raises_for_sector_too_high(self):
        img = imageutil.FiveInchDiskImage()
        try:
            img.seek(track=0, sector=29)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Sector 29 not in range 1-28')

    # write

    def test_write_writes_bytes_and_advances_pointers(self):
        img = imageutil.FiveInchDiskImage()
        img.seek(track=0, sector=1)
        img.write(bytearray(b'\x00\x01\x02'))
        self.assertEqual(img.sector_offset, 3)
        img.seek(track=0, sector=1)
        self.assertEqual(bytearray(b'\x00\x01\x02'), img.read(3))

    def test_write_spans_sectors_and_tracks(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last sector of a track
        img.seek(track=20, sector=28)
        data = bytearray(b'\x42' * (img.SECTOR_SIZE + 1))
        img.write(data)
        # write should have overflowed to first sector of next track
        self.assertEqual(img.track, 21)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 1)
        # seek to first byte of the sector
        img.seek(track=img.track, sector=img.sector)
        self.assertEqual(img.read(1)[0], data[-1])

    def test_write_allows_writing_to_very_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # fill the last sector on disk but don't overflow
        img.seek(track=40, sector=28)
        data = bytearray(b'\x42' * img.SECTOR_SIZE)
        img.write(data)
        # track/sector pointer should wrap around
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 0)
        # verify sector written
        img.seek(track=40, sector=28)
        self.assertEqual(img.read(img.SECTOR_SIZE), data)

    def test_write_raises_if_past_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last sector of a track
        img.seek(track=40, sector=28)
        data = bytearray(b'\x42' * (img.SECTOR_SIZE + 1))
        try:
            img.write(data)
        except ValueError as exc:
            self.assertEqual(exc.args[0], "Wrote past end of disk")

    # read

    def test_read_reads_bytes_and_advances_pointers(self):
        img = imageutil.FiveInchDiskImage()
        img.seek(track=0, sector=1)
        img.write(bytearray(b'\x00\x01\x02'))
        img.seek(track=0, sector=1)
        self.assertEqual(bytearray(b'\x00\x01\x02'), img.read(3))
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 3)

    def test_read_spans_sectors_and_tracks(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last sector of a track
        data = img.read(img.SECTOR_SIZE + 1)
        # read should have overflowed to first sector of next track
        expected = bytearray(b'\xe5' * (img.SECTOR_SIZE + 1))
        self.assertEqual(data, expected)

    def test_read_allows_reading_to_very_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last track/sector
        img.seek(track=40, sector=28)
        img.read(img.SECTOR_SIZE)
        # track/sector pointer should wrap around
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 0)
        # verify sector read
        expected = bytearray(b'\xe5' * img.SECTOR_SIZE)
        self.assertEqual(img.read(img.SECTOR_SIZE), expected)

    def test_read_raises_if_past_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last sector of a track
        img.seek(track=40, sector=28)
        try:
            img.read(img.SECTOR_SIZE + 1)
        except ValueError as exc:
            self.assertEqual(exc.args[0], "Read past end of disk")

class FilesystemTests(unittest.TestCase):

    # format

    def test_format_fills_entire_disk_with_e5(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        # fill disk with some byte that should be overwritten
        img.write(b'\xab' * img.TOTAL_SIZE)
        # seek somewhere to ensure format starts at track 0, sector 1
        img.seek(track=15, sector=1)
        fs.format(b'12345678')

        expected = b'\xe5' * img.SECTOR_SIZE
        # check track 0 after directory area
        img.seek(track=0, sector=9)
        for sector in range(9, img.SECTORS+1):
                data = img.read(img.SECTOR_SIZE)
                self.assertEqual(data, expected)
        # check all tracks after track 0
        img.seek(track=1, sector=1)
        for track in range(1, img.TRACKS):
            for sector in range(img.SECTORS):
                data = img.read(img.SECTOR_SIZE)
                self.assertEqual(data, expected)

    def test_format_writes_directory(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        # fill track 0 with some byte that will be overwritten
        img.write(b'\xab' * (img.SECTOR_SIZE * img.SECTORS))
        # seek somewhere to ensure format starts at track 0, sector 1
        img.seek(track=15, sector=1)
        fs.format(b'12345678')

        # directory header
        img.home()
        diskname = img.read(8)
        self.assertEqual(diskname, b'12345678')
        num_files = ord(img.read(1))
        self.assertEqual(num_files, 0)
        next_open_track = ord(img.read(1))
        self.assertEqual(next_open_track, 0)
        next_open_sector = ord(img.read(1))
        self.assertEqual(next_open_sector, 9)
        unused_area = img.read(5)
        self.assertEqual(unused_area, b'\x20' * 5)

        # directory entries
        for i in range(63):
            self.assertEqual(img.read(16), b'\xff' * 16)

def test_suite():
    return unittest.findTestCases(sys.modules[__name__])

if __name__ == '__main__':
    unittest.main(defaultTest='test_suite')
