34-pin Floppy Drive Connector
-----------------------------

| PEDISK II 34-pin | 50-pin |Dir  |Siemens   | Shugart | Micropolis | Notes |
|-----------------:|-------:|:---:|---------:|--------:|-----------:|:-----:|
| N/C              | 2      |     |          |         |            |       |
| N/C              | 4      |     |          |         |            |       |
| N/C              | 6      |     |          |         |            |       |
| N/C              | 8      |     |          |         |            |       |
| N/C              | 10     | In  | 2SIDED   |         |            |       |
| N/C              | 12     | Out | DCG      |         |            |       |
| N/C              | 14     | Out | SIDE     |         |            |       |
| N/C              | 16     | Out | IN USE   |         |            |       |
| N/C              | 18     | Out | HLD      |         |            |       |
| 4                | 20     | In  | INDEX    | (IN USE)| N/C        | *1, 2*|
| 6                | 22     | In  | READY    | SEL4    | RDY        | *3*   |
| 8                | 24     | In  | (SECTOR) | INDEX   | SEC/INDEX  | *1, 2*|
| 10               | 26     | Out | SEL1     | SEL1    | SEL1       |       |
| 12               | 28     | Out | SEL2     | SEL2    | SEL2       |       |
| N/C              | 30     | Out | SEL3     | SEL3    | SEL3       |       |
| 16               | 32     | Out | SEL4     | MTRON   | MTRON      | *4*   |
| 18               | 34     | Out | STEP IN  | STEP IN | STEP IN    | *5*   |
| 20               | 36     | Out | STEP     | STEP    | STEP       |       |
| 22               | 38     | Out | WDAT     | WDAT    | WDAT       |       |
| 24               | 40     | Out | WRITE    | WGATE   | WGATE      |       |
| 26               | 42     | In  | TRK00    | TRK00   | TRK00      |       |
| 28               | 44     | In  | WPROT    | WPROT   | WPROT      |       |
| 30               | 46     | In  | RDATA    | RDATA   | RDATA      |       |
| 32               | 48     | Both| (SEP DAT)| HD SEL  | HD SEL     | *1, 6*|
| N/C              | 50     | In  | (SEP CLK)| RY/DC   | SEL4       | *1*   |

Notes:

1. `(XX)` is an optional signal that may not be installed on the drive.

2. PEDISK II always connects pins 4(20) and 8(24) in parallel.

3. PEDISK II is no-connect unless jumper W4 is installed.  If W4 is installed,
   the WD1793 gets the `READY` signal from the drive.

4. PEDISK II is no-connect unless jumper W3 is installed.  If W3 is installed,
   `MTRON` is grounded (motor always on).

5. `STEP IN` is also commonly known as `DIRC` (Direction Control).

6. PEDISK II is no-connect unless jumper W5 is installed.  If W5 is installed,
   the PEDISK II can control `HD SEL` (Head Select).


Jumper Settings
---------------

| Jumper     |5.25"  |8"     | Description                          | Notes |
|------------|-------|-------|--------------------------------------|:-----:|
| W1 250/125 |250    |250    | Select Bit Rate (kbits/sec)          |       |
| W2 5/8     |5      |8      | ???                                  |       |
| W3         |Close  |Open   | Grounds MTRON                        |       |
| W4         |Depends|Depends| Close for Micropolis drives with RDY | *1*   |
| W5         |Close  |Open   | Connects HD SELECT for 5.25"         | &nbsp;|

Notes:

1. An 8" PEDISK II system was found with a Siemens FDD100-8 drive.  This drive
   has a `READY` signal on pin 6(22) but the PEDISK II was configured with W4
   open.  The system works in this configuration.

In addition to the jumpers above, the WD1793's `/DDEN` (Double Density Enable)
line must be set high for 8" (single density) or low for 5.25" (double
density).  `/DDEN` is controlled by pin 15 of the U7 latch.  The
firmware/software must be changed to set `/DDEN` appropriately.  Another option
would be to disconnect `/DDEN` from the latch and tie it permanently high
or low.
