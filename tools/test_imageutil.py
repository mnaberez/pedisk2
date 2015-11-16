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
        img.home()
        img.write(bytearray(b'\x00\x01\x02'))
        self.assertEqual(img.sector_offset, 3)
        img.home()
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
        img.home()
        img.write(bytearray(b'\x00\x01\x02'))
        img.home()
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

    def test_format_raises_for_diskname_too_long(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        try:
            fs.format(diskname='123456789')
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                "Disk name '123456789' is too long, limit is 8 bytes")

    def test_format_pads_diskname_with_spaces(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'12345')

        img.home()
        expected = b'12345\x20\x20\x20'
        self.assertEqual(img.read(8), expected)
        num_files = ord(img.read(1))
        self.assertEqual(num_files, 0)

    def test_format_allows_empty_diskname(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'')
        img.home()
        expected = b'\x20' * 8
        self.assertEqual(img.read(8), expected)
        num_files = ord(img.read(1))
        self.assertEqual(num_files, 0)

    # next_free_ts

    def test_next_free_ts_returns_track_0_sector_9_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        track, sector = fs.next_free_ts
        self.assertEqual(track, 0)
        self.assertEqual(sector, 9)

    def test_next_free_ts_returns_valid_track_and_sector(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.write(b'\x22') # set next open track
        img.write(b'\x10') # set next open sector
        track, sector = fs.next_free_ts
        self.assertEqual(track, 0x22)
        self.assertEqual(sector, 0x10)

    def test_next_free_ts_raises_for_track_too_high(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        invalid_track = img.TRACKS
        img.write(bytearray([invalid_track]))
        try:
            track, _ = fs.next_free_ts
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Directory invalid: next available track '
                '41 not in range 0-40'
                )

    def test_next_free_ts_raises_for_sector_too_low(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.read(1) # skip next open track
        invalid_sector = 0
        img.write(bytearray([invalid_sector]))
        try:
            _, sector = fs.next_free_ts
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Directory invalid: next available sector '
                '0 not in range 1-28'
                )

    def test_next_free_ts_raises_for_sector_too_high(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.read(1) # skip next open track
        invalid_sector = img.SECTORS + 1
        img.write(bytearray([invalid_sector]))
        try:
            _, sector = fs.next_free_ts
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Directory invalid: next available sector '
                '29 not in range 1-28'
                )

    def test_next_free_ts_raises_if_it_points_inside_the_dir_area(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.write(b'\x00') # next open track = 0
        img.write(b'\x08') # next open sector = 8

        img.read(1) # skip next open track
        invalid_sector = img.SECTORS + 1
        img.write(bytearray([invalid_sector]))
        try:
            _, sector = fs.next_free_ts
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Directory invalid: next available track 0, sector 8 '
                'is inside the directory area'
                )

    # num_used_entries

    def test_num_used_entries_returns_0_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        self.assertEqual(fs.num_used_entries, 0)

    def test_num_used_entries_returns_valid_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.write(b'\x2a') # number of files used = 42
        self.assertEqual(fs.num_used_entries, 42)

    def test_num_entries_raises_for_invalid_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.write(b'\x40') # number of files used = 64
        try:
            fs.num_used_entries
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Directory invalid: directory entry count byte '
                'of 64 not in range 0-63'
                )

    # num_free_entries

    def test_num_free_entries_returns_63_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        self.assertEqual(fs.num_free_entries, 63)

    def test_num_free_entries_returns_valid_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.write(b'\x2a') # number of files used = 42
        self.assertEqual(fs.num_free_entries, 21)

    # num_free_sectors

    def test_num_free_sectors_returns_all_but_dir_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')

        total_sectors = img.TOTAL_SIZE // img.SECTOR_SIZE
        dir_sectors = 8
        free_sectors = total_sectors - dir_sectors

        self.assertEqual(fs.num_free_sectors, free_sectors)

    # num_free_bytes

    def test_num_free_bytes_returns_free_sectors_times_sector_size(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')

        total_sectors = img.TOTAL_SIZE // img.SECTOR_SIZE
        dir_sectors = 8
        free_sectors = total_sectors - dir_sectors
        free_bytes = free_sectors * img.SECTOR_SIZE

        self.assertEqual(fs.num_free_bytes, free_bytes)

    # write_ld_file

    # TODO write tests
    def test_write_ld_file(self):
        img = imageutil.EightInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        fs.write_ld_file(b'aaaa', 0xaaaa, b'aaaa')
        fs.write_ld_file(b'bbbb', 0xbbbb, b'bbbb')
        fs.write_ld_file(b'cccc', 0xcccc, b'cccc')
        fs.write_ld_file(b'dddd', 0xdddd, b'dddd')

def test_suite():
    return unittest.findTestCases(sys.modules[__name__])

if __name__ == '__main__':
    unittest.main(defaultTest='test_suite')
