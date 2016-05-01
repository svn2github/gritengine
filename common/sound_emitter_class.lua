-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

SoundEmitterClass = {
        renderingDistance=50;
        init = function(persistent)
                persistent:addDiskResource(persistent.audioFile or persistent.className..".wav")
        end;
        activate = function (persistent, instance)
                instance.audio = audio_body_make(persistent.audioFile or persistent.className..".wav")
                instance.audio.looping = true
                instance.audio.position = persistent.spawnPos
                if persistent.pitch then
                    instance.audio.pitch = persistent.pitch
                end
                if persistent.orientation then
                    instance.audio.orientation = persistent.orientation
                    instance.audio.separation = persistent.separation or 1
                end
                if persistent.volume then
                    instance.audio.volume = persistent.volume
                end
                if persistent.referenceDistance then
                    instance.audio.referenceDistance = persistent.referenceDistance
                end
                if persistent.rollOff then
                    instance.audio.rollOff = persistent.rollOff
                end
                instance.audio:play()
        end;
        deactivate = function (persistent)
                local instance = persistent.instance
                if instance.audio ~= nil then
                    instance.audio:stop()
                    instance.audio:destroy()
                end 
        end;        
}               
