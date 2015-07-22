Let's use the beagleboneblack to sniff and identify famicom cartridges.

I want to be able to identify NES carts as they are playing, without interfering with the operation of the game.

The famicom/NES clock is around 1.789773 Mhz. The machine operates at 5V logic, and is 8 bits of data with 16 bit addresses. So if we want to sniff the address and data lines of a cart we need:

16 pins for address (Pins 4-19, A0-A15)
8 pins for data (Pins 28-21, D0-D7)
1 pin for clock (Pin 34, R/W, on high the cpu is reading data)

Let's make a database of the first, say 256 memory reads, and use that as a fingerprint.

Can we have use the famicom clock as an external interrupt, triggering a read of the address and data lines? Let's make a plan:

# With BeagleLogic

The famicom/nes is 5v. The beaglebone has 3.3v GPIO. The awesome Kumar Abhishek has created a cape and software to turn a beagleboneblack into a logic analyser, called [beaglelogic](http://beaglelogic.net). It supports up to 14 inputs at 100Ms/s. But it only has 14 channels, so here are the steps to try.

# Software description

1. Run identify-or-add
2. Turn on famicom
3. Either return the cart's title, or prompt to add a new title

# Detailed description

1. identify-or-add.py allocates 256bytes of shared memory, and puts the offset in a known, magic address
2. identify-or-add waits for PRU0 'sniffed' signal
3. PRU0 reads magic address for where it should start writing data reads
4. PRU waits for external hardware interrupt from R/W pin
5. On each rising edge, write D0-D7 to the shared memory address
6. After 256 bytes, send 'sniffed' signal to identify-or-add.py
7. identify-or-add.py checks csv if signature exists, and if so, returns the title
8. if csv signature does not exist, prompt user to write the title

# Roadmap

### v0

sniff first 256 bytes of data (D0-D7) read with beaglelogic triggered by r/w pin rising

### v1

8192 samples using PRU0/1 storing to RAM 0,1, and 2

D7-D0 store in Data RAM 0 ( 8KB )
A7-A0 store in Data RAM 1 ( 8KB )
A8-A11 are stored as high nibbles in Shared RAM 2 ( 12KB )
A12-A15 are stored as low nibbles in Shared RAM 2 ( 12KB )

   name | pru | pins | memory_address | RAM | notes
--------|-----|------|----------------|-----|-------
    CLK |  0  | 0    |                |     |
  D7-D0 |  0  | 1-8  | 0x0000_0000    |  0  |
A15-A12 |  0  | 9-12 | 0x0001_0000    |  2  | high nibble
    CLK |  1  | 0    |                |     |
  A7-A0 |  1  | 1-8  | 0x0000_2000    |  1  |
 A11-A8 |  1  | 9-12 | 0x0001_0000    |  2  | low nibble

### v2

add some PISO shift-registers to read data+address and dump roms as they are playing with beaglelogic

### v3

add some nice lcd screen output
