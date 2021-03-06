local codepoints = {
    [0x0020] = {    0,  107,    5,   21 }, --  
    [0x0021] = {    5,  107,    6,   21 }, -- !
    [0x0022] = {   11,  107,    9,   21 }, -- "
    [0x0023] = {   20,  107,   13,   21 }, -- #
    [0x0024] = {   33,  107,   11,   21 }, -- $
    [0x0025] = {   44,  107,   20,   21 }, -- %
    [0x0026] = {   64,  107,   14,   21 }, -- &
    [0x0027] = {   78,  107,    6,   21 }, -- '
    [0x0028] = {   84,  107,    9,   21 }, -- (
    [0x0029] = {   93,  107,    9,   21 }, -- )
    [0x002a] = {  102,  107,   11,   21 }, -- *
    [0x002b] = {  113,  107,   13,   21 }, -- +
    [0x002c] = {  126,  107,    6,   21 }, -- ,
    [0x002d] = {  132,  107,    8,   21 }, -- -
    [0x002e] = {  140,  107,    6,   21 }, -- .
    [0x002f] = {  146,  107,   11,   21 }, -- /
    [0x0030] = {  157,  107,   11,   21 }, -- 0
    [0x0031] = {  168,  107,   11,   21 }, -- 1
    [0x0032] = {  179,  107,   11,   21 }, -- 2
    [0x0033] = {  190,  107,   11,   21 }, -- 3
    [0x0034] = {  201,  107,   11,   21 }, -- 4
    [0x0035] = {  212,  107,   11,   21 }, -- 5
    [0x0036] = {  223,  107,   11,   21 }, -- 6
    [0x0037] = {  234,  107,   11,   21 }, -- 7
    [0x0038] = {    0,   86,   11,   21 }, -- 8
    [0x0039] = {   11,   86,   11,   21 }, -- 9
    [0x003a] = {   22,   86,    6,   21 }, -- :
    [0x003b] = {   28,   86,    6,   21 }, -- ;
    [0x003c] = {   34,   86,   13,   21 }, -- <
    [0x003d] = {   47,   86,   13,   21 }, -- =
    [0x003e] = {   60,   86,   13,   21 }, -- >
    [0x003f] = {   73,   86,   10,   21 }, -- ?
    [0x0040] = {   83,   86,   15,   21 }, -- @
    [0x0041] = {   98,   86,   12,   21 }, -- A
    [0x0042] = {  110,   86,   12,   21 }, -- B
    [0x0043] = {  122,   86,   12,   21 }, -- C
    [0x0044] = {  134,   86,   13,   21 }, -- D
    [0x0045] = {  147,   86,   11,   21 }, -- E
    [0x0046] = {  158,   86,   10,   21 }, -- F
    [0x0047] = {  168,   86,   13,   21 }, -- G
    [0x0048] = {  181,   86,   13,   21 }, -- H
    [0x0049] = {  194,   86,    8,   21 }, -- I
    [0x004a] = {  202,   86,    9,   21 }, -- J
    [0x004b] = {  211,   86,   12,   21 }, -- K
    [0x004c] = {  223,   86,   10,   21 }, -- L
    [0x004d] = {  233,   86,   15,   21 }, -- M
    [0x004e] = {    0,   65,   13,   21 }, -- N
    [0x004f] = {   13,   65,   14,   21 }, -- O
    [0x0050] = {   27,   65,   12,   21 }, -- P
    [0x0051] = {   39,   65,   14,   21 }, -- Q
    [0x0052] = {   53,   65,   13,   21 }, -- R
    [0x0053] = {   66,   65,   11,   21 }, -- S
    [0x0054] = {   77,   65,   12,   21 }, -- T
    [0x0055] = {   89,   65,   13,   21 }, -- U
    [0x0056] = {  102,   65,   12,   21 }, -- V
    [0x0057] = {  114,   65,   18,   21 }, -- W
    [0x0058] = {  132,   65,   12,   21 }, -- X
    [0x0059] = {  144,   65,   12,   21 }, -- Y
    [0x005a] = {  156,   65,   11,   21 }, -- Z
    [0x005b] = {  167,   65,    9,   21 }, -- [
    [0x005c] = {  176,   65,   11,   21 }, -- \
    [0x005d] = {  187,   65,    9,   21 }, -- ]
    [0x005e] = {  196,   65,   13,   21 }, -- ^
    [0x005f] = {  209,   65,   11,   21 }, -- _
    [0x0060] = {  220,   65,   11,   21 }, -- `
    [0x0061] = {  231,   65,   11,   21 }, -- a
    [0x0062] = {  242,   65,   11,   21 }, -- b
    [0x0063] = {    0,   44,    9,   21 }, -- c
    [0x0064] = {    9,   44,   11,   21 }, -- d
    [0x0065] = {   20,   44,   11,   21 }, -- e
    [0x0066] = {   31,   44,    7,   21 }, -- f
    [0x0067] = {   38,   44,   11,   21 }, -- g
    [0x0068] = {   49,   44,   11,   21 }, -- h
    [0x0069] = {   60,   44,    4,   21 }, -- i
    [0x006a] = {   64,   44,    6,   21 }, -- j
    [0x006b] = {   70,   44,   10,   21 }, -- k
    [0x006c] = {   80,   44,    4,   21 }, -- l
    [0x006d] = {   84,   44,   16,   21 }, -- m
    [0x006e] = {  100,   44,   11,   21 }, -- n
    [0x006f] = {  111,   44,   11,   21 }, -- o
    [0x0070] = {  122,   44,   11,   21 }, -- p
    [0x0071] = {  133,   44,   11,   21 }, -- q
    [0x0072] = {  144,   44,    8,   21 }, -- r
    [0x0073] = {  152,   44,    9,   21 }, -- s
    [0x0074] = {  161,   44,    7,   21 }, -- t
    [0x0075] = {  168,   44,   11,   21 }, -- u
    [0x0076] = {  179,   44,   10,   21 }, -- v
    [0x0077] = {  189,   44,   16,   21 }, -- w
    [0x0078] = {  205,   44,   11,   21 }, -- x
    [0x0079] = {  216,   44,   10,   21 }, -- y
    [0x007a] = {  226,   44,   10,   21 }, -- z
    [0x007b] = {  236,   44,   11,   21 }, -- {
    [0x007c] = {  247,   44,    8,   21 }, -- |
    [0x007d] = {    0,   23,   11,   21 }, -- }
    [0x007e] = {   11,   23,   13,   21 }, -- ~
}
gfx_font_define(`VerdanaBold16`, `font_verdanab16.png`, 21, codepoints)

material `VerdanaBold16` {
    shader = `Font`,
    diffuseMap = `font_verdanab16.png`,
    alphaRejectThreshold = 0.5,
}

material `VerdanaBold16Alpha` {
    shader = `Font`,
    diffuseMap = `font_verdanab16.png`,
    sceneBlend = "ALPHA";
}
