__SP_H__ = 0x3e
__SP_L__ = 0x3d



.org 0x0000
    rjmp main

.org 0x040
main:
    LDI R16, hi8(0x08FF)
    OUT __SP_H__, R16
    LDI R17, lo8(0x08FF)
    OUT __SP_L__, R17


    L1:
        rjmp L1
