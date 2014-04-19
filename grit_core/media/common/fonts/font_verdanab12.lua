local codepoints = {
    [0x0020] = {    0,  112,    4,   16 }, --  
    [0x0021] = {    4,  112,    5,   16 }, -- !
    [0x0022] = {    9,  112,    7,   16 }, -- "
    [0x0023] = {   16,  112,   10,   16 }, -- #
    [0x0024] = {   26,  112,    9,   16 }, -- $
    [0x0025] = {   35,  112,   15,   16 }, -- %
    [0x0026] = {   50,  112,   10,   16 }, -- &
    [0x0027] = {   60,  112,    4,   16 }, -- '
    [0x0028] = {   64,  112,    7,   16 }, -- (
    [0x0029] = {   71,  112,    7,   16 }, -- )
    [0x002a] = {   78,  112,    9,   16 }, -- *
    [0x002b] = {   87,  112,   10,   16 }, -- +
    [0x002c] = {   97,  112,    4,   16 }, -- ,
    [0x002d] = {  101,  112,    6,   16 }, -- -
    [0x002e] = {  107,  112,    4,   16 }, -- .
    [0x002f] = {  111,  112,    8,   16 }, -- /
    [0x0030] = {    0,   96,    9,   16 }, -- 0
    [0x0031] = {    9,   96,    9,   16 }, -- 1
    [0x0032] = {   18,   96,    9,   16 }, -- 2
    [0x0033] = {   27,   96,    9,   16 }, -- 3
    [0x0034] = {   36,   96,    9,   16 }, -- 4
    [0x0035] = {   45,   96,    9,   16 }, -- 5
    [0x0036] = {   54,   96,    9,   16 }, -- 6
    [0x0037] = {   63,   96,    9,   16 }, -- 7
    [0x0038] = {   72,   96,    9,   16 }, -- 8
    [0x0039] = {   81,   96,    9,   16 }, -- 9
    [0x003a] = {   90,   96,    5,   16 }, -- :
    [0x003b] = {   95,   96,    5,   16 }, -- ;
    [0x003c] = {  100,   96,   10,   16 }, -- <
    [0x003d] = {  110,   96,   10,   16 }, -- =
    [0x003e] = {    0,   80,   10,   16 }, -- >
    [0x003f] = {   10,   80,    7,   16 }, -- ?
    [0x0040] = {   17,   80,   12,   16 }, -- @
    [0x0041] = {   29,   80,    9,   16 }, -- A
    [0x0042] = {   38,   80,    9,   16 }, -- B
    [0x0043] = {   47,   80,    9,   16 }, -- C
    [0x0044] = {   56,   80,   10,   16 }, -- D
    [0x0045] = {   66,   80,    8,   16 }, -- E
    [0x0046] = {   74,   80,    8,   16 }, -- F
    [0x0047] = {   82,   80,   10,   16 }, -- G
    [0x0048] = {   92,   80,   10,   16 }, -- H
    [0x0049] = {  102,   80,    6,   16 }, -- I
    [0x004a] = {  108,   80,    7,   16 }, -- J
    [0x004b] = {  115,   80,    9,   16 }, -- K
    [0x004c] = {    0,   64,    8,   16 }, -- L
    [0x004d] = {    8,   64,   11,   16 }, -- M
    [0x004e] = {   19,   64,   10,   16 }, -- N
    [0x004f] = {   29,   64,   11,   16 }, -- O
    [0x0050] = {   40,   64,    9,   16 }, -- P
    [0x0051] = {   49,   64,   11,   16 }, -- Q
    [0x0052] = {   60,   64,    9,   16 }, -- R
    [0x0053] = {   69,   64,    9,   16 }, -- S
    [0x0054] = {   78,   64,    8,   16 }, -- T
    [0x0055] = {   86,   64,   10,   16 }, -- U
    [0x0056] = {   96,   64,    9,   16 }, -- V
    [0x0057] = {  105,   64,   14,   16 }, -- W
    [0x0058] = {    0,   48,    9,   16 }, -- X
    [0x0059] = {    9,   48,   10,   16 }, -- Y
    [0x005a] = {   19,   48,    8,   16 }, -- Z
    [0x005b] = {   27,   48,    6,   16 }, -- [
    [0x005c] = {   33,   48,    8,   16 }, -- \
    [0x005d] = {   41,   48,    6,   16 }, -- ]
    [0x005e] = {   47,   48,   10,   16 }, -- ^
    [0x005f] = {   57,   48,    9,   16 }, -- _
    [0x0060] = {   66,   48,    9,   16 }, -- `
    [0x0061] = {   75,   48,    8,   16 }, -- a
    [0x0062] = {   83,   48,    8,   16 }, -- b
    [0x0063] = {   91,   48,    7,   16 }, -- c
    [0x0064] = {   98,   48,    8,   16 }, -- d
    [0x0065] = {  106,   48,    8,   16 }, -- e
    [0x0066] = {  114,   48,    5,   16 }, -- f
    [0x0067] = {  119,   48,    8,   16 }, -- g
    [0x0068] = {    0,   32,    8,   16 }, -- h
    [0x0069] = {    8,   32,    4,   16 }, -- i
    [0x006a] = {   12,   32,    5,   16 }, -- j
    [0x006b] = {   17,   32,    8,   16 }, -- k
    [0x006c] = {   25,   32,    4,   16 }, -- l
    [0x006d] = {   29,   32,   12,   16 }, -- m
    [0x006e] = {   41,   32,    8,   16 }, -- n
    [0x006f] = {   49,   32,    8,   16 }, -- o
    [0x0070] = {   57,   32,    8,   16 }, -- p
    [0x0071] = {   65,   32,    8,   16 }, -- q
    [0x0072] = {   73,   32,    6,   16 }, -- r
    [0x0073] = {   79,   32,    7,   16 }, -- s
    [0x0074] = {   86,   32,    5,   16 }, -- t
    [0x0075] = {   91,   32,    8,   16 }, -- u
    [0x0076] = {   99,   32,    8,   16 }, -- v
    [0x0077] = {  107,   32,   12,   16 }, -- w
    [0x0078] = {  119,   32,    8,   16 }, -- x
    [0x0079] = {    0,   16,    8,   16 }, -- y
    [0x007a] = {    8,   16,    7,   16 }, -- z
    [0x007b] = {   15,   16,    9,   16 }, -- {
    [0x007c] = {   24,   16,    6,   16 }, -- |
    [0x007d] = {   30,   16,    9,   16 }, -- }
    [0x007e] = {   39,   16,   10,   16 }, -- ~
}
gfx_font_define(`VerdanaBold12`, `font_verdanab12.png`, 16, codepoints)
