local codepoints = {
    [0x0020] = {    0,  113,    4,   15 }, --  
    [0x0021] = {    4,  113,    3,   15 }, -- !
    [0x0022] = {    7,  113,    5,   15 }, -- "
    [0x0023] = {   12,  113,    7,   15 }, -- #
    [0x0024] = {   19,  113,    7,   15 }, -- $
    [0x0025] = {   26,  113,   12,   15 }, -- %
    [0x0026] = {   38,  113,    9,   15 }, -- &
    [0x0027] = {   47,  113,    2,   15 }, -- '
    [0x0028] = {   49,  113,    4,   15 }, -- (
    [0x0029] = {   53,  113,    4,   15 }, -- )
    [0x002a] = {   57,  113,    5,   15 }, -- *
    [0x002b] = {   62,  113,    8,   15 }, -- +
    [0x002c] = {   70,  113,    4,   15 }, -- ,
    [0x002d] = {   74,  113,    4,   15 }, -- -
    [0x002e] = {   78,  113,    4,   15 }, -- .
    [0x002f] = {   82,  113,    4,   15 }, -- /
    [0x0030] = {   86,  113,    7,   15 }, -- 0
    [0x0031] = {   93,  113,    7,   15 }, -- 1
    [0x0032] = {  100,  113,    7,   15 }, -- 2
    [0x0033] = {  107,  113,    7,   15 }, -- 3
    [0x0034] = {  114,  113,    7,   15 }, -- 4
    [0x0035] = {    0,   98,    7,   15 }, -- 5
    [0x0036] = {    7,   98,    7,   15 }, -- 6
    [0x0037] = {   14,   98,    7,   15 }, -- 7
    [0x0038] = {   21,   98,    7,   15 }, -- 8
    [0x0039] = {   28,   98,    7,   15 }, -- 9
    [0x003a] = {   35,   98,    4,   15 }, -- :
    [0x003b] = {   39,   98,    4,   15 }, -- ;
    [0x003c] = {   43,   98,    8,   15 }, -- <
    [0x003d] = {   51,   98,    8,   15 }, -- =
    [0x003e] = {   59,   98,    8,   15 }, -- >
    [0x003f] = {   67,   98,    7,   15 }, -- ?
    [0x0040] = {   74,   98,   13,   15 }, -- @
    [0x0041] = {   87,   98,    9,   15 }, -- A
    [0x0042] = {   96,   98,    9,   15 }, -- B
    [0x0043] = {  105,   98,    9,   15 }, -- C
    [0x0044] = {  114,   98,    9,   15 }, -- D
    [0x0045] = {    0,   83,    9,   15 }, -- E
    [0x0046] = {    9,   83,    8,   15 }, -- F
    [0x0047] = {   17,   83,   10,   15 }, -- G
    [0x0048] = {   27,   83,    9,   15 }, -- H
    [0x0049] = {   36,   83,    3,   15 }, -- I
    [0x004a] = {   39,   83,    6,   15 }, -- J
    [0x004b] = {   45,   83,    9,   15 }, -- K
    [0x004c] = {   54,   83,    7,   15 }, -- L
    [0x004d] = {   61,   83,   11,   15 }, -- M
    [0x004e] = {   72,   83,    9,   15 }, -- N
    [0x004f] = {   81,   83,   10,   15 }, -- O
    [0x0050] = {   91,   83,    9,   15 }, -- P
    [0x0051] = {  100,   83,   10,   15 }, -- Q
    [0x0052] = {  110,   83,    9,   15 }, -- R
    [0x0053] = {    0,   68,    9,   15 }, -- S
    [0x0054] = {    9,   68,    7,   15 }, -- T
    [0x0055] = {   16,   68,    9,   15 }, -- U
    [0x0056] = {   25,   68,    9,   15 }, -- V
    [0x0057] = {   34,   68,   13,   15 }, -- W
    [0x0058] = {   47,   68,    7,   15 }, -- X
    [0x0059] = {   54,   68,    9,   15 }, -- Y
    [0x005a] = {   63,   68,    7,   15 }, -- Z
    [0x005b] = {   70,   68,    4,   15 }, -- [
    [0x005c] = {   74,   68,    4,   15 }, -- \
    [0x005d] = {   78,   68,    4,   15 }, -- ]
    [0x005e] = {   82,   68,    5,   15 }, -- ^
    [0x005f] = {   87,   68,    7,   15 }, -- _
    [0x0060] = {   94,   68,    4,   15 }, -- `
    [0x0061] = {   98,   68,    7,   15 }, -- a
    [0x0062] = {  105,   68,    7,   15 }, -- b
    [0x0063] = {  112,   68,    7,   15 }, -- c
    [0x0064] = {  119,   68,    7,   15 }, -- d
    [0x0065] = {    0,   53,    7,   15 }, -- e
    [0x0066] = {    7,   53,    3,   15 }, -- f
    [0x0067] = {   10,   53,    7,   15 }, -- g
    [0x0068] = {   17,   53,    7,   15 }, -- h
    [0x0069] = {   24,   53,    3,   15 }, -- i
    [0x006a] = {   27,   53,    3,   15 }, -- j
    [0x006b] = {   30,   53,    7,   15 }, -- k
    [0x006c] = {   37,   53,    3,   15 }, -- l
    [0x006d] = {   40,   53,   11,   15 }, -- m
    [0x006e] = {   51,   53,    7,   15 }, -- n
    [0x006f] = {   58,   53,    7,   15 }, -- o
    [0x0070] = {   65,   53,    7,   15 }, -- p
    [0x0071] = {   72,   53,    7,   15 }, -- q
    [0x0072] = {   79,   53,    4,   15 }, -- r
    [0x0073] = {   83,   53,    7,   15 }, -- s
    [0x0074] = {   90,   53,    4,   15 }, -- t
    [0x0075] = {   94,   53,    7,   15 }, -- u
    [0x0076] = {  101,   53,    5,   15 }, -- v
    [0x0077] = {  106,   53,    9,   15 }, -- w
    [0x0078] = {  115,   53,    7,   15 }, -- x
    [0x0079] = {    0,   38,    7,   15 }, -- y
    [0x007a] = {    7,   38,    7,   15 }, -- z
    [0x007b] = {   14,   38,    4,   15 }, -- {
    [0x007c] = {   18,   38,    3,   15 }, -- |
    [0x007d] = {   21,   38,    4,   15 }, -- }
    [0x007e] = {   25,   38,    8,   15 }, -- ~
}
gfx_font_define(`Arial13`, `font_arial13.png`, 15, codepoints)