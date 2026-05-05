#include <stdint.h>

#define DDRB *(volatile uint8_t *)0x24
#define DDRC *(volatile uint8_t *)0x27
#define PORTB *(volatile uint8_t *)0x25
#define PORTC *(volatile uint8_t *)0x28

int main(void) {
    // configuring PB5, the onboard LED
    DDRB = 1 << 5; // set to output
    PORTB = 0; // initial value of PORTB is 0, but writing a 0 to it just in case. controls whether the LED is on or off.

    // configuring PC0, the pin i'm using to drive the external LED
    DDRC = 1; // same as above
    PORTC = 0; // same as above


    while (1){
        PORTB = 1 << 5;
        PORTC = 1;

        __builtin_avr_delay_cycles(8000000);

        PORTB = 0;
        PORTC = 0;

        __builtin_avr_delay_cycles(8000000);
    }

}
