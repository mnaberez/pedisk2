'''
Make a bootstrap image.  The bootstrap image is a D64 image that
can be written to a 4040 or similar CBM DOS drive.

Process for bootstrapping the PEDISK with no existing PEDISK media:
 - Run makeboot.py to make a boot disk image
 - Run makestrap.py (this file) to make a bootstrap D64 image from it
 - Write the D64 image to a 4040 drive or similar drive
 - Run the "FORMAT8" program from the 4040 to format a PEDISK 8" disk
 - Run the "BOOTSTRAP" program from the 4040 to write the PEDISK sectors
 - Boot from the new PEDISK disk with "SYS 59904"

Usage: makestrap.py <input.img> <output.d64>
'''
import shutil
import sys
import os
import tempfile

import imageutil

def extract_tracks_to_prg_files(imagename):
    img = imageutil.DiskImage.read_file(imagename)
    fs = imageutil.Filesystem(img)
    fs.compact()

    last_track = min(img.TRACKS - 1, fs.next_free_ts[0] + 1)

    for track in range(last_track + 1):
        img.seek(track=track, sector=1)
        data = img.read(img.SECTORS * img.SECTOR_SIZE)

        if track == last_track:
            next_track = 0xFF # no next track
        else:
            next_track = track + 1

        with open("track $%02x" % track, "wb") as f:
            f.write(bytearray([0x00, 0x08])) # load address = 0x0800
            f.write(bytearray([track])) # track number
            f.write(bytearray([img.SECTORS])) # number of sectors
            f.write(bytearray([next_track])) # next track number
            f.write(data) # sector data

def main(argv):
    if len(argv) != 3:
        sys.stderr.write(__doc__)
        sys.exit(1)
    imagename, d64name = map(os.path.abspath, argv[1:])

    here, tempdir = os.getcwd(), tempfile.mkdtemp()
    os.chdir(tempdir)
    try:
        extract_tracks_to_prg_files(imagename)

        res = os.system("acme -v -f cbm -o format8 '%s'" %
            os.path.join(here, 'bootstrap', 'format8.asm'))
        assert res == 0

        res = os.system("acme -v -f cbm -o bootstrap '%s'" %
            os.path.join(here, 'bootstrap', 'bootstrap.asm'))
        assert res == 0

        res = os.system("c1541 -format bootstrap,pe d64 '%s'" % d64name)
        assert res == 0
        for filename in os.listdir('.'):
            os.system("c1541 -attach '%s' -write '%s'" %
                (d64name, filename))
            assert res == 0
    finally:
        os.chdir(here)
        shutil.rmtree(tempdir)
    print("D64 file written to %s" % d64name)

if __name__ == '__main__':
    main(sys.argv)
