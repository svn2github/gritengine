local codepoints = {
    [0x0020] = {    0,  111,    2,   17 }, --  
    [0x0021] = {    2,  111,    4,   17 }, -- !
    [0x0022] = {    6,  111,    5,   17 }, -- "
    [0x0023] = {   11,  111,    8,   17 }, -- #
    [0x0024] = {   19,  111,    7,   17 }, -- $
    [0x0025] = {   26,  111,    9,   17 }, -- %
    [0x0026] = {   35,  111,    7,   17 }, -- &
    [0x0027] = {   42,  111,    2,   17 }, -- '
    [0x0028] = {   44,  111,    4,   17 }, -- (
    [0x0029] = {   48,  111,    4,   17 }, -- )
    [0x002a] = {   52,  111,    4,   17 }, -- *
    [0x002b] = {   56,  111,    7,   17 }, -- +
    [0x002c] = {   63,  111,    2,   17 }, -- ,
    [0x002d] = {   65,  111,    4,   17 }, -- -
    [0x002e] = {   69,  111,    2,   17 }, -- .
    [0x002f] = {   71,  111,    5,   17 }, -- /
    [0x0030] = {   76,  111,    7,   17 }, -- 0
    [0x0031] = {   83,  111,    5,   17 }, -- 1
    [0x0032] = {   88,  111,    7,   17 }, -- 2
    [0x0033] = {   95,  111,    7,   17 }, -- 3
    [0x0034] = {  102,  111,    7,   17 }, -- 4
    [0x0035] = {  109,  111,    7,   17 }, -- 5
    [0x0036] = {  116,  111,    7,   17 }, -- 6
    [0x0037] = {  123,  111,    5,   17 }, -- 7
    [0x0038] = {  128,  111,    7,   17 }, -- 8
    [0x0039] = {  135,  111,    7,   17 }, -- 9
    [0x003a] = {  142,  111,    3,   17 }, -- :
    [0x003b] = {  145,  111,    3,   17 }, -- ;
    [0x003c] = {  148,  111,    7,   17 }, -- <
    [0x003d] = {  155,  111,    7,   17 }, -- =
    [0x003e] = {  162,  111,    7,   17 }, -- >
    [0x003f] = {  169,  111,    7,   17 }, -- ?
    [0x0040] = {  176,  111,   10,   17 }, -- @
    [0x0041] = {  186,  111,    7,   17 }, -- A
    [0x0042] = {  193,  111,    7,   17 }, -- B
    [0x0043] = {  200,  111,    7,   17 }, -- C
    [0x0044] = {  207,  111,    7,   17 }, -- D
    [0x0045] = {  214,  111,    5,   17 }, -- E
    [0x0046] = {  219,  111,    5,   17 }, -- F
    [0x0047] = {  224,  111,    7,   17 }, -- G
    [0x0048] = {  231,  111,    7,   17 }, -- H
    [0x0049] = {  238,  111,    4,   17 }, -- I
    [0x004a] = {  242,  111,    4,   17 }, -- J
    [0x004b] = {  246,  111,    7,   17 }, -- K
    [0x004c] = {  253,  111,    5,   17 }, -- L
    [0x004d] = {  258,  111,    9,   17 }, -- M
    [0x004e] = {  267,  111,    7,   17 }, -- N
    [0x004f] = {  274,  111,    7,   17 }, -- O
    [0x0050] = {  281,  111,    7,   17 }, -- P
    [0x0051] = {  288,  111,    7,   17 }, -- Q
    [0x0052] = {  295,  111,    7,   17 }, -- R
    [0x0053] = {  302,  111,    7,   17 }, -- S
    [0x0054] = {  309,  111,    6,   17 }, -- T
    [0x0055] = {  315,  111,    7,   17 }, -- U
    [0x0056] = {  322,  111,    7,   17 }, -- V
    [0x0057] = {  329,  111,   11,   17 }, -- W
    [0x0058] = {  340,  111,    5,   17 }, -- X
    [0x0059] = {  345,  111,    6,   17 }, -- Y
    [0x005a] = {  351,  111,    5,   17 }, -- Z
    [0x005b] = {  356,  111,    4,   17 }, -- [
    [0x005c] = {  360,  111,    5,   17 }, -- \
    [0x005d] = {  365,  111,    4,   17 }, -- ]
    [0x005e] = {  369,  111,    6,   17 }, -- ^
    [0x005f] = {  375,  111,    7,   17 }, -- _
    [0x0060] = {  382,  111,    4,   17 }, -- `
    [0x0061] = {  386,  111,    7,   17 }, -- a
    [0x0062] = {  393,  111,    7,   17 }, -- b
    [0x0063] = {  400,  111,    6,   17 }, -- c
    [0x0064] = {  406,  111,    7,   17 }, -- d
    [0x0065] = {  413,  111,    7,   17 }, -- e
    [0x0066] = {  420,  111,    4,   17 }, -- f
    [0x0067] = {  424,  111,    7,   17 }, -- g
    [0x0068] = {  431,  111,    7,   17 }, -- h
    [0x0069] = {  438,  111,    4,   17 }, -- i
    [0x006a] = {  442,  111,    4,   17 }, -- j
    [0x006b] = {  446,  111,    6,   17 }, -- k
    [0x006c] = {  452,  111,    4,   17 }, -- l
    [0x006d] = {  456,  111,   10,   17 }, -- m
    [0x006e] = {  466,  111,    7,   17 }, -- n
    [0x006f] = {  473,  111,    7,   17 }, -- o
    [0x0070] = {  480,  111,    7,   17 }, -- p
    [0x0071] = {  487,  111,    7,   17 }, -- q
    [0x0072] = {  494,  111,    5,   17 }, -- r
    [0x0073] = {  499,  111,    6,   17 }, -- s
    [0x0074] = {  505,  111,    4,   17 }, -- t
    [0x0075] = {    0,   94,    7,   17 }, -- u
    [0x0076] = {    7,   94,    5,   17 }, -- v
    [0x0077] = {   12,   94,    9,   17 }, -- w
    [0x0078] = {   21,   94,    5,   17 }, -- x
    [0x0079] = {   26,   94,    6,   17 }, -- y
    [0x007a] = {   32,   94,    5,   17 }, -- z
    [0x007b] = {   37,   94,    5,   17 }, -- {
    [0x007c] = {   42,   94,    4,   17 }, -- |
    [0x007d] = {   46,   94,    5,   17 }, -- }
    [0x007e] = {   51,   94,    7,   17 }, -- ~
}
gfx_font_define(`Impact13`, `font_impact13.png`, 17, codepoints)
