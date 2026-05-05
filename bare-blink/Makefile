MCU = atmega328p
TARGET = bare-blink
SRC = bare-blink.c
PORT = /dev/ttyACM0

$(TARGET).elf: $(SRC)
	avr-gcc -mmcu=$(MCU) -Os -o $(TARGET).elf $(SRC)

$(TARGET).hex: $(TARGET).elf
	avr-objcopy -O ihex -R .eeprom $(TARGET).elf $(TARGET).hex

flash: $(TARGET).hex
	avrdude -p $(MCU) -c arduino -P $(PORT) -U flash:w:$(TARGET).hex:i

clean:
	rm -f $(TARGET).elf $(TARGET).hex

.PHONY: flash clean
