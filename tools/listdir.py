'''
List the directory of a PEDISK disk image
Usage: list_dir.py <image.img>
'''
import sys

import imageutil

def print_dir(fs, out=sys.stdout):
    out.write("Disk Name = %s\n" % fs.diskname.decode('utf-8', errors='ignore'))
    out.write("Next Free TS = %d,%d\n" % fs.next_free_ts)
    out.write("Bytes Free = %d\n" % fs.num_free_bytes)
    out.write("Filename Type Load  Entry Trk,Sec #Secs Size\n")

    for entry in [ e for e in fs.read_dir() if e.used ]:
        typename = imageutil.FileTypes.name_of(entry.filetype)
        if entry.filetype in (imageutil.FileTypes.ASM, imageutil.FileTypes.BAS):
            entry_addr = " ---"
        else:
            entry_addr = "$%04X" % entry.size

        warnings_msg = ''
        if entry.deleted:
            warnings_msg = '<Deleted>'
        expected_size = fs.expected_data_size(entry)
        actual_size = len(fs.read_data(entry))
        if expected_size != actual_size:
            warnings_msg += "<Truncated to %d bytes>" % actual_size

        cols = [
            entry.filename.decode("utf-8", errors='ignore').ljust(9),
            typename.ljust(5),
            "$%04X " % entry.load_address,
            entry_addr.ljust(6),
            ("%d,%d" % (entry.track, entry.sector)).ljust(8),
            str(entry.sector_count).ljust(6),
            str(expected_size).ljust(8),
            warnings_msg
            ]
        out.write(u''.join(cols) + "\n")

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 2:
            sys.stderr.write(__doc__)
            sys.exit(1)
        imagename = sys.argv[1]

        img = imageutil.DiskImage.read_file(imagename)
        fs = imageutil.Filesystem(img)
        print_dir(fs)
    main()
