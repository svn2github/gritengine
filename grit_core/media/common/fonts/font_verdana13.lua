local codepoints = {
    [0x0020] = {    0,  111,    5,   17 }, --  
    [0x0021] = {    5,  111,    5,   17 }, -- !
    [0x0022] = {   10,  111,    5,   17 }, -- "
    [0x0023] = {   15,  111,   10,   17 }, -- #
    [0x0024] = {   25,  111,    8,   17 }, -- $
    [0x0025] = {   33,  111,   13,   17 }, -- %
    [0x0026] = {   46,  111,    9,   17 }, -- &
    [0x0027] = {   55,  111,    3,   17 }, -- '
    [0x0028] = {   58,  111,    6,   17 }, -- (
    [0x0029] = {   64,  111,    6,   17 }, -- )
    [0x002a] = {   70,  111,    9,   17 }, -- *
    [0x002b] = {   79,  111,    9,   17 }, -- +
    [0x002c] = {   88,  111,    5,   17 }, -- ,
    [0x002d] = {   93,  111,    7,   17 }, -- -
    [0x002e] = {  100,  111,    5,   17 }, -- .
    [0x002f] = {  105,  111,    6,   17 }, -- /
    [0x0030] = {  111,  111,    8,   17 }, -- 0
    [0x0031] = {  119,  111,    8,   17 }, -- 1
    [0x0032] = {    0,   94,    8,   17 }, -- 2
    [0x0033] = {    8,   94,    8,   17 }, -- 3
    [0x0034] = {   16,   94,    8,   17 }, -- 4
    [0x0035] = {   24,   94,    8,   17 }, -- 5
    [0x0036] = {   32,   94,    8,   17 }, -- 6
    [0x0037] = {   40,   94,    8,   17 }, -- 7
    [0x0038] = {   48,   94,    8,   17 }, -- 8
    [0x0039] = {   56,   94,    8,   17 }, -- 9
    [0x003a] = {   64,   94,    6,   17 }, -- :
    [0x003b] = {   70,   94,    6,   17 }, -- ;
    [0x003c] = {   76,   94,    9,   17 }, -- <
    [0x003d] = {   85,   94,    9,   17 }, -- =
    [0x003e] = {   94,   94,    9,   17 }, -- >
    [0x003f] = {  103,   94,    7,   17 }, -- ?
    [0x0040] = {  110,   94,   13,   17 }, -- @
    [0x0041] = {    0,   77,    9,   17 }, -- A
    [0x0042] = {    9,   77,    8,   17 }, -- B
    [0x0043] = {   17,   77,    9,   17 }, -- C
    [0x0044] = {   26,   77,    9,   17 }, -- D
    [0x0045] = {   35,   77,    8,   17 }, -- E
    [0x0046] = {   43,   77,    8,   17 }, -- F
    [0x0047] = {   51,   77,    9,   17 }, -- G
    [0x0048] = {   60,   77,    9,   17 }, -- H
    [0x0049] = {   69,   77,    5,   17 }, -- I
    [0x004a] = {   74,   77,    6,   17 }, -- J
    [0x004b] = {   80,   77,    8,   17 }, -- K
    [0x004c] = {   88,   77,    7,   17 }, -- L
    [0x004d] = {   95,   77,   11,   17 }, -- M
    [0x004e] = {  106,   77,    9,   17 }, -- N
    [0x004f] = {  115,   77,   10,   17 }, -- O
    [0x0050] = {    0,   60,    8,   17 }, -- P
    [0x0051] = {    8,   60,   10,   17 }, -- Q
    [0x0052] = {   18,   60,    8,   17 }, -- R
    [0x0053] = {   26,   60,    9,   17 }, -- S
    [0x0054] = {   35,   60,    9,   17 }, -- T
    [0x0055] = {   44,   60,    9,   17 }, -- U
    [0x0056] = {   53,   60,    9,   17 }, -- V
    [0x0057] = {   62,   60,   13,   17 }, -- W
    [0x0058] = {   75,   60,    9,   17 }, -- X
    [0x0059] = {   84,   60,    9,   17 }, -- Y
    [0x005a] = {   93,   60,    9,   17 }, -- Z
    [0x005b] = {  102,   60,    6,   17 }, -- [
    [0x005c] = {  108,   60,    6,   17 }, -- \
    [0x005d] = {  114,   60,    6,   17 }, -- ]
    [0x005e] = {    0,   43,   11,   17 }, -- ^
    [0x005f] = {   11,   43,    8,   17 }, -- _
    [0x0060] = {   19,   43,    8,   17 }, -- `
    [0x0061] = {   27,   43,    8,   17 }, -- a
    [0x0062] = {   35,   43,    8,   17 }, -- b
    [0x0063] = {   43,   43,    8,   17 }, -- c
    [0x0064] = {   51,   43,    8,   17 }, -- d
    [0x0065] = {   59,   43,    8,   17 }, -- e
    [0x0066] = {   67,   43,    5,   17 }, -- f
    [0x0067] = {   72,   43,    8,   17 }, -- g
    [0x0068] = {   80,   43,    8,   17 }, -- h
    [0x0069] = {   88,   43,    3,   17 }, -- i
    [0x006a] = {   91,   43,    4,   17 }, -- j
    [0x006b] = {   95,   43,    7,   17 }, -- k
    [0x006c] = {  102,   43,    3,   17 }, -- l
    [0x006d] = {  105,   43,   11,   17 }, -- m
    [0x006e] = {  116,   43,    8,   17 }, -- n
    [0x006f] = {    0,   26,    8,   17 }, -- o
    [0x0070] = {    8,   26,    8,   17 }, -- p
    [0x0071] = {   16,   26,    8,   17 }, -- q
    [0x0072] = {   24,   26,    5,   17 }, -- r
    [0x0073] = {   29,   26,    7,   17 }, -- s
    [0x0074] = {   36,   26,    6,   17 }, -- t
    [0x0075] = {   42,   26,    8,   17 }, -- u
    [0x0076] = {   50,   26,    8,   17 }, -- v
    [0x0077] = {   58,   26,   11,   17 }, -- w
    [0x0078] = {   69,   26,    7,   17 }, -- x
    [0x0079] = {   76,   26,    8,   17 }, -- y
    [0x007a] = {   84,   26,    7,   17 }, -- z
    [0x007b] = {   91,   26,    8,   17 }, -- {
    [0x007c] = {   99,   26,    7,   17 }, -- |
    [0x007d] = {  106,   26,    8,   17 }, -- }
    [0x007e] = {  114,   26,   11,   17 }, -- ~
}
gfx_font_define("Verdana13", "font_verdana13.png", 17, codepoints)