local codepoints = {
    [0x0020] = {    0,   97,    8,   31 }, --  
    [0x0021] = {    8,   97,   10,   31 }, -- !
    [0x0022] = {   18,   97,   14,   31 }, -- "
    [0x0023] = {   32,   97,   21,   31 }, -- #
    [0x0024] = {   53,   97,   17,   31 }, -- $
    [0x0025] = {   70,   97,   31,   31 }, -- %
    [0x0026] = {  101,   97,   21,   31 }, -- &
    [0x0027] = {  122,   97,    8,   31 }, -- '
    [0x0028] = {  130,   97,   13,   31 }, -- (
    [0x0029] = {  143,   97,   13,   31 }, -- )
    [0x002a] = {  156,   97,   17,   31 }, -- *
    [0x002b] = {  173,   97,   21,   31 }, -- +
    [0x002c] = {  194,   97,    9,   31 }, -- ,
    [0x002d] = {  203,   97,   12,   31 }, -- -
    [0x002e] = {  215,   97,    9,   31 }, -- .
    [0x002f] = {  224,   97,   17,   31 }, -- /
    [0x0030] = {  241,   97,   17,   31 }, -- 0
    [0x0031] = {  258,   97,   17,   31 }, -- 1
    [0x0032] = {  275,   97,   17,   31 }, -- 2
    [0x0033] = {  292,   97,   17,   31 }, -- 3
    [0x0034] = {  309,   97,   17,   31 }, -- 4
    [0x0035] = {  326,   97,   17,   31 }, -- 5
    [0x0036] = {  343,   97,   17,   31 }, -- 6
    [0x0037] = {  360,   97,   17,   31 }, -- 7
    [0x0038] = {  377,   97,   17,   31 }, -- 8
    [0x0039] = {  394,   97,   17,   31 }, -- 9
    [0x003a] = {  411,   97,   10,   31 }, -- :
    [0x003b] = {  421,   97,   10,   31 }, -- ;
    [0x003c] = {  431,   97,   21,   31 }, -- <
    [0x003d] = {  452,   97,   21,   31 }, -- =
    [0x003e] = {  473,   97,   21,   31 }, -- >
    [0x003f] = {  494,   97,   15,   31 }, -- ?
    [0x0040] = {    0,   66,   23,   31 }, -- @
    [0x0041] = {   23,   66,   19,   31 }, -- A
    [0x0042] = {   42,   66,   18,   31 }, -- B
    [0x0043] = {   60,   66,   17,   31 }, -- C
    [0x0044] = {   77,   66,   20,   31 }, -- D
    [0x0045] = {   97,   66,   16,   31 }, -- E
    [0x0046] = {  113,   66,   16,   31 }, -- F
    [0x0047] = {  129,   66,   19,   31 }, -- G
    [0x0048] = {  148,   66,   20,   31 }, -- H
    [0x0049] = {  168,   66,   13,   31 }, -- I
    [0x004a] = {  181,   66,   13,   31 }, -- J
    [0x004b] = {  194,   66,   19,   31 }, -- K
    [0x004c] = {  213,   66,   15,   31 }, -- L
    [0x004d] = {  228,   66,   23,   31 }, -- M
    [0x004e] = {  251,   66,   20,   31 }, -- N
    [0x004f] = {  271,   66,   20,   31 }, -- O
    [0x0050] = {  291,   66,   18,   31 }, -- P
    [0x0051] = {  309,   66,   20,   31 }, -- Q
    [0x0052] = {  329,   66,   19,   31 }, -- R
    [0x0053] = {  348,   66,   17,   31 }, -- S
    [0x0054] = {  365,   66,   16,   31 }, -- T
    [0x0055] = {  381,   66,   19,   31 }, -- U
    [0x0056] = {  400,   66,   18,   31 }, -- V
    [0x0057] = {  418,   66,   27,   31 }, -- W
    [0x0058] = {  445,   66,   18,   31 }, -- X
    [0x0059] = {  463,   66,   18,   31 }, -- Y
    [0x005a] = {  481,   66,   17,   31 }, -- Z
    [0x005b] = {  498,   66,   13,   31 }, -- [
    [0x005c] = {    0,   35,   17,   31 }, -- \
    [0x005d] = {   17,   35,   13,   31 }, -- ]
    [0x005e] = {   30,   35,   21,   31 }, -- ^
    [0x005f] = {   51,   35,   17,   31 }, -- _
    [0x0060] = {   68,   35,   17,   31 }, -- `
    [0x0061] = {   85,   35,   16,   31 }, -- a
    [0x0062] = {  101,   35,   17,   31 }, -- b
    [0x0063] = {  118,   35,   14,   31 }, -- c
    [0x0064] = {  132,   35,   17,   31 }, -- d
    [0x0065] = {  149,   35,   16,   31 }, -- e
    [0x0066] = {  165,   35,   10,   31 }, -- f
    [0x0067] = {  175,   35,   17,   31 }, -- g
    [0x0068] = {  192,   35,   17,   31 }, -- h
    [0x0069] = {  209,   35,    8,   31 }, -- i
    [0x006a] = {  217,   35,   10,   31 }, -- j
    [0x006b] = {  227,   35,   16,   31 }, -- k
    [0x006c] = {  243,   35,    8,   31 }, -- l
    [0x006d] = {  251,   35,   25,   31 }, -- m
    [0x006e] = {  276,   35,   17,   31 }, -- n
    [0x006f] = {  293,   35,   16,   31 }, -- o
    [0x0070] = {  309,   35,   17,   31 }, -- p
    [0x0071] = {  326,   35,   17,   31 }, -- q
    [0x0072] = {  343,   35,   12,   31 }, -- r
    [0x0073] = {  355,   35,   14,   31 }, -- s
    [0x0074] = {  369,   35,   11,   31 }, -- t
    [0x0075] = {  380,   35,   17,   31 }, -- u
    [0x0076] = {  397,   35,   16,   31 }, -- v
    [0x0077] = {  413,   35,   24,   31 }, -- w
    [0x0078] = {  437,   35,   16,   31 }, -- x
    [0x0079] = {  453,   35,   16,   31 }, -- y
    [0x007a] = {  469,   35,   14,   31 }, -- z
    [0x007b] = {  483,   35,   17,   31 }, -- {
    [0x007c] = {    0,    4,   13,   31 }, -- |
    [0x007d] = {   13,    4,   17,   31 }, -- }
    [0x007e] = {   30,    4,   21,   31 }, -- ~
}
gfx_font_define("VerdanaBold24", "font_verdanab24.png", 31, codepoints)