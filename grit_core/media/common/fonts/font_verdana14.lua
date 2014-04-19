local codepoints = {
    [0x0020] = {    0,  110,    5,   18 }, --  
    [0x0021] = {    5,  110,    6,   18 }, -- !
    [0x0022] = {   11,  110,    6,   18 }, -- "
    [0x0023] = {   17,  110,   11,   18 }, -- #
    [0x0024] = {   28,  110,    9,   18 }, -- $
    [0x0025] = {   37,  110,   15,   18 }, -- %
    [0x0026] = {   52,  110,   10,   18 }, -- &
    [0x0027] = {   62,  110,    4,   18 }, -- '
    [0x0028] = {   66,  110,    6,   18 }, -- (
    [0x0029] = {   72,  110,    6,   18 }, -- )
    [0x002a] = {   78,  110,    9,   18 }, -- *
    [0x002b] = {   87,  110,   11,   18 }, -- +
    [0x002c] = {   98,  110,    5,   18 }, -- ,
    [0x002d] = {  103,  110,    7,   18 }, -- -
    [0x002e] = {  110,  110,    5,   18 }, -- .
    [0x002f] = {  115,  110,    6,   18 }, -- /
    [0x0030] = {    0,   92,    9,   18 }, -- 0
    [0x0031] = {    9,   92,    9,   18 }, -- 1
    [0x0032] = {   18,   92,    9,   18 }, -- 2
    [0x0033] = {   27,   92,    9,   18 }, -- 3
    [0x0034] = {   36,   92,    9,   18 }, -- 4
    [0x0035] = {   45,   92,    9,   18 }, -- 5
    [0x0036] = {   54,   92,    9,   18 }, -- 6
    [0x0037] = {   63,   92,    9,   18 }, -- 7
    [0x0038] = {   72,   92,    9,   18 }, -- 8
    [0x0039] = {   81,   92,    9,   18 }, -- 9
    [0x003a] = {   90,   92,    6,   18 }, -- :
    [0x003b] = {   96,   92,    6,   18 }, -- ;
    [0x003c] = {  102,   92,   11,   18 }, -- <
    [0x003d] = {  113,   92,   11,   18 }, -- =
    [0x003e] = {    0,   74,   11,   18 }, -- >
    [0x003f] = {   11,   74,    8,   18 }, -- ?
    [0x0040] = {   19,   74,   14,   18 }, -- @
    [0x0041] = {   33,   74,   10,   18 }, -- A
    [0x0042] = {   43,   74,   10,   18 }, -- B
    [0x0043] = {   53,   74,   10,   18 }, -- C
    [0x0044] = {   63,   74,   11,   18 }, -- D
    [0x0045] = {   74,   74,    9,   18 }, -- E
    [0x0046] = {   83,   74,    8,   18 }, -- F
    [0x0047] = {   91,   74,   11,   18 }, -- G
    [0x0048] = {  102,   74,   10,   18 }, -- H
    [0x0049] = {  112,   74,    5,   18 }, -- I
    [0x004a] = {  117,   74,    6,   18 }, -- J
    [0x004b] = {    0,   56,   10,   18 }, -- K
    [0x004c] = {   10,   56,    8,   18 }, -- L
    [0x004d] = {   18,   56,   11,   18 }, -- M
    [0x004e] = {   29,   56,   10,   18 }, -- N
    [0x004f] = {   39,   56,   11,   18 }, -- O
    [0x0050] = {   50,   56,    8,   18 }, -- P
    [0x0051] = {   58,   56,   11,   18 }, -- Q
    [0x0052] = {   69,   56,   10,   18 }, -- R
    [0x0053] = {   79,   56,   10,   18 }, -- S
    [0x0054] = {   89,   56,    9,   18 }, -- T
    [0x0055] = {   98,   56,   10,   18 }, -- U
    [0x0056] = {  108,   56,   10,   18 }, -- V
    [0x0057] = {    0,   38,   15,   18 }, -- W
    [0x0058] = {   15,   38,   10,   18 }, -- X
    [0x0059] = {   25,   38,    9,   18 }, -- Y
    [0x005a] = {   34,   38,   10,   18 }, -- Z
    [0x005b] = {   44,   38,    6,   18 }, -- [
    [0x005c] = {   50,   38,    6,   18 }, -- \
    [0x005d] = {   56,   38,    6,   18 }, -- ]
    [0x005e] = {   62,   38,   11,   18 }, -- ^
    [0x005f] = {   73,   38,    9,   18 }, -- _
    [0x0060] = {   82,   38,    9,   18 }, -- `
    [0x0061] = {   91,   38,    8,   18 }, -- a
    [0x0062] = {   99,   38,    9,   18 }, -- b
    [0x0063] = {  108,   38,    7,   18 }, -- c
    [0x0064] = {  115,   38,    9,   18 }, -- d
    [0x0065] = {    0,   20,    8,   18 }, -- e
    [0x0066] = {    8,   20,    5,   18 }, -- f
    [0x0067] = {   13,   20,    9,   18 }, -- g
    [0x0068] = {   22,   20,    9,   18 }, -- h
    [0x0069] = {   31,   20,    3,   18 }, -- i
    [0x006a] = {   34,   20,    5,   18 }, -- j
    [0x006b] = {   39,   20,    8,   18 }, -- k
    [0x006c] = {   47,   20,    3,   18 }, -- l
    [0x006d] = {   50,   20,   13,   18 }, -- m
    [0x006e] = {   63,   20,    9,   18 }, -- n
    [0x006f] = {   72,   20,    9,   18 }, -- o
    [0x0070] = {   81,   20,    9,   18 }, -- p
    [0x0071] = {   90,   20,    9,   18 }, -- q
    [0x0072] = {   99,   20,    6,   18 }, -- r
    [0x0073] = {  105,   20,    8,   18 }, -- s
    [0x0074] = {  113,   20,    6,   18 }, -- t
    [0x0075] = {    0,    2,    9,   18 }, -- u
    [0x0076] = {    9,    2,    8,   18 }, -- v
    [0x0077] = {   17,    2,   11,   18 }, -- w
    [0x0078] = {   28,    2,    9,   18 }, -- x
    [0x0079] = {   37,    2,    8,   18 }, -- y
    [0x007a] = {   45,    2,    8,   18 }, -- z
    [0x007b] = {   53,    2,    9,   18 }, -- {
    [0x007c] = {   62,    2,    6,   18 }, -- |
    [0x007d] = {   68,    2,    9,   18 }, -- }
    [0x007e] = {   77,    2,   11,   18 }, -- ~
}
gfx_font_define(`Verdana14`, `font_verdana14.png`, 18, codepoints)
