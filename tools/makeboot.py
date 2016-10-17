'''
Make a bootable PEDISK disk image using the files from the 5.25" version.

This can be used to make a 5.25" or an 8" PEDISK disk.  The files from
the 5.25" system will boot up on 8" hardware but will not be
fully functional due to hardcoded sector constants.  These will
need to be fixed to produce a working 8" system.

Usage: makeboot.py <5|8> <imgname>
'''
import datetime
import os
import shutil
import sys
import tempfile

import imageutil

here = os.path.abspath(os.path.join(os.path.dirname(__file__)))
def asmpath(basename):
    dirname = os.path.abspath(os.path.join(here, '..', 'src'))
    return os.path.join(dirname, basename)

def acme(srcfile, outfile):
    res = os.system("acme -v -f cbm -o '%s' '%s'" % (outfile, srcfile))
    assert res == 0

def main(argv):
    if len(sys.argv) != 3:
        sys.stderr.write(__doc__)
        sys.exit(1)
    size_in_inches, imagename = sys.argv[1:]

    # make and format the image
    img = imageutil.DiskImage.make_for_physical_size(size_in_inches)
    fs = imageutil.Filesystem(img)
    now = datetime.datetime.now()
    diskname = now.strftime('%Y%m%d').encode('ascii') # b'20161016'
    fs.format(diskname=diskname)

    here = os.getcwd()
    tempdir = tempfile.mkdtemp()
    os.chdir(tempdir)

    try:
        # assemble the two sources that make up the special boot file
        acme(srcfile=asmpath('dos_t00_s09_7800.asm'),
             outfile='dos_t00_s09_7800.bin')
        acme(srcfile=asmpath('dos_t00_s22_7a00.asm'),
             outfile='dos_t00_s22_7a00.bin')

        # write the special boot file into the image
        data = bytearray()
        with open('dos_t00_s09_7800.bin', 'rb') as f:
            data.extend(f.read())
        with open('dos_t00_s22_7a00.bin', 'rb') as f:
            data.extend(f.read())
        fs.write_file(filename=b'******', filetype=imageutil.FileTypes.LD,
            load_address=0x7800, entry_address=0x7800, data=data)

        # assemble and write all the other files into the image
        files = (
            (b'*****H', 0x7c00, 'dos_t00_s26_7c00_h_help.asm'),
            (b'*****P', 0x7c00, 'dos_t01_s01_7c00_p_directory.asm'),
            (b'*****U', 0x7c00, 'dos_t01_s05_7c00_u_disk_utility.asm'),
            (b'*****4', 0x7c00, 'dos_t01_s07_7c00_4_read_or_write.asm'),
            (b'*****3', 0x7c00, 'dos_t01_s09_7c00_3_disk_format_5inch.asm'),
            (b'*****2', 0x7c00, 'dos_t01_s15_7c00_2_disk_copy.asm'),
            (b'*****1', 0x7c00, 'dos_t01_s19_7c00_1_disk_compression.asm'),
            (b'*****D', 0x7c00, 'dos_t01_s25_7c00_d_dump_disk_or_mem.asm'),
            (b'*****N', 0x7c00, 'dos_t01_s28_7c00_n_file_rename.asm'),
            )
        for name, address, filename in files:
            # assemble the file
            srcfile = asmpath(filename)
            outfile = '%s.bin' % os.path.splitext(filename)[0]
            acme(srcfile=srcfile, outfile=outfile)
            # write it into the image
            with open(outfile, 'rb') as f:
                fs.write_file(filename=name, filetype=imageutil.FileTypes.LD,
                    load_address=address, entry_address=address, data=f.read())
    finally:
        os.chdir(here)
        shutil.rmtree(tempdir)

    # save image file
    with open(imagename, 'wb') as f:
        f.write(img.data)
    print("PEDISK image file written to %s" % imagename)

if __name__ == '__main__':
    main(sys.argv)
