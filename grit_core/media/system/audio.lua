-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading audio.lua")

audio = audio or { }

if not audio.collision then
    audio.collision = true
    disk_resource_acquire("/common/sounds/collision.wav") -- prevent it from being unloaded by anyone until we release it
end

if not audio.explosion then
    audio.explosion = true
    disk_resource_acquire("/common/sounds/explosion.wav") -- prevent it from being unloaded by anyone until we release it
end

disk_resource_ensure_loaded("/common/sounds/collision.wav") -- force load it (in rendering thread)
disk_resource_ensure_loaded("/common/sounds/explosion.wav") -- force load it (in rendering thread)
