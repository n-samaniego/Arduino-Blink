#include <avr/io.h>

#define F_CPU 16000000 // Speed of the ATMEGA328P on the UNO; used so _delay_ms() works correctly
#include <util/delay.h>

int main(void) {
    // configuring PB5, the onboard LED
    DDRB = 1 << 5; // set to output
    PORTB = 0; // initial value of PORTB is 0, but writing a 0 to it just in case. controls whether the LED is on or off.
    // PINB = 0 << 5; only used for reading input, my mistake

    // configuring PC0, the pin i'm using to drive the external LED
    DDRC = 1; // same as above
    PORTC = 0; // same as above
    // PINC = 0; same as above



    while (1) {
        PORTB = 1 << 5;
        PORTC = 1;

        _delay_ms(500);

        PORTB = 0;
        PORTC = 0;

        _delay_ms(500);

        }

}
