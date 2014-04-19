local codepoints = {
    [0x0020] = {    0,  450,   17,   62 }, --  
    [0x0021] = {   17,  450,   20,   62 }, -- !
    [0x0022] = {   37,  450,   29,   62 }, -- "
    [0x0023] = {   66,  450,   43,   62 }, -- #
    [0x0024] = {  109,  450,   36,   62 }, -- $
    [0x0025] = {  145,  450,   64,   62 }, -- %
    [0x0026] = {  209,  450,   43,   62 }, -- &
    [0x0027] = {  252,  450,   17,   62 }, -- '
    [0x0028] = {  269,  450,   27,   62 }, -- (
    [0x0029] = {  296,  450,   27,   62 }, -- )
    [0x002a] = {  323,  450,   36,   62 }, -- *
    [0x002b] = {  359,  450,   43,   62 }, -- +
    [0x002c] = {  402,  450,   18,   62 }, -- ,
    [0x002d] = {  420,  450,   24,   62 }, -- -
    [0x002e] = {  444,  450,   18,   62 }, -- .
    [0x002f] = {  462,  450,   34,   62 }, -- /
    [0x0030] = {    0,  388,   36,   62 }, -- 0
    [0x0031] = {   36,  388,   36,   62 }, -- 1
    [0x0032] = {   72,  388,   36,   62 }, -- 2
    [0x0033] = {  108,  388,   36,   62 }, -- 3
    [0x0034] = {  144,  388,   36,   62 }, -- 4
    [0x0035] = {  180,  388,   36,   62 }, -- 5
    [0x0036] = {  216,  388,   36,   62 }, -- 6
    [0x0037] = {  252,  388,   36,   62 }, -- 7
    [0x0038] = {  288,  388,   36,   62 }, -- 8
    [0x0039] = {  324,  388,   36,   62 }, -- 9
    [0x003a] = {  360,  388,   20,   62 }, -- :
    [0x003b] = {  380,  388,   20,   62 }, -- ;
    [0x003c] = {  400,  388,   43,   62 }, -- <
    [0x003d] = {  443,  388,   43,   62 }, -- =
    [0x003e] = {    0,  326,   43,   62 }, -- >
    [0x003f] = {   43,  326,   31,   62 }, -- ?
    [0x0040] = {   74,  326,   48,   62 }, -- @
    [0x0041] = {  122,  326,   39,   62 }, -- A
    [0x0042] = {  161,  326,   38,   62 }, -- B
    [0x0043] = {  199,  326,   36,   62 }, -- C
    [0x0044] = {  235,  326,   42,   62 }, -- D
    [0x0045] = {  277,  326,   34,   62 }, -- E
    [0x0046] = {  311,  326,   33,   62 }, -- F
    [0x0047] = {  344,  326,   41,   62 }, -- G
    [0x0048] = {  385,  326,   42,   62 }, -- H
    [0x0049] = {  427,  326,   27,   62 }, -- I
    [0x004a] = {  454,  326,   28,   62 }, -- J
    [0x004b] = {    0,  264,   39,   62 }, -- K
    [0x004c] = {   39,  264,   32,   62 }, -- L
    [0x004d] = {   71,  264,   47,   62 }, -- M
    [0x004e] = {  118,  264,   42,   62 }, -- N
    [0x004f] = {  160,  264,   43,   62 }, -- O
    [0x0050] = {  203,  264,   37,   62 }, -- P
    [0x0051] = {  240,  264,   43,   62 }, -- Q
    [0x0052] = {  283,  264,   39,   62 }, -- R
    [0x0053] = {  322,  264,   36,   62 }, -- S
    [0x0054] = {  358,  264,   34,   62 }, -- T
    [0x0055] = {  392,  264,   41,   62 }, -- U
    [0x0056] = {  433,  264,   38,   62 }, -- V
    [0x0057] = {    0,  202,   56,   62 }, -- W
    [0x0058] = {   56,  202,   38,   62 }, -- X
    [0x0059] = {   94,  202,   37,   62 }, -- Y
    [0x005a] = {  131,  202,   35,   62 }, -- Z
    [0x005b] = {  166,  202,   27,   62 }, -- [
    [0x005c] = {  193,  202,   34,   62 }, -- \
    [0x005d] = {  227,  202,   27,   62 }, -- ]
    [0x005e] = {  254,  202,   43,   62 }, -- ^
    [0x005f] = {  297,  202,   36,   62 }, -- _
    [0x0060] = {  333,  202,   36,   62 }, -- `
    [0x0061] = {  369,  202,   33,   62 }, -- a
    [0x0062] = {  402,  202,   35,   62 }, -- b
    [0x0063] = {  437,  202,   29,   62 }, -- c
    [0x0064] = {  466,  202,   35,   62 }, -- d
    [0x0065] = {    0,  140,   33,   62 }, -- e
    [0x0066] = {   33,  140,   21,   62 }, -- f
    [0x0067] = {   54,  140,   35,   62 }, -- g
    [0x0068] = {   89,  140,   36,   62 }, -- h
    [0x0069] = {  125,  140,   17,   62 }, -- i
    [0x006a] = {  142,  140,   20,   62 }, -- j
    [0x006b] = {  162,  140,   34,   62 }, -- k
    [0x006c] = {  196,  140,   17,   62 }, -- l
    [0x006d] = {  213,  140,   53,   62 }, -- m
    [0x006e] = {  266,  140,   36,   62 }, -- n
    [0x006f] = {  302,  140,   34,   62 }, -- o
    [0x0070] = {  336,  140,   35,   62 }, -- p
    [0x0071] = {  371,  140,   35,   62 }, -- q
    [0x0072] = {  406,  140,   25,   62 }, -- r
    [0x0073] = {  431,  140,   30,   62 }, -- s
    [0x0074] = {  461,  140,   23,   62 }, -- t
    [0x0075] = {    0,   78,   36,   62 }, -- u
    [0x0076] = {   36,   78,   33,   62 }, -- v
    [0x0077] = {   69,   78,   49,   62 }, -- w
    [0x0078] = {  118,   78,   33,   62 }, -- x
    [0x0079] = {  151,   78,   33,   62 }, -- y
    [0x007a] = {  184,   78,   30,   62 }, -- z
    [0x007b] = {  214,   78,   36,   62 }, -- {
    [0x007c] = {  250,   78,   27,   62 }, -- |
    [0x007d] = {  277,   78,   36,   62 }, -- }
    [0x007e] = {  313,   78,   43,   62 }, -- ~
}
gfx_font_define(`VerdanaBold50`, `font_verdanab50.png`, 62, codepoints)
