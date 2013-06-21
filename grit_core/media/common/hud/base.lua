-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Rect" { }


hud_class "Positioner" {     
    size = vector2(0,0);    
    factor = vector2(1,1);
    offset = vector2(0,0);
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
    end;    
    parentResizedCallback = function (self, psize)  
        self.position = math.floor(psize*self.factor + self.offset) -- floor to avoid a 0.5 pixel offset if width or height is an odd number    
    end;    
}   
 
hud_center = hud_center or gfx_hud_object_add("Positioner", { factor = vector2(0.5, 0.5) })
hud_bottom_left = hud_bottom_left or gfx_hud_object_add("Positioner", { factor = vector2(0.0, 0.0) })
hud_bottom_right = hud_bottom_right or gfx_hud_object_add("Positioner", { factor = vector2(1.0, 0.0) })
hud_top_left = hud_top_left or gfx_hud_object_add("Positioner", { factor = vector2(0.0, 1.0) })
hud_top_right = hud_top_right or gfx_hud_object_add("Positioner", { factor = vector2(1.0, 1.0) })


gfx_font_define("TinyFont","TinyFont.png",6,{

    [0x30] = {  0,  0, 5, 6 };
    [0x31] = {  5,  0, 5, 6 };
    [0x32] = { 10,  0, 5, 6 };
    [0x33] = { 15,  0, 5, 6 };
    [0x34] = { 20,  0, 5, 6 };
    [0x35] = { 25,  0, 5, 6 };
    [0x36] = { 30,  0, 5, 6 };
    [0x37] = { 35,  0, 5, 6 };
    [0x38] = { 40,  0, 5, 6 };
    [0x39] = { 45,  0, 5, 6 };

    [0x2E] = {  0,  6, 5, 6 };
    [0x2C] = {  5,  6, 5, 6 };
    [0x25] = { 10,  6, 5, 6 };
    [0x20] = { 45, 18, 5, 6 };

    [0x41] = { 15,  6, 5, 6 };
    [0x42] = { 20,  6, 5, 6 };
    [0x43] = { 25,  6, 5, 6 };
    [0x44] = { 30,  6, 5, 6 };
    [0x45] = { 35,  6, 5, 6 };
    [0x46] = { 40,  6, 5, 6 };
    [0x47] = { 45,  6, 5, 6 };

    [0x48] = {  0, 12, 5, 6 };
    [0x49] = {  5, 12, 5, 6 };
    [0x4A] = { 10, 12, 5, 6 };
    [0x4B] = { 15, 12, 5, 6 };
    [0x4C] = { 20, 12, 5, 6 };
    [0x4D] = { 25, 12, 5, 6 };
    [0x4E] = { 30, 12, 5, 6 };
    [0x4f] = { 35, 12, 5, 6 };
    [0x50] = { 40, 12, 5, 6 };
    [0x51] = { 45, 12, 5, 6 };

    [0x52] = {  0, 18, 5, 6 };
    [0x53] = {  5, 18, 5, 6 };
    [0x54] = { 10, 18, 5, 6 };
    [0x55] = { 15, 18, 5, 6 };
    [0x56] = { 20, 18, 5, 6 };
    [0x57] = { 25, 18, 5, 6 };
    [0x58] = { 30, 18, 5, 6 };
    [0x59] = { 35, 18, 5, 6 };
    [0x5a] = { 40, 18, 5, 6 };

    [0x61] = { 15,  6, 5, 6 };
    [0x62] = { 20,  6, 5, 6 };
    [0x63] = { 25,  6, 5, 6 };
    [0x64] = { 30,  6, 5, 6 };
    [0x65] = { 35,  6, 5, 6 };
    [0x66] = { 40,  6, 5, 6 };
    [0x67] = { 45,  6, 5, 6 };

    [0x68] = {  0, 12, 5, 6 };
    [0x69] = {  5, 12, 5, 6 };
    [0x6A] = { 10, 12, 5, 6 };
    [0x6B] = { 15, 12, 5, 6 };
    [0x6C] = { 20, 12, 5, 6 };
    [0x6D] = { 25, 12, 5, 6 };
    [0x6E] = { 30, 12, 5, 6 };
    [0x6f] = { 35, 12, 5, 6 };
    [0x70] = { 40, 12, 5, 6 };
    [0x71] = { 45, 12, 5, 6 };

    [0x72] = {  0, 18, 5, 6 };
    [0x73] = {  5, 18, 5, 6 };
    [0x74] = { 10, 18, 5, 6 };
    [0x75] = { 15, 18, 5, 6 };
    [0x76] = { 20, 18, 5, 6 };
    [0x77] = { 25, 18, 5, 6 };
    [0x78] = { 30, 18, 5, 6 };
    [0x79] = { 35, 18, 5, 6 };
    [0x7A] = { 40, 18, 5, 6 };


    [0x2b] = {  0, 24, 5, 6 };
    [0x2d] = {  5, 24, 5, 6 };
})
