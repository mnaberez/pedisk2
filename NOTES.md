PEDISK II Notes
===============


Initialization
--------------

Before running any other commands, the PEDISK II needs to be initialized:

    sys 59904

It should print the welcome banner:

    pedisk ii system
    cgrs microtech
    langhorne,pa.19047 c1981

After a short time, it will return to the ``ready.`` prompt.  If the DOS
can't be loaded from disk, a ``disk error`` message will be printed before
the prompt the prompt returns.  The BASIC wedge is not installed if the DOS
is not loaded.


Drive Selection
---------------

The drive must be selected before most other commands will work.

Select the drive:

    sys 60320

Deselect the drive:

    sys 60171

When the drive is selected, there will be an audible click as the head
load solenoid engages.  The activity LED on the front of the drive will
also turn on.  When deselected, the solenoid releases and the LED turns off.


Head Step
---------

Step out (decrease track, towards track 0):

    poke 59776,99

Step in (increase track, towards track 76):

    poke 59776,67

Do not step beyond track 76.  It will bump against the stop.


Random Seek
-----------

Restore (go to track 0):

    poke 59776,11

Seek to a random track:

    poke 59779,t  : rem put track number in data register
    poke 59776,27 : rem seek to track

Show current track:

    print peek(59777)


Track Zero Sensor
-----------------

The track zero sensor is on pin 34 of the FD1793.  When the head is
positioned on track zero, pin 34 is low.  When it is not, pin 34
is high.

Bit 2 of the FD1793 status register is track zero status:

    print peek(59776) and 4

Prints ``4`` when positioned on track zero, should print ``0``
when on any other track.


Write Protect Sensor
--------------------

The write protect sensor is on pin 36 of the FD1793.  When the notch is
covered, pin 36 is high.  When it is not, pin 36 is low.

Bit 6 of the FD1793 status register is write protect status:

    print peek(59776) and 64

Prints ``64`` when notch is not covered, ``0`` when not is covered.


Index Hole Sensor
-----------------

The index hole sensor is on pin 35 of the FD1793.  When the drive is selected
(``sys 60320``) and a floppy is spinning, the line pulses.  When the drive
is not selected (``sys 60171``), or the floppy is not spinning, the line does
not pulse.


Disk Format
-----------

The PEDISK II model 877-1 uses an 8" single sided, soft sectored, single density
(FM) floppy disk. It has 77 tracks, 26 sectors per track, and a 128 byte sector
length.  It can hold about 250 KB.

8" double sided disks are not compatible because they have the index hole in
a different position than 8" single sided disks.  The PEDISK requires single
sided disks.  If a double sided disk is inserted, the index hole sensor will
not pulse, and the head load solenoid will not engage.

8" hard sectored disks are also not compatible.  The PEDISK requires soft
sectored disks.  If a hard sectored disk is inserted, the head load solenoid
will engage, but the format program will hang.

FD1793 pin 37 is ``/DDEN`` (``/DOUBLE DENSITY``) and should be low when double
density.  On the PEDISK II, pin 37 is high (single density).

FD1793 pin 24 is ``CLK`` (``CLOCK``).  According to the datasheet, it should
be 2.0 MHz for 8" drives.  On the PEDISK II, it measures 2.0 MHz on the
logic analyzer.

Midnite Software Gazette, Issue 11 (Feb/Mar 1983):
"PEDISK Model 877 is an 8" SD floppy disk system that uses the IBM 3740
 format ... Eight inch SD CPM (trademark of Digital Research) diskettes
 can also be read/written with the 877 system."

From the ROM:
 - Tracks: 77 ($EBD3)
 - Sectors Per Track: ($EC74)
 - Sector Length: 128 bytes ($ECCA)


Board Jumpers
-------------

Jumper W1 is ``8`` or ``5``.  This means 8" or 5.25".  When the jumpered
for ``8``, FD1793 pin 24 ``CLK`` measures 2.0 MHz on the logic analyzer.  When
jumpered for ``5``, ``CLK`` measures 1.0 MHz.  This matches what the datasheet
says ``CLK`` should be for 8" and 5.25" drives.

Jumper W2 is ``250`` or ``125``.  It is set to ``250``.  This is probably
the bit rate (kbits/sec).  For Single Density 8", the bit rate is 250
kbits/sec.  According to a [table](http://en.wikipedia.org/wiki/List_of_floppy_disk_formats),
all the 8" double density formats are 500 kbits/sec.  There is no
``500`` option on the PEDISK board.

Jumpers W3, W4, and W5 are unknown.  They are all open.

BASIC Wedge
-----------

Initializing the PEDISK II with ``sys 59904`` will attempt to load the DOS
from disk.  The wedge will only be installed if the DOS loads successfully.

Detect if the wedge is installed:

    print peek(121)

Prints ``76`` if installed or ``201`` if not installed.

All of the PEDISK II commands are loaded into RAM from the boot disk, with the
sole exception of ``!load``.  The ``!load`` command can be used even if the boot
disk can't be loaded.  However, the wedge must be force installed.

Force the wedge to install:

    sys 60159

Load a program:

    !load"foobar:0"

The filename (``foobar``) may be up to six characters.  The drive number
(``:0``) must be included or else a ``?syntax error`` will result.

