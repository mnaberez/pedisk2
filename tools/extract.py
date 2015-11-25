'''
Extract all files from a PEDISK disk image
Usage: extract.py <image.img>
'''
import os
import sys

import imageutil

def extract_files(fs, output_dir):
    for entry in fs.read_dir():
        if not entry.used:
            continue
        data = fs.read_data(entry)

        filename = os.path.join(output_dir, entry.modern_filename)
        with open(filename, 'wb') as f:
            f.write(data)

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 2:
            sys.stderr.write(__doc__)
            sys.exit(1)
        imagename = sys.argv[1]

        img = imageutil.DiskImage.read_file(imagename)
        dirname = os.path.splitext(os.path.basename(imagename))[0]
        os.mkdir(dirname)
        fs = imageutil.Filesystem(img)
        extract_files(fs, dirname)
    main()
