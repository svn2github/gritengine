local codepoints = {
    [0x0020] = {    0,  107,    6,   21 }, --  
    [0x0021] = {    6,  107,    6,   21 }, -- !
    [0x0022] = {   12,  107,    7,   21 }, -- "
    [0x0023] = {   19,  107,   13,   21 }, -- #
    [0x0024] = {   32,  107,   10,   21 }, -- $
    [0x0025] = {   42,  107,   17,   21 }, -- %
    [0x0026] = {   59,  107,   12,   21 }, -- &
    [0x0027] = {   71,  107,    4,   21 }, -- '
    [0x0028] = {   75,  107,    7,   21 }, -- (
    [0x0029] = {   82,  107,    7,   21 }, -- )
    [0x002a] = {   89,  107,   10,   21 }, -- *
    [0x002b] = {   99,  107,   13,   21 }, -- +
    [0x002c] = {  112,  107,    6,   21 }, -- ,
    [0x002d] = {  118,  107,    7,   21 }, -- -
    [0x002e] = {  125,  107,    6,   21 }, -- .
    [0x002f] = {  131,  107,    7,   21 }, -- /
    [0x0030] = {  138,  107,   10,   21 }, -- 0
    [0x0031] = {  148,  107,   10,   21 }, -- 1
    [0x0032] = {  158,  107,   10,   21 }, -- 2
    [0x0033] = {  168,  107,   10,   21 }, -- 3
    [0x0034] = {  178,  107,   10,   21 }, -- 4
    [0x0035] = {  188,  107,   10,   21 }, -- 5
    [0x0036] = {  198,  107,   10,   21 }, -- 6
    [0x0037] = {  208,  107,   10,   21 }, -- 7
    [0x0038] = {  218,  107,   10,   21 }, -- 8
    [0x0039] = {  228,  107,   10,   21 }, -- 9
    [0x003a] = {  238,  107,    7,   21 }, -- :
    [0x003b] = {  245,  107,    7,   21 }, -- ;
    [0x003c] = {    0,   86,   13,   21 }, -- <
    [0x003d] = {   13,   86,   13,   21 }, -- =
    [0x003e] = {   26,   86,   13,   21 }, -- >
    [0x003f] = {   39,   86,    9,   21 }, -- ?
    [0x0040] = {   48,   86,   16,   21 }, -- @
    [0x0041] = {   64,   86,   11,   21 }, -- A
    [0x0042] = {   75,   86,   11,   21 }, -- B
    [0x0043] = {   86,   86,   11,   21 }, -- C
    [0x0044] = {   97,   86,   12,   21 }, -- D
    [0x0045] = {  109,   86,   10,   21 }, -- E
    [0x0046] = {  119,   86,    9,   21 }, -- F
    [0x0047] = {  128,   86,   12,   21 }, -- G
    [0x0048] = {  140,   86,   12,   21 }, -- H
    [0x0049] = {  152,   86,    7,   21 }, -- I
    [0x004a] = {  159,   86,    7,   21 }, -- J
    [0x004b] = {  166,   86,   11,   21 }, -- K
    [0x004c] = {  177,   86,    9,   21 }, -- L
    [0x004d] = {  186,   86,   13,   21 }, -- M
    [0x004e] = {  199,   86,   12,   21 }, -- N
    [0x004f] = {  211,   86,   13,   21 }, -- O
    [0x0050] = {  224,   86,   10,   21 }, -- P
    [0x0051] = {  234,   86,   13,   21 }, -- Q
    [0x0052] = {    0,   65,   11,   21 }, -- R
    [0x0053] = {   11,   65,   10,   21 }, -- S
    [0x0054] = {   21,   65,   10,   21 }, -- T
    [0x0055] = {   31,   65,   12,   21 }, -- U
    [0x0056] = {   43,   65,   11,   21 }, -- V
    [0x0057] = {   54,   65,   17,   21 }, -- W
    [0x0058] = {   71,   65,   11,   21 }, -- X
    [0x0059] = {   82,   65,   11,   21 }, -- Y
    [0x005a] = {   93,   65,   11,   21 }, -- Z
    [0x005b] = {  104,   65,    7,   21 }, -- [
    [0x005c] = {  111,   65,    7,   21 }, -- \
    [0x005d] = {  118,   65,    7,   21 }, -- ]
    [0x005e] = {  125,   65,   13,   21 }, -- ^
    [0x005f] = {  138,   65,   10,   21 }, -- _
    [0x0060] = {  148,   65,   10,   21 }, -- `
    [0x0061] = {  158,   65,   10,   21 }, -- a
    [0x0062] = {  168,   65,   10,   21 }, -- b
    [0x0063] = {  178,   65,    8,   21 }, -- c
    [0x0064] = {  186,   65,   10,   21 }, -- d
    [0x0065] = {  196,   65,   10,   21 }, -- e
    [0x0066] = {  206,   65,    6,   21 }, -- f
    [0x0067] = {  212,   65,   10,   21 }, -- g
    [0x0068] = {  222,   65,   10,   21 }, -- h
    [0x0069] = {  232,   65,    5,   21 }, -- i
    [0x006a] = {  237,   65,    6,   21 }, -- j
    [0x006b] = {  243,   65,    9,   21 }, -- k
    [0x006c] = {    0,   44,    5,   21 }, -- l
    [0x006d] = {    5,   44,   15,   21 }, -- m
    [0x006e] = {   20,   44,   10,   21 }, -- n
    [0x006f] = {   30,   44,   10,   21 }, -- o
    [0x0070] = {   40,   44,   10,   21 }, -- p
    [0x0071] = {   50,   44,   10,   21 }, -- q
    [0x0072] = {   60,   44,    6,   21 }, -- r
    [0x0073] = {   66,   44,    9,   21 }, -- s
    [0x0074] = {   75,   44,    7,   21 }, -- t
    [0x0075] = {   82,   44,   10,   21 }, -- u
    [0x0076] = {   92,   44,    9,   21 }, -- v
    [0x0077] = {  101,   44,   13,   21 }, -- w
    [0x0078] = {  114,   44,    9,   21 }, -- x
    [0x0079] = {  123,   44,    9,   21 }, -- y
    [0x007a] = {  132,   44,    9,   21 }, -- z
    [0x007b] = {  141,   44,   10,   21 }, -- {
    [0x007c] = {  151,   44,    7,   21 }, -- |
    [0x007d] = {  158,   44,   10,   21 }, -- }
    [0x007e] = {  168,   44,   13,   21 }, -- ~
}
gfx_font_define(`Verdana16`, `font_verdana16.png`, 21, codepoints)