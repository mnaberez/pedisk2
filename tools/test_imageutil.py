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

    def test_seek_raises_for_track_out_of_range(self):
        img = imageutil.FiveInchDiskImage()
        for t in (-1, img.TRACKS):
            try:
                img.seek(track=t, sector=1)
                self.fail('nothing raised')
            except ValueError as exc:
                self.assertEqual(exc.args[0],
                    'Invalid track or sector: (%d,%d)' % (t, 1))

    def test_seek_raises_for_sector_out_of_range(self):
        img = imageutil.FiveInchDiskImage()
        for s in (0, img.SECTORS+1):
            try:
                img.seek(track=0, sector=s)
                self.fail('nothing raised')
            except ValueError as exc:
                self.assertEqual(exc.args[0],
                    'Invalid track or sector: (%d,%d)' % (0, s))

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
        track = 20
        img.seek(track=track, sector=img.SECTORS)
        data = bytearray(b'\x42' * (img.SECTOR_SIZE + 1))
        img.write(data)
        # write should have overflowed to first sector of next track
        self.assertEqual(img.track, track + 1)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 1)
        # seek to first byte of the sector
        img.seek(track=img.track, sector=img.sector)
        self.assertEqual(img.read(1)[0], data[-1])

    def test_write_allows_writing_to_very_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # fill the last sector on disk but don't overflow
        img.seek(track=img.TRACKS - 1, sector=img.SECTORS)
        data = bytearray(b'\x42' * img.SECTOR_SIZE)
        img.write(data)
        # track/sector pointer should wrap around
        self.assertEqual(img.track, 0)
        self.assertEqual(img.sector, 1)
        self.assertEqual(img.sector_offset, 0)
        # verify sector written
        img.seek(track=img.TRACKS - 1, sector=img.SECTORS)
        self.assertEqual(img.read(img.SECTOR_SIZE), data)

    def test_write_raises_if_past_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        # seek to the last sector of a track
        img.seek(track=img.TRACKS - 1, sector=img.SECTORS)
        data = bytearray(b'\x42' * (img.SECTOR_SIZE + 1))
        try:
            img.write(data)
            self.fail('nothing raised')
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
        img.seek(track=img.TRACKS - 1, sector=img.SECTORS)
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
        img.seek(track=img.TRACKS - 1, sector=img.SECTORS)
        try:
            img.read(img.SECTOR_SIZE + 1)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0], "Read past end of disk")

    # peek

    def test_peek_reads_bytes_without_changing_pointers(self):
        img = imageutil.FiveInchDiskImage()
        img.home()
        t, s = img.track, img.sector
        so, do = img.sector_offset, img.data_offset
        img.peek(100)
        self.assertEqual(img.track, t)
        self.assertEqual(img.sector, s)
        self.assertEqual(img.sector_offset, so)
        self.assertEqual(img.data_offset, do)

    def test_peek_reads_to_very_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        t, s = img.TRACKS - 1, img.SECTORS
        img.seek(t, s)
        so, do = img.sector_offset, img.data_offset
        img.peek(128)
        self.assertEqual(img.track, t)
        self.assertEqual(img.sector, s)
        self.assertEqual(img.sector_offset, so)
        self.assertEqual(img.data_offset, do)

    def test_peek_raises_if_past_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        t, s = img.TRACKS - 1, img.SECTORS
        img.seek(t, s)
        try:
            img.peek(128 + 1)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0], 'Read past end of disk')

    # count_sectors_from

    def test_count_sectors_from_returns_full_size_of_image(self):
        img = imageutil.FiveInchDiskImage()
        total_sectors = img.TRACKS * img.SECTORS
        self.assertEqual(img.count_sectors_from(0, 1), total_sectors)

    def test_count_sectors_from_returns_1_sector_at_very_end(self):
        img = imageutil.FiveInchDiskImage()
        last_track = img.TRACKS - 1
        last_sector = img.SECTORS
        self.assertEqual(img.count_sectors_from(last_track, last_sector), 1)

    def test_count_sectors_raises_for_invalid_track_or_sector(self):
        img = imageutil.FiveInchDiskImage()
        try:
            track = img.TRACKS + 1
            img.count_sectors_from(track, 1)
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Invalid track or sector: (%d,1)' % track, 1)

    # is_valid_ts

    def test_is_valid_ts_validates_track_in_range(self):
        img = imageutil.FiveInchDiskImage()
        self.assertTrue(img.is_valid_ts(track=0, sector=1))
        self.assertTrue(img.is_valid_ts(track=img.TRACKS - 1, sector=1))
        too_low = -1
        self.assertFalse(img.is_valid_ts(track=too_low, sector=1))
        too_high = img.TRACKS
        self.assertFalse(img.is_valid_ts(track=too_high, sector=1))

    def test_is_valid_ts_validates_sector_in_range(self):
        img = imageutil.FiveInchDiskImage()
        self.assertTrue(img.is_valid_ts(track=0, sector=1))
        self.assertTrue(img.is_valid_ts(track=0, sector=img.SECTORS))
        too_low = 0
        self.assertFalse(img.is_valid_ts(track=0, sector=too_low))
        too_high = img.SECTORS + 1
        self.assertFalse(img.is_valid_ts(track=0, sector=too_high))

    # validate_ts

    def test_validate_ts_does_nothing_for_valid_ts(self):
        img = imageutil.FiveInchDiskImage()
        img.validate_ts(track=0, sector=1)

    def test_validate_ts_raises_for_invalid_ts(self):
        img = imageutil.FiveInchDiskImage()
        try:
            img.validate_ts(track=0, sector=0)
        except ValueError as exc:
            self.assertEqual(exc.args[0], 'Invalid track or sector: (0,0)')

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
        diskname = b'123456789'
        try:
            fs.format(diskname=diskname)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                "Disk name %r is too long, limit is 8 bytes" % diskname)

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
        img.write(b'\x22') # set next free track
        img.write(b'\x10') # set next free sector
        track, sector = fs.next_free_ts
        self.assertEqual(track, 0x22)
        self.assertEqual(sector, 0x10)

    def test_next_free_ts_returns_invalid_track_and_sector(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        # pedisk appears to set track out of range when disk is full
        img.write(b'\xFD') # set next free track to an invalid one
        img.write(b'\xFE') # set next free sector to an invalid one
        track, sector = fs.next_free_ts
        self.assertEqual(track, 0xFD)
        self.assertEqual(sector, 0xFE)

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

    def test_num_used_entries_returns_invalid_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        # pedisk behavior when all entries are used is not known
        img.write(b'\xFD') # set number of files to invalid
        self.assertEqual(fs.num_used_entries, 0xFD)

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

    def test_num_free_entries_returns_0_for_invalid_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.write(b'\x46') # number of files used = 70 (too high)
        self.assertEqual(fs.num_free_entries, 0)

    # next_free_entry_index

    def test_next_free_entry_index_returns_0_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        self.assertEqual(fs.next_free_entry_index, 0)

    def test_next_free_entry_index_raises_if_dir_is_full(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # fill all 63 directory entries
        for i in range(63):
            fs.write_file(
                filename=bytearray([i]),
                filetype=imageutil.FileTypes.ASM,
                data=b'123',
                load_address=0x0401
                )
        # no free entry
        try:
            fs.next_free_entry_index
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Disk full: no entries left in directory')

    def test_next_free_entry_index_ignores_count_in_header(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.write(b'\x10') # number of used files; 0x10 is a lie
        self.assertEqual(fs.next_free_entry_index, 0)

    def test_next_free_entry_returns_first_entry_after_last_used_one(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # write four directory entries
        for i in range(4):
            fs.write_file(
                filename=bytearray([i]),
                filetype=imageutil.FileTypes.ASM,
                data=b'123',
                load_address=0x0401
                )
        # make first and second entries appear unused
        img.home()
        img.read(16) # skip disk name and info
        img.write(b'\xff' * 16)
        img.write(b'\xff' * 16)
        # third and fourth entries are still used
        # free entry should still be the fifth
        self.assertEqual(fs.next_free_entry_index, 4)

    # num_free_sectors

    def test_num_free_sectors_returns_all_but_dir_for_fresh_image(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')

        total_sectors = img.TOTAL_SIZE // img.SECTOR_SIZE
        dir_sectors = 8
        free_sectors = total_sectors - dir_sectors

        self.assertEqual(fs.num_free_sectors, free_sectors)

    def test_num_free_sectors_returns_0_if_free_track_too_high(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.write(bytearray([img.TRACKS])) # free track = last + 1
        self.assertEqual(fs.num_free_sectors, 0)

    def test_num_free_sectors_returns_0_if_free_sector_too_low(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.write(b'\x02') # free track = track 2
        img.write(b'\x00') # free sector = 0 (invalid, sectors start at 1)
        self.assertEqual(fs.num_free_sectors, 0)

    def test_num_free_sectors_returns_0_if_free_sector_too_high(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(8) # skip diskname
        img.read(1) # skip number of files
        img.write(b'\x02') # free track = track 2
        img.write(bytearray([img.SECTORS + 1])) # free sector = last + 1
        self.assertEqual(fs.num_free_sectors, 0)

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

    # diskname

    def test_diskname_returns_disk_name(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'abcdefgh')
        self.assertEqual(fs.diskname, b'abcdefgh')

    # rename_disk

    def test_rename_disk_renames_disk(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'12345678')
        fs.rename_disk(b'abcdefgh')
        img.home()
        self.assertEqual(img.read(8), b'abcdefgh')

    def test_rename_disk_pads_diskname_with_spaces(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'12345678')
        fs.rename_disk(b'abcd')
        img.home()
        self.assertEqual(img.read(8), b'abcd\x20\x20\x20\x20')

    def test_rename_disks_raises_for_diskname_too_long(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'abc')
        diskname = b'123456789'
        try:
            fs.rename_disk(diskname)
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                "Disk name %r is too long, limit is 8 bytes" % diskname)

    # list_dir

    def test_list_dir_returns_empty_for_fresh_disk(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        self.assertEqual(fs.list_dir(), [])

    def test_list_dir_returns_only_active_filenames(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(16) # skip directory header
        img.write(b'aaaaaa'.ljust(16, b'\x00'))    # "aaaaaa"
        img.write(b'bbbbb\xff'.ljust(16, b'\x00')) # deleted
        img.write(b'cccccc'.ljust(16, b'\x00'))    # "cccccc"
        self.assertEqual(fs.list_dir(),
            [bytearray(b'aaaaaa'), bytearray(b'cccccc')])

    # read_dir

    def test_read_dir_returns_all_dir_entries(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(16) # skip directory header
        img.write(b'aaaaaa'.ljust(16, b'\x00'))
        entries = fs.read_dir()
        self.assertEqual(len(entries), 63)
        self.assertEqual(entries[0].filename, b'aaaaaa')
        for i in range(1, 63):
            self.assertEqual(entries[i].filename, b'\xff' * 6)

    # read_entry

    def test_read_entry_raises_for_file_not_found(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        try:
            fs.read_entry(b'notfound')
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                "File %r not found" % b'notfound')

    def test_read_entry_returns_entry_for_filename(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(16) # skip directory header
        img.write(b'aaaaaa'.ljust(16, b'\x00'))    # "aaaaaa"
        img.write(b'\xffbbbbb'.ljust(16, b'\x00')) # deleted
        img.write(b'cccccc'.ljust(16, b'\x00'))    # "cccccc"
        entry = fs.read_entry(b'cccccc')
        self.assertEqual(entry.filename, b'cccccc')

    def test_read_entry_pads_filename_with_spaces_if_needed(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        img.home()
        img.read(16) # skip directory header
        img.write(b'a\x20\x20\x20\x20\x20'.ljust(16, b'\x00')) # "a"
        entry = fs.read_entry(b'a')
        self.assertEqual(entry.filename, b'a\x20\x20\x20\x20\x20')

    # expected_data_size

    def test_expected_data_size_returns_full_sectors_for_LD_and_SEQ(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        for ftype in (imageutil.FileTypes.LD, imageutil.FileTypes.SEQ):
            entry = imageutil.DirectoryEntry(
                        filename=b'strtrk',
                        load_address=0x0080,
                        filetype=ftype,
                        track=0,
                        sector=9,
                        size=0x0080,
                        sector_count=3
                        )
            size = 3 * img.SECTOR_SIZE
            self.assertEqual(fs.expected_data_size(entry), size)

    def test_expected_data_size_returns_size_field_for_BAS(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        entry = imageutil.DirectoryEntry(
                    filename=b'strtrk',
                    load_address=0x0401,
                    filetype=imageutil.FileTypes.BAS,
                    track=0,
                    sector=9,
                    size=42,
                    sector_count=100
                    )
        self.assertEqual(fs.expected_data_size(entry), 42)

    def test_expected_data_size_does_not_return_more_than_sector_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        entry = imageutil.DirectoryEntry(
                    filename=b'strtrk',
                    load_address=0x0401,
                    filetype=imageutil.FileTypes.BAS,
                    track=0,
                    sector=9,
                    size=img.SECTOR_SIZE+1,
                    sector_count=1
                    )
        self.assertEqual(fs.expected_data_size(entry), img.SECTOR_SIZE)

    def test_expected_data_size_returns_full_sectors_for_size_0xFFFF(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        entry = imageutil.DirectoryEntry(
                    filename=b'strtrk',
                    load_address=0x0401,
                    filetype=imageutil.FileTypes.ASM,
                    track=0,
                    sector=9,
                    size=0xFFFF,
                    sector_count=1000
                    )
        size = 1000 * img.SECTOR_SIZE
        self.assertTrue(size > 0xFFFF)
        self.assertEqual(fs.expected_data_size(entry), size)

    # read_data

    def test_read_data_reads_exact_size_for_not_LD_not_SEQ(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # write directory entry
        img.home()
        img.read(16) # skip directory header
        img.write(b'hello '    + # filename
                  b'\x42\x01'  + # file size = 322 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 0 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x02\x03'  + # track 2, sector 3
                  b'\x03\x00')   # 3 sectors on disk
        # write contents
        img.seek(track=2, sector=3)
        contents = b'Contents of the file'.ljust(322, b'.')
        img.write(contents)
        # should read only 322 bytes
        entry = fs.read_entry(b'hello')
        self.assertEqual(fs.read_data(entry), contents)

    def test_read_data_reads_sector_count_for_types_LD_and_SEQ(self):
        for ftype in (imageutil.FileTypes.LD, imageutil.FileTypes.SEQ):
            img = imageutil.FiveInchDiskImage()
            fs = imageutil.Filesystem(img)
            fs.format(diskname=b'fresh')
            # write directory entry
            img.home()
            img.read(16) # skip directory header
            img.write(b'strtrk')          # filename
            img.write(b'\x42\x01')        # file size = 322 bytes
            img.write(b'\x00\x00')        # load address
            img.write(bytearray([ftype])) # file type
            img.write(b'\x00')            # unknown byte
            img.write(b'\x02\x03')        # track 2, sector 3
            img.write(b'\x03\x00')        # 3 sectors on disk
            # write contents
            img.seek(track=2, sector=3)
            contents = b'Contents of the file'.ljust(322, b'.')
            img.write(contents)
            # should read the full 3 sectors
            entry = fs.read_entry(b'strtrk')
            expected = contents.ljust(3 * 128, b'\xe5')
            self.assertEqual(fs.read_data(entry), expected)

    def test_read_data_allows_reading_the_largest_possible_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # write the largest possible file
        max_sectors = fs.num_free_sectors
        data = b'a' * (max_sectors * img.SECTOR_SIZE)
        fs.write_file(b'biggie', imageutil.FileTypes.SEQ,
            load_address=0x0080, data=data)
        # read it back
        entry = fs.read_entry(b'biggie')
        self.assertEqual(fs.read_data(entry), data)

    def test_read_data_returns_empty_for_zero_length_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # write directory entry
        img.home()
        img.read(16) # skip directory header
        img.write(b'strtrk'    + # filename
                  b'\x00\x00'  + # file size = 0 bytes
                  b'\x00\x00'  + # load address
                  b'\x05'      + # file type = 5 (LD)
                  b'\x00'      + # unknown byte
                  b'\x02\x03'  + # track 2, sector 3
                  b'\x00\x00')   # 0 sectors on disk
        entry = fs.read_entry(b'strtrk')
        self.assertEqual(fs.read_data(entry), b'')

    def test_read_data_returns_empty_for_invalid_track_sector(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # write directory entry
        img.home()
        img.read(16) # skip directory header
        img.write(b'strtrk'    + # filename
                  b'\x05\x00'  + # file size = 5 bytes
                  b'\x00\x00'  + # load address
                  b'\x05'      + # file type = 5 (LD)
                  b'\x00'      + # unknown byte
                  b'\xFF\x03'  + # track 255, sector 3
                  b'\x01\x00')   # 1 sector on disk
        entry = fs.read_entry(b'strtrk')
        self.assertEqual(fs.read_data(entry), b'')

    def test_read_data_does_not_read_more_than_sector_count(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        img.home()
        img.read(16) # skip directory header
        # write directory entry
        img.write(b'strtrk')   # filename
        # file size is larger than 1 sector
        size = img.SECTOR_SIZE + 1
        size_lo, size_hi = (size & 0xFF), (size >> 8)
        img.write(bytearray([size_lo, size_hi])) # file size
        img.write(b'\x01\x04') # load address
        img.write(b'\x03')     # file type = 3 (BAS)
        img.write(b'\x00')     # unknown byte
        img.write(b'\x00\x09') # track 0, sector 9
        # sector count is 1 sector
        img.write(b'\x01\x00') # 1 sector on disk
        # read_data() should not return more than 1 sector
        entry = fs.read_entry(b'strtrk')
        self.assertEqual(len(fs.read_data(entry)), img.SECTOR_SIZE)

    # read_file

    def test_read_file_raises_for_file_not_found(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        try:
            fs.read_file(b'notfnd')
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                "File %r not found" % b'notfnd')

    def test_read_file_returns_data_from_read_data(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'fresh')
        # write directory entry
        img.home()
        img.read(16) # skip directory header
        img.write(b'hello '    + # filename
                  b'\x42\x01'  + # file size = 322 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x02\x03'  + # track 2, sector 3
                  b'\x03\x00')   # 3 sectors on disk
        # write contents
        img.seek(track=2, sector=3)
        contents = b'Contents of the file'.ljust(322, b'.')
        img.write(contents)
        # should read the contents
        self.assertEqual(fs.read_file(b'hello'), contents)

    # file_exists

    def test_file_exists_returns_False_if_name_not_in_dir(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        self.assertFalse(fs.file_exists(b'strtrk'))

    def test_file_exists_returns_True_if_name_in_dir(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        img.home()
        img.read(16) # skip directory header
        img.write(b'strtrk'.ljust(16, b'\x00'))
        self.assertTrue(fs.file_exists(b'strtrk'))

    def test_file_exists_pads_filename_with_spaces(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        img.home()
        img.read(16) # skip directory header
        img.write(b'hi'.ljust(6, b'\x20').ljust(16, b'\x00'))
        self.assertTrue(fs.file_exists(b'hi'))

    # write_file

    def test_write_file_raises_if_file_already_exists(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        filename = b'strtrk'
        fs.write_file(filename, imageutil.FileTypes.SEQ,
            load_address=0, data=b'12345')
        try:
            fs.write_file(filename, imageutil.FileTypes.SEQ,
                load_address=0, data=b'12345')
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'File %r already exists' % filename)

    def test_write_file_raises_if_no_entry_free(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        img.home()
        img.read(16) # skip directory header
        used_entry = b'\x20' * 16
        full_directory = used_entry * 63
        img.write(full_directory)
        try:
            fs.write_file(b'foo', imageutil.FileTypes.SEQ,
                load_address=0, data=b'12345')
            self.fail('nothing raised')
        except ValueError as exc:
            self.assertEqual(exc.args[0],
                'Disk full: no entries left in directory')

    def test_write_file_uses_first_unused_dir_entry(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # use the first two directory entries
        img.home()
        img.read(16) # skip directory header
        used_entry = b'\x20' * 16
        img.write(used_entry * 2)
        # write the new file
        fs.write_file(b'newnew', imageutil.FileTypes.SEQ,
            load_address=0, data=b'12345')
        # the new file should be in the third entry
        img.home()
        img.read(16 + 16 + 16) # skip header + 2 used entries
        self.assertEqual(b'newnew', img.read(6))

    def test_write_file_does_not_use_entry_of_deleted_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # use the first directory entry for a deleted file
        img.home()
        img.read(16) # skip directory header
        entry = (b'strtr\xff' + # filename (\xff means deleted)
                 b'\x42\x01'  + # file size = 322 bytes
                 b'\x00\x00'  + # load address
                 b'\x00'      + # file type = 0 (SEQ)
                 b'\x00'      + # unknown byte
                 b'\x02\x03'  + # track 2, sector 3
                 b'\x03\x00')   # 3 sectors on disk
        img.write(entry)
        # write the new file
        fs.write_file(b'newnew', imageutil.FileTypes.SEQ,
            load_address=0, data=b'12345')
        # new file should be in the second entry
        img.home()
        img.read(16 + 16) # skip header + first entry
        self.assertEqual(b'newnew', img.read(6))

    def test_write_file_rewrites_count_of_used_entries(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # write a nonsensical used entry count in the header
        img.home()
        img.read(8) # skip disk name in header
        img.write(b'\x33')
        self.assertEqual(fs.num_used_entries, 0x33)
        # use the first directory entry for a deleted file
        img.home()
        img.read(16) # skip directory header
        entry = (b'strtr\xff' + # filename (\xff means deleted)
                 b'\x42\x01'  + # file size = 322 bytes
                 b'\x00\x00'  + # load address
                 b'\x00'      + # file type = 0 (SEQ)
                 b'\x00'      + # unknown byte
                 b'\x02\x03'  + # track 2, sector 3
                 b'\x03\x00')   # 3 sectors on disk
        img.write(entry)
        # write two files
        fs.write_file(b'foo', imageutil.FileTypes.SEQ,
            load_address=0, data=b'12345')
        fs.write_file(b'bar', imageutil.FileTypes.SEQ,
            load_address=0, data=b'12345')
        # used file entry should be three
        self.assertEqual(fs.num_used_entries, 3)

    def test_write_file_sets_size_from_length_of_data_for_not_type_LD(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # write SEQ file with data 40,000 bytes long
        fs.write_file(b'lotofa', imageutil.FileTypes.SEQ,
            load_address=0, data=b'a' * 0x9c40)
        # check directory entry
        img.home()
        img.read(16) # skip directory header
        entry = img.read(16)
        # size = 40,000 (0x9c40)
        self.assertEqual(entry[6:8], bytearray([0x40, 0x9c]))
        # sector count = 313 (0x0139)
        self.assertEqual(entry[14:16], bytearray([0x39, 0x01]))

    def test_write_file_sets_size_to_entry_address_for_type_LD_only(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # write SEQ file with data 40,000 bytes long
        fs.write_file(b'lotofa', imageutil.FileTypes.LD,
            load_address=0x0401, entry_address=0x0415, data=b'a' * 0x9c40)
        # check directory entry
        img.home()
        img.read(16) # skip directory header
        entry = img.read(16)
        # size field is abused as entry address; entry address = 0x415
        self.assertEqual(entry[6:8], bytearray([0x15, 0x04]))
        # sector count = 313 (0x0139)
        self.assertEqual(entry[14:16], bytearray([0x39, 0x01]))

    def test_write_file_writes_to_very_end_of_disk(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        img.home()
        img.read(8) # skip disk name
        img.read(1) # skip number of used files
        last_ts = (img.TRACKS - 1, img.SECTORS)
        img.write(bytearray(last_ts)) # next free t/s = the last t/s
        self.assertEqual(fs.num_free_bytes, img.SECTOR_SIZE)
        data = b'a'*img.SECTOR_SIZE
        fs.write_file(b'ending', imageutil.FileTypes.SEQ,
            load_address=0x0080, data=data)
        self.assertEqual(img.data[-len(data):], data)
        # no more free sectors so next free t/s is an invalid track
        last_track_plus_one = img.TRACKS
        self.assertEqual(fs.next_free_ts, (last_track_plus_one, 1,))

    def test_write_file_allows_writing_the_largest_possible_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        # write the largest possible file
        max_sectors = fs.num_free_sectors
        data = b'a' * (max_sectors * img.SECTOR_SIZE)
        fs.write_file(b'biggie', imageutil.FileTypes.SEQ,
            load_address=0x0080, data=data)
        self.assertEqual(img.data[-len(data):], data)
        # check directory entry
        entry = fs.read_entry(b'biggie')
        self.assertEqual(entry.sector_count, max_sectors)
        # the actual size of the data is larger than the size field,
        # so the size field is capped at its max value.
        self.assertEqual(entry.size, 0xFFFF)
        # no more free sectors so next free t/s is an invalid track
        last_track_plus_one = img.TRACKS
        self.assertEqual(fs.next_free_ts, (last_track_plus_one, 1,))

    def test_write_file_allows_writing_an_empty_non_LD_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        for name in (b'a', b'c'):
            fs.write_file(name, imageutil.FileTypes.SEQ,
                load_address=0x0080, data=b'')
            entry = fs.read_entry(name)
            self.assertEqual(entry.size, 0)
            self.assertEqual(entry.sector_count, 0)
            self.assertEqual(entry.track, 0)
            self.assertEqual(entry.sector, 9)
            self.assertEqual(fs.next_free_ts, (0, 9))

    def test_write_file_allows_writing_an_empty_LD_file(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'foo')
        for name in (b'a', b'c'):
            fs.write_file(name, imageutil.FileTypes.LD,
                load_address=0x0080, entry_address=0xc000, data=b'')
            entry = fs.read_entry(name)
            self.assertEqual(entry.size, 0xc000) # entry address
            self.assertEqual(entry.sector_count, 0)
            self.assertEqual(entry.track, 0)
            self.assertEqual(entry.sector, 9)
            self.assertEqual(fs.next_free_ts, (0, 9))

    # compact

    def test_compact_preserves_diskname(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'abcdefgh')
        fs.compact()
        self.assertEqual(fs.diskname, b'abcdefgh')

    def test_compact_preserves_unknown_bytes_in_dir_header(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        img.home()
        img.read(8 + 1 + 2) # skip diskname, num files, free track, sector
        img.write(b'vwxyz')
        fs.compact()
        img.home()
        img.read(8 + 1 + 2)
        self.assertEqual(img.read(5), b'vwxyz')

    def tset_compact_preserves_unknown_byte_in_entry(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        # write directory
        img.home()
        img.read(8) # skip disk name
        img.write(b'\x02') # number of used entries = 2
        img.write(b'\x00') # next free track = 0
        img.write(b'\x0b') # next free sector = 11
        img.read(5) # skip 5 unknown bytes
        # write entry
        img.write(b'readme' + # filename (0xFF means deleted)
                  b'\x05\x00'  + # file size = 5 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x42'      + # unknown byte = 0x42
                  b'\x01\x03'  + # track 1, sector 3
                  b'\x01\x00')   # 1 sector on disk
        # write file
        img.seek(track=1, sector=3)
        img.write(b'Hello')
        # should preserve the unknown byte
        fs.compact()
        self.assertEqual(fs.num_used_entries, 1)
        entry = fs.read_entry(b'readme')
        self.assertEqual(entry.unknown, 0x42)
        self.assertEqual(entry.track, 0)
        self.assertEqual(entry.sector, 9)
        self.assertEqual(fs.read_data(entry), b'Hello')

    def test_compact_clears_unused_sectors_to_0xE5(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        # fill unused sectors with junk
        track, sector = fs.next_free_ts
        size = img.count_sectors_from(track, sector) * img.SECTOR_SIZE
        img.seek(track, sector)
        img.write(b'a' * size)
        # compact() should fill unused sectors with 0xE5
        fs.compact()
        img.seek(track, sector)
        self.assertEqual(img.read(size), b'\xe5' * size)

    def test_compact_removes_deleted_files(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        # write directory
        img.home()
        img.read(8) # skip disk name
        img.write(b'\x02') # number of used entries = 2
        img.write(b'\x00') # next free track = 0
        img.write(b'\x0b') # next free sector = 11
        img.read(5) # skip 5 unknown bytes
        # write entry for a deleted file
        img.write(b'readm\xff' + # filename (0xFF means deleted)
                  b'\x07\x00'  + # file size = 7 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x09'  + # track 0, sector 9
                  b'\x01\x00')   # 1 sector on disk
        # write entry for another file
        img.write(b'readme'    + # filename
                  b'\x0b\x00'  + # file size = 11 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x0a'  + # track 0, sector 10
                  b'\x01\x00')   # 1 sector on disk
        # write first file contents
        img.seek(track=0, sector=9)
        img.write(b'Deleted')
        # write second file contents
        img.seek(track=0, sector=10)
        img.write(b'Not Deleted')
        # should keep the non-deleted file only
        fs.compact()
        self.assertEqual(fs.num_used_entries, 1)
        self.assertEqual(fs.next_free_ts, (0,10))
        entry = fs.read_entry(b'readme')
        self.assertEqual(entry.track, 0)
        self.assertEqual(entry.sector, 9)
        self.assertEqual(fs.read_data(entry), b'Not Deleted')

    def test_compact_removes_duplicate_filenames(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        # write directory
        img.home()
        img.read(8) # skip disk name
        img.write(b'\x02') # number of used entries = 2
        img.write(b'\x00') # next free track = 0
        img.write(b'\x0b') # next free sector = 11
        img.read(5) # skip 5 unknown bytes
        # write entry for a deleted file
        img.write(b'readme'    + # filename
                  b'\x05\x00'  + # file size = 5 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x09'  + # track 0, sector 9
                  b'\x01\x00')   # 1 sector on disk
        # write entry for another file
        img.write(b'readme'    + # filename
                  b'\x06\x00'  + # file size = 6 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x0a'  + # track 0, sector 10
                  b'\x01\x00')   # 1 sector on disk
        # write first file data
        img.seek(track=0, sector=9)
        img.write(b'First')
        # write second file data
        img.seek(track=0, sector=10)
        img.write(b'Second')
        # should keep only the second file
        fs.compact()
        self.assertEqual(fs.num_used_entries, 1)
        entry = fs.read_entry(b'readme')
        self.assertEqual(entry.track, 0)
        self.assertEqual(entry.sector, 9)
        self.assertEqual(b'Second', fs.read_data(entry))

    def test_compact_removes_inconsistent_files(self):
        img = imageutil.FiveInchDiskImage()
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'diskname')
        # write directory
        img.home()
        img.read(8) # skip disk name
        img.write(b'\x03') # number of used entries = 2
        img.write(bytearray([img.TRACKS])) # next free track = invalid
        img.write(b'\x00') # next free sector = 1
        img.read(5) # skip 5 unknown bytes
        # write entry for a consistent file
        img.write(b'cnsist'    + # filename
                  b'\x0a\x00'  + # file size = 10 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x09'  + # track 0, sector 9
                  b'\x01\x00')   # 1 sector on disk
        # write entry for an inconsistent file (no data sectors)
        img.write(b'nosecs'    + # filename
                  b'\x05\x00'  + # file size = 5 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x0a'  + # track 0, sector 10
                  b'\x00\x00')   # 0 sectors on disk
        # write entry for an inconsistent file (file size zero)
        img.write(b'zerosz'    + # filename
                  b'\x00\x00'  + # file size = 0 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x0a'  + # track 0, sector 10
                  b'\x01\x00')   # 1 sector on disk
        # write entry for an inconsistent file (too many data sectors)
        img.write(b'biggie'    + # filename
                  b'\xff\xff'  + # file size = 65535 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\x00\x0b'  + # track 0, sector 11
                  b'\xff\xff')   # 65535 sectors on disk
        # write entry for an inconsistent file (t/s invalid)
        img.write(b'offdsk'    + # filename
                  b'\x05\x00'  + # file size = 5 bytes
                  b'\x00\x00'  + # load address
                  b'\x03'      + # file type = 3 (BAS)
                  b'\x00'      + # unknown byte
                  b'\xfe\x01'  + # track 254, sector 1
                  b'\x01\x00')   # 1 sector on disk
        # write the consistent file's contents
        img.seek(track=0, sector=9)
        img.write(b'Consistent')
        # should keep the consistent file only
        fs.compact()
        self.assertEqual(fs.num_used_entries, 1)
        self.assertEqual(fs.next_free_ts, (0,10))
        entry = fs.read_entry(b'cnsist')
        self.assertEqual(entry.track, 0)
        self.assertEqual(entry.sector, 9)
        self.assertEqual(fs.read_data(entry), b'Consistent')

class _low_highTests(unittest.TestCase):
    def test_raises_for_num_out_of_range(self):
        for num in (-1, 65536):
            try:
                imageutil._low_high(num)
                self.fail('nothing raised')
            except ValueError as exc:
                self.assertEqual(exc.args[0],
                    'Expected 0-65535, got %r' % num)

    def test_splits_16bit_into_two_8bit(self):
        num = 0xABCD
        lo, hi = imageutil._low_high(num)
        self.assertEqual(lo, 0xCD)
        self.assertEqual(hi, 0xAB)

class FileTypesTest(unittest.TestCase):
    def test_returns_number_by_name(self):
        self.assertEqual(imageutil.FileTypes.LD, 5)

    def test_name_of_returns_name_of_number(self):
        self.assertEqual(imageutil.FileTypes.name_of(5), "LD")

def test_suite():
    return unittest.findTestCases(sys.modules[__name__])

if __name__ == '__main__':
    unittest.main(defaultTest='test_suite')
