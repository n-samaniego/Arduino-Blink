---
id: journal
aliases: []
tags:
- C
- Embedded
---
# Journal for Bare Metal Arduino Blink
## Introduction
Here's my first foray into the embedded world. Using an Arduino UNO R3, I'll be writing some bare-metal C to make an LED on the board blink. Additionally, I'll drive an external LED to blink at the same time. I'll be doing this twice: once with the use of a library, and a second time with no help from the library.

After completing those first two parts, I'll be rewriting my program in AVR assembly. Since this is the first time I will be writing assembly code, doing it on a trivial project such as this will be a good learning experience. That is part 3. Part 4 will be back to C and using in-line assembly. I think that, for the future, that will be the way I'll be utilizing assembly in my code, so it's also good to have some exposure here when the complexity is still low.

Throughout my learning process, I'll be utilizing the use of Claude AI as a mentor to help me through things I don't understand. Already, it has been a great tool in understanding how to use Git, set up my development environment, get started with learning C, and so many other things. As I'm embarking on this journey alone, internet searches as well as talking to Claude AI are my main sources of guidance.



## Set Up
To start, I'm going to go through the datasheet of the UNO's microcontroller, the ATmega328P. Also, to set up my development machine, I'm going to be downloading the tools to write, compile, and flash my code onto the MCU.

### The Tools
Since I'll be writing on a Linux machine, specifically an Arch-based distribution called CachyOS, my first step is to run the following in order to start writing my program.

```
sudo pacman -S avr-gcc avr-libc avrdude
```

Because the ATmega328P is an AVR chip, the standard GCC I currently have installed on my machine is not suitable. Compiling my code with GCC would produce machine code for a whole differrent architecture and ISA, specifically my x86-64 CPU.

AVR-GCC is my cross-compiler. In order to compile machine code for the UNO, I will need to compile it on my computer and then flash it onto the MCU. AVR-LibC is the standard library I need, since glibc assumes things like an OS, a heap, syscalls, a filesystem, and more. avrdude is the tool I'll use to push my code over USB into my UNO.

### The ATMEGA328P Datasheet
> [!info] A note about memory addresses
> Memory addresses are written in hexadecimal, 0x__, to represent a location in memory. Each digit in the number represents 4 bits, so both together represents 1 byte.

Here are some important things I learned from the datasheet:
- Speed of 20MHz
- The specific one that the UNO is using is the 28P3 package, which is a PDIP (Plastic Dual Inline Package)
- The datasheet contains both the Register Summary and the Instruction Set summary. If I wanted to, I could recreate this project using assembly code (I probably will)
- A metal leg on the chip is a leg. These legs are grouped up (in groups of up to 8) into ports.
- Each one of the port pins can be configured by accessing 3 different register bits. These are DDxn, PORTxn, and PINxn, where x denotes the port and n is the leg number.
- These register bits live in the memory addresses DDRx, PORTx, and PINx.

> [!info] Example
> On the Arduino, there is a pin called A0 (or D14). This is connected to PC0 on the ATMEGA328P. In order to configure this pin, I would need to write to bit 0 of DDRC, PORTC, and PINC.

### The Arduino Pin Out
I also grabbed the Arduino UNO R3's pin out. In the advanced section, it lists the names/uses of the pins for interrupts, I2C, analog, MCU, and Arduino itself. This will be vital for my use, as I plan to heavily reference this when writing my code.

Now, to build!


## On Coding
First thing I need to do is learn some C syntax that will help me. While a lot of this is abstracted away with the use of avr-libc, since I plan on implementing the code once more without it's help, it'd serve me to understand what exactly is abstracted away. At least a little bit.

Since the registers I'm writing to are spots in memory, I'll have to use pointer syntax to write to them. For example, the following line writes to the register bit controlling whether PB0 is an input or an output pin (from the documentation, setting it to a 1 means it's an output pin):
```c
DDRB = 1;
```
> [!note] On the use of 'DDRB'
> DDRB is a dereferenced pointer. With the inclusion of avr-libc, I can basically treat DDRB as a variable for this first part of my project.

> [!note] On pointers and dereferencing
> The & operator gives you the address of a variable in memory. The use of * depends on the context. When declaring a pointer, something like int *p "means p is a pointer to an int". When using a pointer, *p means "go to the address p holds and give me the value there (or I'm going to write here)", which is dereferencing p.

Because the register is literally a byte in memory, configuring PB0 means writing to the least significant bit in that register. If we were to take a look at that spot in memory, we'd see "0000 0001".

If I wanted PB5 to be configured as an output instead of PB0, I have multiple ways of going about it. First, I could understand that, in binary, the fifth bit is the "16's" place. In this case, I could do the following:
```c
DDRB = 16;
```
Which in the register would look like "0001 0000". Not the worst thing, but there's an easier way.

Using a bitwise operation, specifically the << operator, I can shift a bit left by however many bits I specify. Using this, I can assign and shift all in one line!
```c
DDRB = 1 << 5;
```

This looks identical to assigning a value of 16 to DDRB directly!

One last thing, if I wanted to set BOTH PB0 and PB5 to as outputs, I can use the OR operator. Specifically, I can use |=, which both assigns and OR's together the current value.

If I already set PB5 high using either of the previous methods, I can do the following to also set PB0 to high (while leaving the other bits in the register untouched).
```c
DDRB |= 1;
```

This is a bitmask operation, and I can utilize AND, OR, and NOT to do any number of similar operations if I need to do so.



## Part 1: blink.c
Alright, I'm writing this after I finished making both the on-board LED and external LED blink. Hooray! I did it!

That was... not that hard, and yet, it was the product of a few hours of work. Between learning some of the C syntax I talked about above, I also had to struggle with a lot of things. Wrong headers, my neovim LSP throwing me warnings, trying to write clean and concise code, writing a makefile for the first time (and everything that came with that), and getting my computer to let me flash my arduino... basically, coding was the easy part.

### Neovim LSP
This was the of my problems, and while it was an easy fix, it was an unfortunate error. I managed to NOT install all the tools i was supposed to. None of them. Even though I talked about it during setup, I guess I never actually ran the command. Silly me.

Next issue was, when I did have everything installed, neovim was still throwing a fit. Claude helped me write a .clangd file which told the LSP where to look. I still don't really understand what I needed that for, but it's also uploaded to github for reference.

As far as I understand, it's telling clangd what I'm doing and with compile flags so it knows that I'm not making things up. It didn't recognize my header or my variables (like DDRB, etc.), but once I got that sorted out, I had more problems to face.

### Headers
At first, I tried doing #include <avr-libc>, which came from a misunderstanding of how avr-libc actually works. It's a library with a bunch of header files I need to include individually, I can't include the whole thing.

From that, Claude clued me into the fact that the header files I actually need are avr/io.h and util/delay.h. Additionally, to use _delay_ms(), I need to define the frequency. While the ATMEGA328P *can* run at 20MHz, it actually runs at 16MHz on the Arduino UNO. That was a small mixup, but would've cost me if I didn't know.

### The code
Once I got the headers fixed, next was actually writing the code. Again, the easy part!

To start, I configured both the pins I decided to use for this project. PB5 is the on-board LED and PC0 is the pin I decided to use to drive the external LED. I set both their corresponding DDRx registers bits to 1, configuring both as outputs. Next, I set both their corresponding PORTx registers (not register bits!) to 0. Initially, I thought PINx controlled whether or not it was logic high or low, but I learned that PINx is actually for reading input! In this case, they are unneeded.

To run my code, I went with a while (1) loop. There is the fact that I could've used a for (;;) loop, but I feel like while true loops are more... common? Widely used?

Regardless, the code I wrote is very simple. Since both PB5 and PC0 were set to 0; I wrote a 1 to both corresponding PORTx bits. Using _delay_ms(500), I have the code wait for half a second, then I set it low again, then wait another half second. Easy!

There are some choices I made here. I didn't have to necessarily set both PORTx registers to 0. In the documentation, they have an initial value of 0. Additionally, while I could've used the bitmask operations I learned earlier, I didn't need to. Both these pins are on different ports, so there was no need to "not touch" the other bits when setting everything to 0. I understand that it's the safer approach, but again, it's unneeded in this specific context.

### The Makefile
...This one was confusing. Before this, I barely had any experience with Makefiles. Really, I had none. I didn't really understand what they were doing, nor did I have any idea on the syntax.

I made Claude walk me through writing it step-by-step, though, so now I think I have a much cleaner understanding of what's happening.

My takeaway from making my own Makefile for this program is that Makefiles are close to bash scripts, but not really. You can set variables, you call them with $, you're writing out some commands that the terminal will run. Okay so far.

The syntax was something I struggled with. The "target: dependancies" and then rules right after didn't make sense to me until I was walked through it all.

Also, I dont really have any idea what flags were used for ANY of my tools before I started writing the Makefile, so that was all the AI's doing. Definitely going to rectify that issue soon though, since I plan on doing this all again with no avr-libc. Flags in general are something that I'm woefully ignorant about.

The flow of the make file is this:
- Take blink.c, compile it with avr-gcc with flags specifying the MCU, to optimize for size, and the output name (blink.elf) to make a .elf file.
- Take blink.elf, convert it to a .hex file, with flags specifying that I need the Intel HEX format and that I don't need the EEPROM section, and name it blink.hex.
- Make a command that flashes the .hex file to my UNO.
- Make a command that cleans the memory of the UNO.

### Flashing
I ran into some issues while flashing the program onto the board. avrdude threw a fit saying that it didn't have permissions, so with Claude's help, I managed to fix what was wrong there.

Turns out, I needed a seperate user group that has permissions to write to the UNO.

After that, I successfully flashed my first embedded program onto the board. The on-board LED was blinking, and now it was time to move on to the external LED.

### The External Circuit
Next, I moved onto building the circuit to drive the external LED. I used the PC0 (which is A0 on the board) and GND pins to create my circuit. Additionally, I needed a resistor, but didn't know what value to choose.

I knew a couple things here. Logic high on the pin output's 5V. Typically, the forward voltage on an LED is 2V, with a current of 20mA.

Using my extensive knowledge of Electrical Engineering and Ohm's Law, I took the delta between the two voltage values (which is what I need the resistor to drop), divided by the resistance, and came up with an answer of 150 Ohms. I already had a 220 Ohm resistor on hand, so while the LED was going to be a bit dim, it was more that enough for proof of concept.

I wired everything together, turned my UNO back on, and beheld my work!

Both LEDs were blinking, in sync! Exactly what I wanted! I don't feel particularly accomplished after completing that, but now I'm ready to tackle the next part. No more avr-libc for me!



## Part 2: bare-blank.c
Alright, just finished testing my program for part 2! Everything looks good, and I learned a lot. Again, the reason I'm doing this is to tear back one layer of abstraction and get even closer to the hardware. Without arv-libc, I had to implement some defines, learn about casts, struggle again with understanding pointers, and reimplement the delay. The while loop was generally the same, except for one specific part.

### Casts
What even are they? It took me a minute to understand and why I needed them, but now it makes sense.

In order to write to the registers I needed to, I had to do something special.

Let's take the example of register DDRB. avr-libc abstracted away this part, but it's address is not literally 'DDRB'. Looking at the datasheet again, DDRB's address starts at 0x24 and is 8 bits wide.

To write to this address, I had to utilize a cast:
```c
#define DDRB *(volatile uint8_t *)0x24
```

Again, 0x24 is the memory address, but if I just say "0x24 = 1 << 5", my compiler would probably throw a fit. I haven't tried it, but I really don't want to try.

The cast itself is the "(volatile uint8_t *)" bit. To break it down, volatile tells the compiler that every read and write to this address matters. uint8_t is defined in stdint.h, which is why it was my only include. It's been part of the C standard library since C99, so any compiler (that can compile from C99 on) has that available. uint8_t is a typedef (indicated by the _t), which is basically an alias for an unsigned 8 bit integer. the * tells the compiler to treat whatever follows as a pointer to a volatile uint8_t.

Finally, the * on the outside means that I am dereferencing the pointer.

I did this for DDRB, DDRC, PORTB, and PORTC, with all their corresponding memory addresses.

### The Delay
Because I am not including util/delay.h, I'm unable to use _delay_ms() in this part. Luckly, there is a compiler build in function (in avr-gcc) called __builtin_avr_delay_cycles(). It takes in a number of cycles and waits for that many to pass before continuing with the rest of the code.

In my first implementation, I gave it a delay of 500ms between on and off. To do this in the second part, I had to calculate how many cycles I needed to pass for it to be half a second.

I do know that the clock frequency of the UNO is 16Mhz, so 16,000,000 cycles in one second. A half second would take half as many cycles, so 8,000,000.

Not too bad!

With this, I copied the Makefile, changed the TARGET and SRC variables so that it works with bare-blink.c, made it, and flashed it. I got the same expected behavior. Part 2 is a success.



## Part 3: blink.S
Once again, I'll be rewriting my program, but this time in AVR assembly. As it is my first time writing assembly, I expect this to take a while.

My first step is to look at what assembly of my program might look like. Doing the following command in the terminal gives me a blink.s to peruse:
```
avr-gcc -mmcu=atmega328p -Os -S -o blink.s bare-blink.c
```

Looking at the instructions with the documentation there are definitely some things I recognize. Instructions such as out, subi, sbci, and nop are all very clear to me, but I still really have no idea how to read and understand what's going on. I'm going to walk through it with the help of Claude to understand what's going on.

### Understanding the Instructions

