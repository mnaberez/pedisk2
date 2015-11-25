'''
Format a PEDISK disk image
Usage: peformat.py <5|8> <image.img>
'''

import sys

import imageutil

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 3:
            sys.stderr.write(__doc__)
            sys.exit(1)
        size_in_inches, imagename = sys.argv[1:]

        # make an image and format a filesystem on it
        img = imageutil.DiskImage.make_for_physical_size(size_in_inches)
        fs = imageutil.Filesystem(img)
        fs.format(diskname=b'12345678')

        # write image file to disk
        with open(imagename, 'wb') as f:
            f.write(img.data)
    main()
