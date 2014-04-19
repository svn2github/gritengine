local codepoints = {
    [0x0020] = {    0,  450,   18,   62 }, --  
    [0x0021] = {   18,  450,   20,   62 }, -- !
    [0x0022] = {   38,  450,   23,   62 }, -- "
    [0x0023] = {   61,  450,   41,   62 }, -- #
    [0x0024] = {  102,  450,   32,   62 }, -- $
    [0x0025] = {  134,  450,   54,   62 }, -- %
    [0x0026] = {  188,  450,   36,   62 }, -- &
    [0x0027] = {  224,  450,   13,   62 }, -- '
    [0x0028] = {  237,  450,   23,   62 }, -- (
    [0x0029] = {  260,  450,   23,   62 }, -- )
    [0x002a] = {  283,  450,   32,   62 }, -- *
    [0x002b] = {  315,  450,   41,   62 }, -- +
    [0x002c] = {  356,  450,   18,   62 }, -- ,
    [0x002d] = {  374,  450,   23,   62 }, -- -
    [0x002e] = {  397,  450,   18,   62 }, -- .
    [0x002f] = {  415,  450,   23,   62 }, -- /
    [0x0030] = {  438,  450,   32,   62 }, -- 0
    [0x0031] = {  470,  450,   32,   62 }, -- 1
    [0x0032] = {    0,  388,   32,   62 }, -- 2
    [0x0033] = {   32,  388,   32,   62 }, -- 3
    [0x0034] = {   64,  388,   32,   62 }, -- 4
    [0x0035] = {   96,  388,   32,   62 }, -- 5
    [0x0036] = {  128,  388,   32,   62 }, -- 6
    [0x0037] = {  160,  388,   32,   62 }, -- 7
    [0x0038] = {  192,  388,   32,   62 }, -- 8
    [0x0039] = {  224,  388,   32,   62 }, -- 9
    [0x003a] = {  256,  388,   23,   62 }, -- :
    [0x003b] = {  279,  388,   23,   62 }, -- ;
    [0x003c] = {  302,  388,   41,   62 }, -- <
    [0x003d] = {  343,  388,   41,   62 }, -- =
    [0x003e] = {  384,  388,   41,   62 }, -- >
    [0x003f] = {  425,  388,   27,   62 }, -- ?
    [0x0040] = {  452,  388,   50,   62 }, -- @
    [0x0041] = {    0,  326,   34,   62 }, -- A
    [0x0042] = {   34,  326,   34,   62 }, -- B
    [0x0043] = {   68,  326,   35,   62 }, -- C
    [0x0044] = {  103,  326,   39,   62 }, -- D
    [0x0045] = {  142,  326,   32,   62 }, -- E
    [0x0046] = {  174,  326,   29,   62 }, -- F
    [0x0047] = {  203,  326,   39,   62 }, -- G
    [0x0048] = {  242,  326,   38,   62 }, -- H
    [0x0049] = {  280,  326,   21,   62 }, -- I
    [0x004a] = {  301,  326,   23,   62 }, -- J
    [0x004b] = {  324,  326,   35,   62 }, -- K
    [0x004c] = {  359,  326,   28,   62 }, -- L
    [0x004d] = {  387,  326,   42,   62 }, -- M
    [0x004e] = {  429,  326,   37,   62 }, -- N
    [0x004f] = {  466,  326,   39,   62 }, -- O
    [0x0050] = {    0,  264,   30,   62 }, -- P
    [0x0051] = {   30,  264,   39,   62 }, -- Q
    [0x0052] = {   69,  264,   35,   62 }, -- R
    [0x0053] = {  104,  264,   34,   62 }, -- S
    [0x0054] = {  138,  264,   31,   62 }, -- T
    [0x0055] = {  169,  264,   37,   62 }, -- U
    [0x0056] = {  206,  264,   34,   62 }, -- V
    [0x0057] = {  240,  264,   49,   62 }, -- W
    [0x0058] = {  289,  264,   34,   62 }, -- X
    [0x0059] = {  323,  264,   31,   62 }, -- Y
    [0x005a] = {  354,  264,   34,   62 }, -- Z
    [0x005b] = {  388,  264,   23,   62 }, -- [
    [0x005c] = {  411,  264,   23,   62 }, -- \
    [0x005d] = {  434,  264,   23,   62 }, -- ]
    [0x005e] = {  457,  264,   41,   62 }, -- ^
    [0x005f] = {    0,  202,   32,   62 }, -- _
    [0x0060] = {   32,  202,   32,   62 }, -- `
    [0x0061] = {   64,  202,   30,   62 }, -- a
    [0x0062] = {   94,  202,   31,   62 }, -- b
    [0x0063] = {  125,  202,   26,   62 }, -- c
    [0x0064] = {  151,  202,   31,   62 }, -- d
    [0x0065] = {  182,  202,   30,   62 }, -- e
    [0x0066] = {  212,  202,   18,   62 }, -- f
    [0x0067] = {  230,  202,   31,   62 }, -- g
    [0x0068] = {  261,  202,   32,   62 }, -- h
    [0x0069] = {  293,  202,   15,   62 }, -- i
    [0x006a] = {  308,  202,   17,   62 }, -- j
    [0x006b] = {  325,  202,   30,   62 }, -- k
    [0x006c] = {  355,  202,   15,   62 }, -- l
    [0x006d] = {  370,  202,   49,   62 }, -- m
    [0x006e] = {  419,  202,   32,   62 }, -- n
    [0x006f] = {  451,  202,   30,   62 }, -- o
    [0x0070] = {    0,  140,   31,   62 }, -- p
    [0x0071] = {   31,  140,   31,   62 }, -- q
    [0x0072] = {   62,  140,   21,   62 }, -- r
    [0x0073] = {   83,  140,   26,   62 }, -- s
    [0x0074] = {  109,  140,   20,   62 }, -- t
    [0x0075] = {  129,  140,   32,   62 }, -- u
    [0x0076] = {  161,  140,   30,   62 }, -- v
    [0x0077] = {  191,  140,   41,   62 }, -- w
    [0x0078] = {  232,  140,   30,   62 }, -- x
    [0x0079] = {  262,  140,   30,   62 }, -- y
    [0x007a] = {  292,  140,   26,   62 }, -- z
    [0x007b] = {  318,  140,   32,   62 }, -- {
    [0x007c] = {  350,  140,   23,   62 }, -- |
    [0x007d] = {  373,  140,   32,   62 }, -- }
    [0x007e] = {  405,  140,   41,   62 }, -- ~
}
gfx_font_define(`Verdana50`, `font_verdana50.png`, 62, codepoints)
