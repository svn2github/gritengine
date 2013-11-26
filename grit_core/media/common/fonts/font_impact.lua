local codepoints = {
    [0x0020] = {    0,  255,    1,    1 }, --  
    [0x0021] = {    1,  215,   13,   41 }, -- !
    [0x0022] = {   14,  215,   17,   41 }, -- "
    [0x0023] = {   31,  220,   30,   36 }, -- #
    [0x0024] = {   61,  209,   25,   47 }, -- $
    [0x0025] = {   86,  214,   34,   42 }, -- %
    [0x0026] = {  120,  223,   30,   33 }, -- &
    [0x0027] = {  150,  215,    8,   41 }, -- '
    [0x0028] = {  158,  215,   15,   41 }, -- (
    [0x0029] = {  173,  215,   14,   41 }, -- )
    [0x002a] = {  187,  215,   14,   41 }, -- *
    [0x002b] = {  201,  223,   25,   33 }, -- +
    [0x002c] = {  226,  243,    8,   13 }, -- ,
    [0x002d] = {  234,  235,   14,   21 }, -- -
    [0x002e] = {  248,  247,    8,    9 }, -- .
    [0x002f] = {  256,  215,   19,   41 }, -- /
    [0x0030] = {  275,  214,   25,   42 }, -- 0
    [0x0031] = {  300,  215,   17,   41 }, -- 1
    [0x0032] = {  317,  214,   23,   42 }, -- 2
    [0x0033] = {  340,  214,   25,   42 }, -- 3
    [0x0034] = {  365,  215,   25,   41 }, -- 4
    [0x0035] = {  390,  215,   25,   41 }, -- 5
    [0x0036] = {  415,  214,   25,   42 }, -- 6
    [0x0037] = {  440,  215,   20,   41 }, -- 7
    [0x0038] = {  460,  214,   25,   42 }, -- 8
    [0x0039] = {  485,  214,   25,   42 }, -- 9
    [0x003a] = {    0,  179,    9,   27 }, -- :
    [0x003b] = {    9,  175,    9,   31 }, -- ;
    [0x003c] = {   18,  172,   25,   34 }, -- <
    [0x003d] = {   43,  178,   25,   28 }, -- =
    [0x003e] = {   68,  172,   25,   34 }, -- >
    [0x003f] = {   93,  164,   24,   42 }, -- ?
    [0x0040] = {  117,  163,   38,   43 }, -- @
    [0x0041] = {  155,  165,   27,   41 }, -- A
    [0x0042] = {  182,  165,   26,   41 }, -- B
    [0x0043] = {  208,  164,   26,   42 }, -- C
    [0x0044] = {  234,  165,   26,   41 }, -- D
    [0x0045] = {  260,  165,   20,   41 }, -- E
    [0x0046] = {  280,  165,   20,   41 }, -- F
    [0x0047] = {  300,  164,   26,   42 }, -- G
    [0x0048] = {  326,  165,   26,   41 }, -- H
    [0x0049] = {  352,  165,   12,   41 }, -- I
    [0x004a] = {  364,  165,   15,   41 }, -- J
    [0x004b] = {  379,  165,   28,   41 }, -- K
    [0x004c] = {  407,  165,   18,   41 }, -- L
    [0x004d] = {  425,  165,   34,   41 }, -- M
    [0x004e] = {  459,  165,   25,   41 }, -- N
    [0x004f] = {  484,  164,   25,   42 }, -- O
    [0x0050] = {    0,  115,   24,   41 }, -- P
    [0x0051] = {   24,  110,   25,   46 }, -- Q
    [0x0052] = {   49,  115,   25,   41 }, -- R
    [0x0053] = {   74,  114,   25,   42 }, -- S
    [0x0054] = {   99,  115,   23,   41 }, -- T
    [0x0055] = {  122,  115,   25,   41 }, -- U
    [0x0056] = {  147,  115,   27,   41 }, -- V
    [0x0057] = {  174,  115,   41,   41 }, -- W
    [0x0058] = {  215,  115,   25,   41 }, -- X
    [0x0059] = {  240,  115,   23,   41 }, -- Y
    [0x005a] = {  263,  115,   20,   41 }, -- Z
    [0x005b] = {  283,  115,   13,   41 }, -- [
    [0x005c] = {  296,  115,   20,   41 }, -- \
    [0x005d] = {  316,  115,   12,   41 }, -- ]
    [0x005e] = {  328,  115,   24,   41 }, -- ^
    [0x005f] = {  352,  150,   28,    6 }, -- _
    [0x0060] = {  380,  111,   13,   45 }, -- `
    [0x0061] = {  393,  123,   23,   33 }, -- a
    [0x0062] = {  416,  115,   24,   41 }, -- b
    [0x0063] = {  440,  123,   23,   33 }, -- c
    [0x0064] = {  463,  115,   24,   41 }, -- d
    [0x0065] = {  487,  123,   24,   33 }, -- e
    [0x0066] = {    0,   65,   13,   41 }, -- f
    [0x0067] = {   13,   68,   24,   38 }, -- g
    [0x0068] = {   37,   65,   24,   41 }, -- h
    [0x0069] = {   61,   65,   11,   41 }, -- i
    [0x006a] = {   72,   61,   12,   45 }, -- j
    [0x006b] = {   84,   65,   24,   41 }, -- k
    [0x006c] = {  108,   65,   11,   41 }, -- l
    [0x006d] = {  119,   73,   37,   33 }, -- m
    [0x006e] = {  156,   73,   24,   33 }, -- n
    [0x006f] = {  180,   73,   24,   33 }, -- o
    [0x0070] = {  204,   69,   24,   37 }, -- p
    [0x0071] = {  228,   69,   24,   37 }, -- q
    [0x0072] = {  252,   73,   17,   33 }, -- r
    [0x0073] = {  269,   73,   22,   33 }, -- s
    [0x0074] = {  291,   68,   14,   38 }, -- t
    [0x0075] = {  305,   73,   24,   33 }, -- u
    [0x0076] = {  329,   73,   23,   33 }, -- v
    [0x0077] = {  352,   73,   33,   33 }, -- w
    [0x0078] = {  385,   73,   23,   33 }, -- x
    [0x0079] = {  408,   69,   23,   37 }, -- y
    [0x007a] = {  431,   73,   17,   33 }, -- z
    [0x007b] = {  448,   59,   17,   47 }, -- {
    [0x007c] = {  465,   60,    9,   46 }, -- |
    [0x007d] = {  474,   59,   17,   47 }, -- }
    [0x007e] = {    0,   29,   24,   27 }, -- ~
}
gfx_font_define("Impact", "font_impact.png", 50, codepoints)
