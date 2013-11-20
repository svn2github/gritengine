print("Initialising misc.fixed font (deprecated version)")

local function coords(codepoint, wide)
    -- divide into grid of 84 cols
    local x = codepoint % 84
    local y = math.floor(codepoint / 84)

    -- get glyph left hand corner
    x = x * 12
    y = y * 13

    -- glyphs are either single width or double width
    local width = wide and 12 or 6

    x = x + (12 - width) -- RHS of cell is used for single width glyphs

    -- glyphs have fixed height
    local height = 13

    return x,y,width,height
end
    

local function add_font2(name,texture,tw,th)
        local codepoints = {}
        for cp=0,65535 do
                codepoints[cp] = {coords(cp,string.char(cp):getProperty("EAST_ASIAN_WIDTH")=="F")}
        end
        add_font(name,texture,tw,th,codepoints)
        print("Added font "..name.." (deprecated version)")
end

add_font2("misc.fixed","system/misc.fixed.dds",2048,8192)
