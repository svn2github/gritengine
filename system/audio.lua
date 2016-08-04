-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading audio.lua")

audio = audio or { }

if disk_resource_has(`/common/sounds/collision.wav`) then
	 -- prevent it from being unloaded by anyone until we release it
	audio.collision = disk_resource_hold_make(`/common/sounds/collision.wav`)
	 -- force load it (in rendering thread)
	disk_resource_ensure_loaded(audio.collision.name)

	audio.explosion = disk_resource_hold_make(`/common/sounds/explosion.wav`)
	disk_resource_ensure_loaded(audio.explosion.name)
end
