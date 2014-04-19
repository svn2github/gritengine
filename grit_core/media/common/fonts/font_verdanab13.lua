local codepoints = {
    [0x0020] = {    0,  111,    4,   17 }, --  
    [0x0021] = {    4,  111,    6,   17 }, -- !
    [0x0022] = {   10,  111,    7,   17 }, -- "
    [0x0023] = {   17,  111,   11,   17 }, -- #
    [0x0024] = {   28,  111,    9,   17 }, -- $
    [0x0025] = {   37,  111,   17,   17 }, -- %
    [0x0026] = {   54,  111,   11,   17 }, -- &
    [0x0027] = {   65,  111,    4,   17 }, -- '
    [0x0028] = {   69,  111,    7,   17 }, -- (
    [0x0029] = {   76,  111,    7,   17 }, -- )
    [0x002a] = {   83,  111,    9,   17 }, -- *
    [0x002b] = {   92,  111,   11,   17 }, -- +
    [0x002c] = {  103,  111,    5,   17 }, -- ,
    [0x002d] = {  108,  111,    7,   17 }, -- -
    [0x002e] = {  115,  111,    5,   17 }, -- .
    [0x002f] = {    0,   94,    9,   17 }, -- /
    [0x0030] = {    9,   94,    9,   17 }, -- 0
    [0x0031] = {   18,   94,    9,   17 }, -- 1
    [0x0032] = {   27,   94,    9,   17 }, -- 2
    [0x0033] = {   36,   94,    9,   17 }, -- 3
    [0x0034] = {   45,   94,    9,   17 }, -- 4
    [0x0035] = {   54,   94,    9,   17 }, -- 5
    [0x0036] = {   63,   94,    9,   17 }, -- 6
    [0x0037] = {   72,   94,    9,   17 }, -- 7
    [0x0038] = {   81,   94,    9,   17 }, -- 8
    [0x0039] = {   90,   94,    9,   17 }, -- 9
    [0x003a] = {   99,   94,    5,   17 }, -- :
    [0x003b] = {  104,   94,    5,   17 }, -- ;
    [0x003c] = {  109,   94,   11,   17 }, -- <
    [0x003d] = {    0,   77,   11,   17 }, -- =
    [0x003e] = {   11,   77,   11,   17 }, -- >
    [0x003f] = {   22,   77,    8,   17 }, -- ?
    [0x0040] = {   30,   77,   13,   17 }, -- @
    [0x0041] = {   43,   77,   10,   17 }, -- A
    [0x0042] = {   53,   77,   10,   17 }, -- B
    [0x0043] = {   63,   77,   10,   17 }, -- C
    [0x0044] = {   73,   77,   10,   17 }, -- D
    [0x0045] = {   83,   77,    9,   17 }, -- E
    [0x0046] = {   92,   77,    9,   17 }, -- F
    [0x0047] = {  101,   77,   10,   17 }, -- G
    [0x0048] = {  111,   77,   11,   17 }, -- H
    [0x0049] = {    0,   60,    6,   17 }, -- I
    [0x004a] = {    6,   60,    7,   17 }, -- J
    [0x004b] = {   13,   60,    9,   17 }, -- K
    [0x004c] = {   22,   60,    8,   17 }, -- L
    [0x004d] = {   30,   60,   12,   17 }, -- M
    [0x004e] = {   42,   60,   10,   17 }, -- N
    [0x004f] = {   52,   60,   11,   17 }, -- O
    [0x0050] = {   63,   60,    9,   17 }, -- P
    [0x0051] = {   72,   60,   11,   17 }, -- Q
    [0x0052] = {   83,   60,    9,   17 }, -- R
    [0x0053] = {   92,   60,    9,   17 }, -- S
    [0x0054] = {  101,   60,    8,   17 }, -- T
    [0x0055] = {  109,   60,   10,   17 }, -- U
    [0x0056] = {    0,   43,   10,   17 }, -- V
    [0x0057] = {   10,   43,   14,   17 }, -- W
    [0x0058] = {   24,   43,   10,   17 }, -- X
    [0x0059] = {   34,   43,   10,   17 }, -- Y
    [0x005a] = {   44,   43,    9,   17 }, -- Z
    [0x005b] = {   53,   43,    6,   17 }, -- [
    [0x005c] = {   59,   43,    9,   17 }, -- \
    [0x005d] = {   68,   43,    6,   17 }, -- ]
    [0x005e] = {   74,   43,   10,   17 }, -- ^
    [0x005f] = {   84,   43,    9,   17 }, -- _
    [0x0060] = {   93,   43,    9,   17 }, -- `
    [0x0061] = {  102,   43,    9,   17 }, -- a
    [0x0062] = {  111,   43,    9,   17 }, -- b
    [0x0063] = {    0,   26,    8,   17 }, -- c
    [0x0064] = {    8,   26,    9,   17 }, -- d
    [0x0065] = {   17,   26,    9,   17 }, -- e
    [0x0066] = {   26,   26,    5,   17 }, -- f
    [0x0067] = {   31,   26,    9,   17 }, -- g
    [0x0068] = {   40,   26,    9,   17 }, -- h
    [0x0069] = {   49,   26,    4,   17 }, -- i
    [0x006a] = {   53,   26,    5,   17 }, -- j
    [0x006b] = {   58,   26,    8,   17 }, -- k
    [0x006c] = {   66,   26,    4,   17 }, -- l
    [0x006d] = {   70,   26,   14,   17 }, -- m
    [0x006e] = {   84,   26,    9,   17 }, -- n
    [0x006f] = {   93,   26,    9,   17 }, -- o
    [0x0070] = {  102,   26,    9,   17 }, -- p
    [0x0071] = {  111,   26,    9,   17 }, -- q
    [0x0072] = {  120,   26,    6,   17 }, -- r
    [0x0073] = {    0,    9,    8,   17 }, -- s
    [0x0074] = {    8,    9,    6,   17 }, -- t
    [0x0075] = {   14,    9,    9,   17 }, -- u
    [0x0076] = {   23,    9,    9,   17 }, -- v
    [0x0077] = {   32,    9,   12,   17 }, -- w
    [0x0078] = {   44,    9,    9,   17 }, -- x
    [0x0079] = {   53,    9,    9,   17 }, -- y
    [0x007a] = {   62,    9,    8,   17 }, -- z
    [0x007b] = {   70,    9,    9,   17 }, -- {
    [0x007c] = {   79,    9,    8,   17 }, -- |
    [0x007d] = {   87,    9,    9,   17 }, -- }
    [0x007e] = {   96,    9,   11,   17 }, -- ~
}
gfx_font_define(`VerdanaBold13`, `font_verdanab13.png`, 17, codepoints)
