'''
Convert a PEDISK image from one size to another.
Usage: convert.py <source.img> <5|8> <dest.img>
'''
import sys

import imageutil

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

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 4:
            sys.stderr.write(__doc__)
            sys.exit(1)
        srcname, size_in_inches, destname = sys.argv[1:]

        # read source image
        srcimg = imageutil.DiskImage.read_file(srcname)
        srcfs = imageutil.Filesystem(srcimg)

        # make destination image
        destimg = imageutil.DiskImage.make_for_physical_size(size_in_inches)
        destfs = imageutil.Filesystem(destimg)
        destfs.format(srcfs.diskname)

        # copy files from source into destination
        copy_files(srcfs, destfs)

        # write destination image
        with open(destname, 'wb') as f:
            f.write(destimg.data)
    main()
