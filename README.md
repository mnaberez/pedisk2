# PEDISK II

This repository holds reverse engineering work on the
[PEDISK II](http://mikenaberezny.com/hardware/pet-cbm/microtech-pedisk-ii/) from CGRS Microtech,
a floppy disk controller for Commodore PET/CBM computers.

## Files

 - `pedisk2.bin` is a binary dump of the EPROM.

 - `pedisk2.asm` is a disassembly of it.

## Assemble

The `.asm` files can be assembled with the
[ACME](http://www.esw-heim.tu-clausthal.de/~marco/smorbrod/acme/)
assembler:

    $ acme -v1 --outfile test.bin pedisk2.asm

It should assemble a binary that is identical to the original.

## Credits

The initial disassembly was done by Lee Davison.
