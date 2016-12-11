-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

SoundEmitterClass = {
        renderingDistance=50;
		type = "SoundEmitterClass";
        init = function(self)
                self:addDiskResource(self.audioFile or self.className..".wav")
        end;
        activate = function (self, instance)
                instance.audio = audio_body_make(self.audioFile or self.className..".wav")
                instance.audio.looping = true
                instance.audio.position = self.spawnPos
                if self.pitch then
                    instance.audio.pitch = self.pitch
                end
                if self.orientation then
                    instance.audio.orientation = self.orientation
                    instance.audio.separation = self.separation or 1
                end
                if self.volume then
                    instance.audio.volume = self.volume
                end
                if self.referenceDistance then
                    instance.audio.referenceDistance = self.referenceDistance
                end
                if self.rollOff then
                    instance.audio.rollOff = self.rollOff
                end
                instance.audio:play()
        end;
        deactivate = function (self)
                local instance = self.instance
                if instance.audio ~= nil then
                    instance.audio:stop()
                    instance.audio:destroy()
                end 
        end;        
}               
