-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading capturer.lua")

Capturer = Capturer or { }

function Capturer.new()
        local self = { }

        self.rate = 1/25-1/75
        self.recording = false
        self.frameCounter = 0
        self.frameTime = 0
        self.moviePrefix = "movie/"
        self.movieFormat = "tga"
        self.screenShotCounter = 0

        make_instance(self,Capturer)

        return self

end

function Capturer:singleScreenShot(movie)
        local name
        local counter = 1
        while true do
                local prefix = movie and self.moviePrefix or ""
                local suffix = movie and self.movieFormat or user_cfg.screenshotFormat
                name = string.format("%sscreenshot-%03d.%s",prefix,counter,suffix)
                counter = counter + 1
                local fd = io.open(name)
                if fd==nil then
                        break
                end
                fd:close()
        end
        gfx_screenshot(name)
        echo("Wrote: "..name)
end

function Capturer:frameCallback()
        local secs = seconds()
        local elapsed = self.frameTime - secs
        if elapsed < self.rate then
                return
        end
        -- record the frame
        local name = string.format("%smovie-%05d.%s",self.moviePrefix,self.frameCounter,"tga")
        self.frameCounter = self.frameCounter + 1
        gfx_screenshot(name)
        self.frameTimer = secs
end

function Capturer:toggle()
        if self.recording then
                self:stop()
        else
                self:record()
        end
end

function Capturer:record()
        if self.recording then error("Already recording.") end
        echo ("Started recording")
        main.frameCallbacks:insert("Capturer.frameCallback",function (...) self:frameCallback(...) end)
        self.recording = true
        self.frameCounter = 0
        self.frameTime = seconds()
end
function Capturer:stop()
        if not self.recording then error("Not recording.") end
        main.frameCallbacks:removeByName("Capturer.frameCallback")
        self.recording = false
        echo ("Recorded: "..self.frameCounter.." frames in "..(seconds()-self.frameTime).." seconds ("..self.frameCounter/self.frameTime.." fps)")
end

function Capturer:destroy()
        if self.recording then
                self:stop()
        end
end

if capturer ~= nil then
        capturer:destroy()
end
capturer = Capturer.new()

