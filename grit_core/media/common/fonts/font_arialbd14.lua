local codepoints = {
    [0x0020] = {    0,  112,    4,   16 }, --  
    [0x0021] = {    4,  112,    4,   16 }, -- !
    [0x0022] = {    8,  112,    7,   16 }, -- "
    [0x0023] = {   15,  112,    8,   16 }, -- #
    [0x0024] = {   23,  112,    8,   16 }, -- $
    [0x0025] = {   31,  112,   10,   16 }, -- %
    [0x0026] = {   41,  112,   10,   16 }, -- &
    [0x0027] = {   51,  112,    3,   16 }, -- '
    [0x0028] = {   54,  112,    5,   16 }, -- (
    [0x0029] = {   59,  112,    5,   16 }, -- )
    [0x002a] = {   64,  112,    5,   16 }, -- *
    [0x002b] = {   69,  112,    8,   16 }, -- +
    [0x002c] = {   77,  112,    4,   16 }, -- ,
    [0x002d] = {   81,  112,    5,   16 }, -- -
    [0x002e] = {   86,  112,    4,   16 }, -- .
    [0x002f] = {   90,  112,    4,   16 }, -- /
    [0x0030] = {   94,  112,    8,   16 }, -- 0
    [0x0031] = {  102,  112,    8,   16 }, -- 1
    [0x0032] = {  110,  112,    8,   16 }, -- 2
    [0x0033] = {  118,  112,    8,   16 }, -- 3
    [0x0034] = {    0,   96,    8,   16 }, -- 4
    [0x0035] = {    8,   96,    8,   16 }, -- 5
    [0x0036] = {   16,   96,    8,   16 }, -- 6
    [0x0037] = {   24,   96,    8,   16 }, -- 7
    [0x0038] = {   32,   96,    8,   16 }, -- 8
    [0x0039] = {   40,   96,    8,   16 }, -- 9
    [0x003a] = {   48,   96,    4,   16 }, -- :
    [0x003b] = {   52,   96,    4,   16 }, -- ;
    [0x003c] = {   56,   96,    8,   16 }, -- <
    [0x003d] = {   64,   96,    8,   16 }, -- =
    [0x003e] = {   72,   96,    8,   16 }, -- >
    [0x003f] = {   80,   96,    9,   16 }, -- ?
    [0x0040] = {   89,   96,   14,   16 }, -- @
    [0x0041] = {  103,   96,    9,   16 }, -- A
    [0x0042] = {  112,   96,   10,   16 }, -- B
    [0x0043] = {    0,   80,   10,   16 }, -- C
    [0x0044] = {   10,   80,   10,   16 }, -- D
    [0x0045] = {   20,   80,    9,   16 }, -- E
    [0x0046] = {   29,   80,    9,   16 }, -- F
    [0x0047] = {   38,   80,   11,   16 }, -- G
    [0x0048] = {   49,   80,   10,   16 }, -- H
    [0x0049] = {   59,   80,    4,   16 }, -- I
    [0x004a] = {   63,   80,    8,   16 }, -- J
    [0x004b] = {   71,   80,   10,   16 }, -- K
    [0x004c] = {   81,   80,    8,   16 }, -- L
    [0x004d] = {   89,   80,   13,   16 }, -- M
    [0x004e] = {  102,   80,   10,   16 }, -- N
    [0x004f] = {  112,   80,   11,   16 }, -- O
    [0x0050] = {    0,   64,    9,   16 }, -- P
    [0x0051] = {    9,   64,   11,   16 }, -- Q
    [0x0052] = {   20,   64,   10,   16 }, -- R
    [0x0053] = {   30,   64,    9,   16 }, -- S
    [0x0054] = {   39,   64,    8,   16 }, -- T
    [0x0055] = {   47,   64,   10,   16 }, -- U
    [0x0056] = {   57,   64,    9,   16 }, -- V
    [0x0057] = {   66,   64,   13,   16 }, -- W
    [0x0058] = {   79,   64,    9,   16 }, -- X
    [0x0059] = {   88,   64,   10,   16 }, -- Y
    [0x005a] = {   98,   64,    8,   16 }, -- Z
    [0x005b] = {  106,   64,    5,   16 }, -- [
    [0x005c] = {  111,   64,    4,   16 }, -- \
    [0x005d] = {  115,   64,    5,   16 }, -- ]
    [0x005e] = {    0,   48,    8,   16 }, -- ^
    [0x005f] = {    8,   48,    8,   16 }, -- _
    [0x0060] = {   16,   48,    5,   16 }, -- `
    [0x0061] = {   21,   48,    8,   16 }, -- a
    [0x0062] = {   29,   48,    9,   16 }, -- b
    [0x0063] = {   38,   48,    8,   16 }, -- c
    [0x0064] = {   46,   48,    9,   16 }, -- d
    [0x0065] = {   55,   48,    9,   16 }, -- e
    [0x0066] = {   64,   48,    5,   16 }, -- f
    [0x0067] = {   69,   48,    9,   16 }, -- g
    [0x0068] = {   78,   48,    9,   16 }, -- h
    [0x0069] = {   87,   48,    4,   16 }, -- i
    [0x006a] = {   91,   48,    4,   16 }, -- j
    [0x006b] = {   95,   48,    8,   16 }, -- k
    [0x006c] = {  103,   48,    4,   16 }, -- l
    [0x006d] = {  107,   48,   12,   16 }, -- m
    [0x006e] = {    0,   32,    9,   16 }, -- n
    [0x006f] = {    9,   32,    9,   16 }, -- o
    [0x0070] = {   18,   32,    9,   16 }, -- p
    [0x0071] = {   27,   32,    9,   16 }, -- q
    [0x0072] = {   36,   32,    6,   16 }, -- r
    [0x0073] = {   42,   32,    8,   16 }, -- s
    [0x0074] = {   50,   32,    5,   16 }, -- t
    [0x0075] = {   55,   32,    9,   16 }, -- u
    [0x0076] = {   64,   32,    9,   16 }, -- v
    [0x0077] = {   73,   32,   11,   16 }, -- w
    [0x0078] = {   84,   32,    8,   16 }, -- x
    [0x0079] = {   92,   32,    7,   16 }, -- y
    [0x007a] = {   99,   32,    7,   16 }, -- z
    [0x007b] = {  106,   32,    5,   16 }, -- {
    [0x007c] = {  111,   32,    3,   16 }, -- |
    [0x007d] = {  114,   32,    5,   16 }, -- }
    [0x007e] = {  119,   32,    8,   16 }, -- ~
}
gfx_font_define(`ArialBold14`, `font_arialbd14.png`, 16, codepoints)
