local codepoints = {
    [0x0020] = {    0,  100,    7,   28 }, --  
    [0x0021] = {    7,  100,    7,   28 }, -- !
    [0x0022] = {   14,  100,   11,   28 }, -- "
    [0x0023] = {   25,  100,   13,   28 }, -- #
    [0x0024] = {   38,  100,   13,   28 }, -- $
    [0x0025] = {   51,  100,   18,   28 }, -- %
    [0x0026] = {   69,  100,   17,   28 }, -- &
    [0x0027] = {   86,  100,    6,   28 }, -- '
    [0x0028] = {   92,  100,    8,   28 }, -- (
    [0x0029] = {  100,  100,    8,   28 }, -- )
    [0x002a] = {  108,  100,    9,   28 }, -- *
    [0x002b] = {  117,  100,   14,   28 }, -- +
    [0x002c] = {  131,  100,    7,   28 }, -- ,
    [0x002d] = {  138,  100,    8,   28 }, -- -
    [0x002e] = {  146,  100,    7,   28 }, -- .
    [0x002f] = {  153,  100,    7,   28 }, -- /
    [0x0030] = {  160,  100,   13,   28 }, -- 0
    [0x0031] = {  173,  100,   13,   28 }, -- 1
    [0x0032] = {  186,  100,   13,   28 }, -- 2
    [0x0033] = {  199,  100,   13,   28 }, -- 3
    [0x0034] = {  212,  100,   13,   28 }, -- 4
    [0x0035] = {  225,  100,   13,   28 }, -- 5
    [0x0036] = {  238,  100,   13,   28 }, -- 6
    [0x0037] = {  251,  100,   13,   28 }, -- 7
    [0x0038] = {  264,  100,   13,   28 }, -- 8
    [0x0039] = {  277,  100,   13,   28 }, -- 9
    [0x003a] = {  290,  100,    7,   28 }, -- :
    [0x003b] = {  297,  100,    7,   28 }, -- ;
    [0x003c] = {  304,  100,   14,   28 }, -- <
    [0x003d] = {  318,  100,   14,   28 }, -- =
    [0x003e] = {  332,  100,   14,   28 }, -- >
    [0x003f] = {  346,  100,   15,   28 }, -- ?
    [0x0040] = {  361,  100,   23,   28 }, -- @
    [0x0041] = {  384,  100,   17,   28 }, -- A
    [0x0042] = {  401,  100,   17,   28 }, -- B
    [0x0043] = {  418,  100,   17,   28 }, -- C
    [0x0044] = {  435,  100,   17,   28 }, -- D
    [0x0045] = {  452,  100,   16,   28 }, -- E
    [0x0046] = {  468,  100,   15,   28 }, -- F
    [0x0047] = {  483,  100,   19,   28 }, -- G
    [0x0048] = {    0,   72,   17,   28 }, -- H
    [0x0049] = {   17,   72,    7,   28 }, -- I
    [0x004a] = {   24,   72,   13,   28 }, -- J
    [0x004b] = {   37,   72,   17,   28 }, -- K
    [0x004c] = {   54,   72,   15,   28 }, -- L
    [0x004d] = {   69,   72,   21,   28 }, -- M
    [0x004e] = {   90,   72,   17,   28 }, -- N
    [0x004f] = {  107,   72,   18,   28 }, -- O
    [0x0050] = {  125,   72,   16,   28 }, -- P
    [0x0051] = {  141,   72,   18,   28 }, -- Q
    [0x0052] = {  159,   72,   17,   28 }, -- R
    [0x0053] = {  176,   72,   16,   28 }, -- S
    [0x0054] = {  192,   72,   15,   28 }, -- T
    [0x0055] = {  207,   72,   17,   28 }, -- U
    [0x0056] = {  224,   72,   16,   28 }, -- V
    [0x0057] = {  240,   72,   23,   28 }, -- W
    [0x0058] = {  263,   72,   16,   28 }, -- X
    [0x0059] = {  279,   72,   15,   28 }, -- Y
    [0x005a] = {  294,   72,   14,   28 }, -- Z
    [0x005b] = {  308,   72,    8,   28 }, -- [
    [0x005c] = {  316,   72,    7,   28 }, -- \
    [0x005d] = {  323,   72,    8,   28 }, -- ]
    [0x005e] = {  331,   72,   14,   28 }, -- ^
    [0x005f] = {  345,   72,   13,   28 }, -- _
    [0x0060] = {  358,   72,    8,   28 }, -- `
    [0x0061] = {  366,   72,   13,   28 }, -- a
    [0x0062] = {  379,   72,   15,   28 }, -- b
    [0x0063] = {  394,   72,   13,   28 }, -- c
    [0x0064] = {  407,   72,   15,   28 }, -- d
    [0x0065] = {  422,   72,   13,   28 }, -- e
    [0x0066] = {  435,   72,    8,   28 }, -- f
    [0x0067] = {  443,   72,   15,   28 }, -- g
    [0x0068] = {  458,   72,   15,   28 }, -- h
    [0x0069] = {  473,   72,    7,   28 }, -- i
    [0x006a] = {  480,   72,    7,   28 }, -- j
    [0x006b] = {  487,   72,   13,   28 }, -- k
    [0x006c] = {  500,   72,    7,   28 }, -- l
    [0x006d] = {    0,   44,   21,   28 }, -- m
    [0x006e] = {   21,   44,   15,   28 }, -- n
    [0x006f] = {   36,   44,   15,   28 }, -- o
    [0x0070] = {   51,   44,   15,   28 }, -- p
    [0x0071] = {   66,   44,   15,   28 }, -- q
    [0x0072] = {   81,   44,    9,   28 }, -- r
    [0x0073] = {   90,   44,   13,   28 }, -- s
    [0x0074] = {  103,   44,    8,   28 }, -- t
    [0x0075] = {  111,   44,   15,   28 }, -- u
    [0x0076] = {  126,   44,   13,   28 }, -- v
    [0x0077] = {  139,   44,   19,   28 }, -- w
    [0x0078] = {  158,   44,   13,   28 }, -- x
    [0x0079] = {  171,   44,   13,   28 }, -- y
    [0x007a] = {  184,   44,   12,   28 }, -- z
    [0x007b] = {  196,   44,    9,   28 }, -- {
    [0x007c] = {  205,   44,    7,   28 }, -- |
    [0x007d] = {  212,   44,    9,   28 }, -- }
    [0x007e] = {  221,   44,   14,   28 }, -- ~
}
gfx_font_define(`ArialBold24`, `font_arialbd24.png`, 28, codepoints)
