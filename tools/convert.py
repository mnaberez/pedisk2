'''
Convert a PEDISK image from one size to another.
Usage: convert.py <source.img> <5|8> <dest.img>
'''
import os
import sys

import imageutil

def read_image(filename):
    size = os.path.getsize(filename)
    if size == 256256: # 8"
        img = imageutil.EightInchDiskImage()
    elif size == 146944: # 5.25"
        img = imageutil.FiveInchDiskImage()
    else:
        raise Exception("Unrecognized image: %r" % filename)
    with open(filename, 'rb') as f:
        img.data = bytearray(f.read())
    return img

def make_image(physical_size):
    if str(physical_size)[0] == '8': # 8"
        img = imageutil.EightInchDiskImage()
    elif str(physical_size)[0] == '5': # 5.25"
        img = imageutil.FiveInchDiskImage()
    else:
        raise Exception("Bad disk type: %r" % physical_size)
    return img

def copy_files(source_fs, destination_fs):
    for entry in [ e for e in source_fs.read_dir() if e.used ]:
        data = source_fs.read_file(entry.filename)
        destination_fs.write_file(
            filename=entry.filename,
            filetype=entry.filetype,
            load_address=entry.load_address,
            entry_address=entry.entry_address,
            data=data
            )

if __name__ == 'main':
    def main():
        if len(sys.argv) != 4:
            sys.stderr.write(__doc__)
            sys.exit(1)
        srcname, desttype, destname = sys.argv[1:]

        # read source image
        srcimg = read_image(srcname)
        srcfs = imageutil.Filesystem(srcimg)

        # make destination image
        destimg = make_image(desttype)
        destfs = imageutil.Filesystem(destimg)
        destfs.format(srcfs.diskname)

        # copy files from source into destination
        copy_files(srcfs, destfs)

        # write destination image
        with open(destname, 'wb') as f:
            f.write(destimg.data)
    main()
