-- (c) Augusto Moura 2014, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `.` {
    alpha = 0;
	size = vec(1500, 1024);
	size2 = vec(2048, 2048);
	alp = 1;
    zOrder = 0;
	
	flare = {};
	
    init = function (self)
		self.needsFrameCallbacks = true
		
		self.flare = {}
		
        self.flare[0] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare0.png", size=self.size})
        self.flare[0].parent = self
		
        self.flare[1] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare1.png", needsAlpha = true, size=vec(2048, 256)})
        self.flare[1].parent = self		

        self.flare[2] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare2.png"})
        self.flare[2].parent = self

        self.flare[3] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare3.png"})
        self.flare[3].parent = self

        self.flare[4] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare4.png"})
        self.flare[4].parent = self

        self.flare[5] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare5.png", size=self.size2})
        self.flare[5].parent = self
		
		self.flare[6] = gfx_hud_object_add("/common/hud/Rect", {texture="Flare6.png", size=vec(512, 512)})
        self.flare[6].parent = self	
    end;
    destroy = function (self)
		self.needsFrameCallbacks = false
        for i = 0, 6 do
            self.flare[i]:destroy()
        end	
    end;
    frameCallback = function (self, elapsed)

        -- sun_direction is the direction of the rays of light, so invert to point towards the sun
        --
		local sun_pos = player_ctrl.camPos + (gfx_sun_falloff_distance() * gfx_sun_direction() * -1)	
            
        local screen_pos = gfx_world_to_screen(player_ctrl.camPos, player_ctrl.camDir, sun_pos)

		--local sunPos = vector3(-1600, 1000, 2000)
		
		if screen_pos.z > 0 then

            -- first test if night
            local sun_obscured = env.secondsSinceMidnight < 4 * 60 * 60 + 40 * 60 or env.secondsSinceMidnight > 19 * 60 * 60 + 15 * 60

            if not sun_obscured then
                local ray = -1000 * gfx_sun_direction()
                local obscurer = physics_sweep_sphere(0.0001, player_ctrl.camPos, ray, true, 0)
                if obscurer ~= nil then
                    sun_obscured = true
                end
            end

			if sun_obscured then
                self.alp = math.max(self.alp - 0.07, 0)
			else
                self.alp = math.min(self.alp + 0.07, 1)
			end
			
            local s_pos = screen_pos.xy

			self.flare[0].position = s_pos
			self.flare[1].position = s_pos		
			self.flare[2].position =  s_pos * vec2(0.9, 0.9)
			self.flare[3].position =  s_pos  * vec2(0.7, 0.7)
			self.flare[4].position =  s_pos  * vec2(0.6, 0.6)
			self.flare[5].position =  s_pos  * vec2(0.4, 0.4)
			self.flare[6].position =  s_pos  * vec2(0.2, 0.2)

            local orientation = -player_ctrl.camYaw
			self.flare[5].orientation = orientation
			self.flare[6].orientation = orientation
		else

            self.alp = self.alp - 0.07

		end

        if self.alp < 0 then
            self.alp = 0
        end

        for i = 0, 6 do
            self.flare[i].alpha = self.alp
        end	
    end;
}
