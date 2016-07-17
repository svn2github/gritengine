local codepoints = {
    [0x0020] = {    0,   97,    8,   31 }, --  
    [0x0021] = {    8,   97,    9,   31 }, -- !
    [0x0022] = {   17,   97,   11,   31 }, -- "
    [0x0023] = {   28,   97,   20,   31 }, -- #
    [0x0024] = {   48,   97,   15,   31 }, -- $
    [0x0025] = {   63,   97,   26,   31 }, -- %
    [0x0026] = {   89,   97,   17,   31 }, -- &
    [0x0027] = {  106,   97,    6,   31 }, -- '
    [0x0028] = {  112,   97,   11,   31 }, -- (
    [0x0029] = {  123,   97,   11,   31 }, -- )
    [0x002a] = {  134,   97,   15,   31 }, -- *
    [0x002b] = {  149,   97,   20,   31 }, -- +
    [0x002c] = {  169,   97,    9,   31 }, -- ,
    [0x002d] = {  178,   97,   11,   31 }, -- -
    [0x002e] = {  189,   97,    9,   31 }, -- .
    [0x002f] = {  198,   97,   11,   31 }, -- /
    [0x0030] = {  209,   97,   15,   31 }, -- 0
    [0x0031] = {  224,   97,   15,   31 }, -- 1
    [0x0032] = {  239,   97,   15,   31 }, -- 2
    [0x0033] = {  254,   97,   15,   31 }, -- 3
    [0x0034] = {  269,   97,   15,   31 }, -- 4
    [0x0035] = {  284,   97,   15,   31 }, -- 5
    [0x0036] = {  299,   97,   15,   31 }, -- 6
    [0x0037] = {  314,   97,   15,   31 }, -- 7
    [0x0038] = {  329,   97,   15,   31 }, -- 8
    [0x0039] = {  344,   97,   15,   31 }, -- 9
    [0x003a] = {  359,   97,   11,   31 }, -- :
    [0x003b] = {  370,   97,   11,   31 }, -- ;
    [0x003c] = {  381,   97,   20,   31 }, -- <
    [0x003d] = {  401,   97,   20,   31 }, -- =
    [0x003e] = {  421,   97,   20,   31 }, -- >
    [0x003f] = {  441,   97,   13,   31 }, -- ?
    [0x0040] = {  454,   97,   24,   31 }, -- @
    [0x0041] = {  478,   97,   16,   31 }, -- A
    [0x0042] = {  494,   97,   16,   31 }, -- B
    [0x0043] = {    0,   66,   17,   31 }, -- C
    [0x0044] = {   17,   66,   19,   31 }, -- D
    [0x0045] = {   36,   66,   15,   31 }, -- E
    [0x0046] = {   51,   66,   14,   31 }, -- F
    [0x0047] = {   65,   66,   19,   31 }, -- G
    [0x0048] = {   84,   66,   18,   31 }, -- H
    [0x0049] = {  102,   66,   10,   31 }, -- I
    [0x004a] = {  112,   66,   11,   31 }, -- J
    [0x004b] = {  123,   66,   17,   31 }, -- K
    [0x004c] = {  140,   66,   13,   31 }, -- L
    [0x004d] = {  153,   66,   20,   31 }, -- M
    [0x004e] = {  173,   66,   18,   31 }, -- N
    [0x004f] = {  191,   66,   19,   31 }, -- O
    [0x0050] = {  210,   66,   14,   31 }, -- P
    [0x0051] = {  224,   66,   19,   31 }, -- Q
    [0x0052] = {  243,   66,   17,   31 }, -- R
    [0x0053] = {  260,   66,   16,   31 }, -- S
    [0x0054] = {  276,   66,   15,   31 }, -- T
    [0x0055] = {  291,   66,   18,   31 }, -- U
    [0x0056] = {  309,   66,   16,   31 }, -- V
    [0x0057] = {  325,   66,   24,   31 }, -- W
    [0x0058] = {  349,   66,   16,   31 }, -- X
    [0x0059] = {  365,   66,   15,   31 }, -- Y
    [0x005a] = {  380,   66,   16,   31 }, -- Z
    [0x005b] = {  396,   66,   11,   31 }, -- [
    [0x005c] = {  407,   66,   11,   31 }, -- \
    [0x005d] = {  418,   66,   11,   31 }, -- ]
    [0x005e] = {  429,   66,   20,   31 }, -- ^
    [0x005f] = {  449,   66,   15,   31 }, -- _
    [0x0060] = {  464,   66,   15,   31 }, -- `
    [0x0061] = {  479,   66,   14,   31 }, -- a
    [0x0062] = {  493,   66,   15,   31 }, -- b
    [0x0063] = {    0,   35,   13,   31 }, -- c
    [0x0064] = {   13,   35,   15,   31 }, -- d
    [0x0065] = {   28,   35,   14,   31 }, -- e
    [0x0066] = {   42,   35,    8,   31 }, -- f
    [0x0067] = {   50,   35,   15,   31 }, -- g
    [0x0068] = {   65,   35,   15,   31 }, -- h
    [0x0069] = {   80,   35,    6,   31 }, -- i
    [0x006a] = {   86,   35,    8,   31 }, -- j
    [0x006b] = {   94,   35,   14,   31 }, -- k
    [0x006c] = {  108,   35,    6,   31 }, -- l
    [0x006d] = {  114,   35,   23,   31 }, -- m
    [0x006e] = {  137,   35,   15,   31 }, -- n
    [0x006f] = {  152,   35,   15,   31 }, -- o
    [0x0070] = {  167,   35,   15,   31 }, -- p
    [0x0071] = {  182,   35,   15,   31 }, -- q
    [0x0072] = {  197,   35,   10,   31 }, -- r
    [0x0073] = {  207,   35,   13,   31 }, -- s
    [0x0074] = {  220,   35,    9,   31 }, -- t
    [0x0075] = {  229,   35,   15,   31 }, -- u
    [0x0076] = {  244,   35,   14,   31 }, -- v
    [0x0077] = {  258,   35,   20,   31 }, -- w
    [0x0078] = {  278,   35,   14,   31 }, -- x
    [0x0079] = {  292,   35,   14,   31 }, -- y
    [0x007a] = {  306,   35,   13,   31 }, -- z
    [0x007b] = {  319,   35,   15,   31 }, -- {
    [0x007c] = {  334,   35,   11,   31 }, -- |
    [0x007d] = {  345,   35,   15,   31 }, -- }
    [0x007e] = {  360,   35,   20,   31 }, -- ~
}
gfx_font_define(`Verdana24`, `font_verdana24.png`, 31, codepoints)