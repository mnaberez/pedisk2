# PEDISK II

This repository holds reverse engineering work on the
[PEDISK II](http://mikenaberezny.com/hardware/pet-cbm/microtech-pedisk-ii/) from CGRS Microtech,
a floppy disk controller for Commodore PET/CBM computers.

## Files

 - `rom_e800.bin` is a binary dump of the EPROM.

 - `rom_e800.asm` is a disassembly of it.

## Assemble

The `.asm` files can be assembled with the
[ACME](http://www.esw-heim.tu-clausthal.de/~marco/smorbrod/acme/)
assembler:

    $ acme -v1 --outfile test.bin pedisk2.asm

It should assemble a binary that is identical to the original.

## Credits

- Lee Davison did the initial disassembly of the ROM.
- Jim Oldfield provided the PEDISK disks from which the DOS code was recovered.
- Mike Naberezny disassembled the DOS code and wrote the image tools.
- Steve Hirsch provided help and formatted 8" disks used for early testing.
- Josh Bensadon reverse engineered the original PCB and made the schematic.
- Steve Gray made the replica PCB layout and had boards manufactured.
- Mike Stein built the replica and provided help and input throughout.
