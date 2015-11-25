'''
Extract all files from a PEDISK disk image
Usage: extract.py <image.img>
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

def modern_filename(entry):
    f = entry.filename.decode('utf-8', errors='ignore').strip()
    f += '.' + imageutil.FileTypes.name_of(entry.filetype)
    f = f.replace('*', '_').replace('?', '_').lower()
    return f

def extract_files(fs, output_dir):
    for entry in fs.read_dir():
        if not entry.used:
            continue
        data = fs.read_file(entry.filename)

        filename = os.path.join(output_dir, modern_filename(entry))
        if entry.deleted:
            filename += '.deleted'

        with open(filename, 'wb') as f:
            f.write(data)

if __name__ == '__main__':
    def main():
        if len(sys.argv) != 2:
            sys.stderr.write(__doc__)
            sys.exit(1)
        imagename = sys.argv[1]

        img = read_image(imagename)
        dirname = os.path.splitext(os.path.basename(imagename))[0]
        os.mkdir(dirname)
        fs = imageutil.Filesystem(img)
        extract_files(fs, dirname)
    main()
