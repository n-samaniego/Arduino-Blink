---
id: journal
aliases: []
tags:
- C
- Embedded
---
# Journal for Bare Metal Arduino Blink
## Introduction
Here's my first foray into the embedded world. Using an Arduino UNO, I'll be writing some bare-metal C to make an LED on the board blink.

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

### The Datasheet
> [!info] A note about memory addresses
> Memory addresses are written in hexadecimal, 0x__, to represent a location in memory. Each digit in the number represents 4 bits, so both together represents 1 byte.

Here are some important things I learned from the datasheet:
- Speed of 20MHz
- The specific one that the UNO is using is the 28P3 package, which is a PDIP (Plastic Dual Inline Package)
- The datasheet contains both the Register Summary and the Instruction Set summary. If I wanted to, I could recreate this project using assembly code (I probably will)



