-- (c) Augusto Moura 2014, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `.` {
    alpha = 0;
	size = vec(1500, 1024);
	alp = 1;
    zOrder = 0;
	
	flare = {};
	
    init = function (self)
		self.needsFrameCallbacks = true;

		-- used for keep actual size of screen, updates only when resizes the window
		self.needsParentResizedCallbacks = true;
		self.win_size = gfx_window_size();

		self.flare = {}

		self.flare[0] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare6.png`, size=vec(16, 16), parent = self, colour = vector3(0.085, 1, 0.15)})
		
		self.flare[1] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare6.png`, size=vec(40, 40), parent = self, colour = vector3(0.085, 0.7, 1)})
		
        self.flare[2] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare5.png`, size=vec(2048, 2048), parent = self})
		
		self.flare[3] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare4.png`, size=vec(400, 400), parent = self})
		
		self.flare[4] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare3.png`, size=vec(300, 300), parent = self, colour = vector3(0, 0.75, 0.65)})
		
		self.flare[5] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare2.png`, size=vec(230, 230), parent = self, colour = vector3(1, 0, 0.85)})
		
		self.flare[6] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare2.png`, size=vec(200, 200), parent = self, colour = vector3(1, 0, 0.85)})

        self.flare[7] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare1.png`, needsAlpha = true, size=vec(2048, 256), parent = self})	
		
        self.flare[8] = gfx_hud_object_add(`/common/hud/Rect`, {texture=`Flare0.png`, size=self.size, parent = self})
    end;
    destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
        for i = 0, 8 do
            self.flare[i]:destroy()
        end	
    end;
    frameCallback = function (self, elapsed)

        -- sun_direction is the direction of the rays of light, so invert to point towards the sun
        --
		local sun_pos = player_ctrl.camPos + (gfx_sun_falloff_distance() * gfx_sun_direction() * -1)	

        local screen_pos = gfx_world_to_screen(player_ctrl.camPos, player_ctrl.camDir, sun_pos) - vector3(self.win_size.x/2, self.win_size.y/2, 0)

		local s_pos = screen_pos.xy
		
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
                --self.alp = math.min(self.alp + 0.07, 1)
				-- decreases alpha according by distance of sun position and the center of screen
				self.alp = math.min(math.sqrt((0 - s_pos.x) ^ 2 + (0 - s_pos.y) ^ 2) * -0.0002  + 1, 1)
			end
			
			-- colours
			self.flare[8].colour = gfx_sun_colour()
			self.flare[7].colour = gfx_sun_colour()
			
			-- positions
			self.flare[0].position =  s_pos  * vec2(0.3, 0.3)
			self.flare[1].position =  s_pos  * vec2(0.2, 0.2)
			self.flare[2].position =  s_pos  * vec2(0.4, 0.4)			
			self.flare[3].position =  s_pos  * vec2(0.6, 0.6)			
			self.flare[4].position =  s_pos  * vec2(0.8, 0.8)
			self.flare[5].position =  s_pos  / vec2(0.98, 0.98)
			self.flare[6].position =  s_pos  / vec2(0.95, 0.95)
			self.flare[7].position = s_pos		
			self.flare[8].position = s_pos

			-- increase size with distance
			local dsize = math.min(math.sqrt((self.flare[0].position.x - s_pos.x) ^ 2 + (self.flare[0].position.y - s_pos.y) ^ 2) * 0.07, 32)			
			self.flare[0].size = vec2(dsize*0.85, dsize)			
			dsize = math.min(math.sqrt((self.flare[1].position.x - s_pos.x) ^ 2 + (self.flare[1].position.y - s_pos.y) ^ 2) * 0.2, 100)			
			self.flare[1].size = vec2(dsize*0.7, dsize)
			
			-- rotates around sun position
			for i = 0, 3 do
				local dir = self.flare[i].position
				self.flare[i].orientation = math.deg(math.atan2(dir.x - s_pos.x, dir.y - s_pos.y))	
			end
		else
            -- if the sun is on opposite side of camera, the lensflare fade out
			self.alp = self.alp - 0.07
		end
		
		-- applies final alpha value
        for i = 0, 8 do
            self.flare[i].alpha = self.alp
        end	
    end;
	
	parentResizedCallback = function (self, psize)
		self.win_size = gfx_window_size()
    end;
}
