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

v0: sniff first 256 bytes of data read with beaglelogic and r/w pin
v1: add some PISO shift-registers to read data+address and dump roms as they are playing with beaglelogic
