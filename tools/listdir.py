'''
List the directory of a PEDISK disk image
Usage: list_dir.py <image.img>
'''
import os
import sys

import imageutil

def read_image(filename):
    size = os.path.getsize(imagename)
    if size == 256256: # 8"
        img = imageutil.EightInchDiskImage()
    elif size == 146944: # 5.25"
        img = imageutil.FiveInchDiskImage()
    else:
        raise Exception("Unrecognized image: %r" % imagename)
    with open(imagename, 'rb') as f:
        img.data = bytearray(f.read())
    return img

def print_dir(fs, out=sys.stdout):
    out.write("Disk Name = %s\n" % fs.diskname.decode('utf-8'))
    out.write("Next Free TS = %d,%d\n" % fs.next_free_ts)
    out.write("Bytes Free = %d\n" % fs.num_free_bytes)
    out.write("Filename Type Load  Entry Trk,Sec #Secs Size\n")

    for entry in fs.read_dir():
        if not entry.used:
            continue

        typename = imageutil.FileTypes.name_of(entry.filetype)
        if entry.filetype == imageutil.FileTypes.LD:
            entry_addr = "$%04X" % entry.size
            size = str(entry.sector_count * fs.image.SECTOR_SIZE)
        else:
            entry_addr = " ---"
            size = str(entry.size)

        warnings_msg = ''
        if entry.deleted:
            warnings_msg = '<Deleted>'
        expected_size = fs.file_size(entry.filename)
        actual_size = len(fs.read_file(entry.filename))
        if expected_size != actual_size:
            warnings_msg += "<Truncated to %d bytes>" % actual_size

        cols = [
            entry.filename.decode("utf-8", errors='replace').ljust(9),
            typename.ljust(5),
            "$%04X " % entry.load_address,
            entry_addr.ljust(6),
            ("%d,%d" % (entry.track, entry.sector)).ljust(8),
            str(entry.sector_count).ljust(6),
            str(size).ljust(8),
            warnings_msg
            ]
        out.write(u''.join(cols) + "\n")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.stderr.write(__doc__)
        sys.exit(1)
    imagename = sys.argv[1]

    img = read_image(imagename)
    fs = imageutil.Filesystem(img)
    print_dir(fs)
