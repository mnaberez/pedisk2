'''
Make a bootstrap file.  The bootstrap file is a program that is
stored on a CBM disk and has the first 100 sectors of a PEDISK
disk embedded into it.  When run, it writes those sectors to
the PEDISK.

Process for bootstrapping the PEDISK with no existing media:
 - Assemble format.asm, run it to format a new PEDISK disk
 - Run makeboot.py to make a boot disk image
 - Run makestrap.py (this file) to make a bootstrap file from the image
 - Assemble the bootstrap file, run it to write the sectors
 - Boot from the new disk with "SYS 59904"

Usage: makestrap.py <input.img> <output.asm>
'''
import sys

if len(sys.argv) != 3:
    sys.stderr.write(__doc__)
    sys.exit(1)

imagename, asmname = sys.argv[1:]

# read first 100 sectors of the image file
with open(imagename, 'rb') as f:
    data = bytearray(f.read(100 * 128))

# convert it to assembly: "    !byte $00,$ab,$f2,..."
bytes_stmt = "    !byte " + ','.join([ "$%02x" % d for d in data ])

# load assembly code template
with open('../bootstrap/bootstrap.asm', 'r') as f:
    asm_code = f.read()

# write a bootstrap file using bootstrap.asm as a template
with open(asmname, 'w') as f:
    f.write(asm_code)
    f.write("\n")
    f.write(bytes_stmt)
