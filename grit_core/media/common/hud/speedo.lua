-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class "Speedo" {
	metricUnits = false;
    init = function (self)
		self.alpha = 0
        self.needsFrameCallbacks = true
		local sz = vector2(108,12)
		self.labels = gfx_hud_object_add("StackY", {
			parent = self,
			padding = -1,
			gfx_hud_object_add("Label", {font = "TinyFont", size=sz }),
			gfx_hud_object_add("Label", {font = "TinyFont", size=sz }),
		})
		self.size = self.labels.size
    end;

    destroy = function (self)
        self.labels = safe_destroy(self.labels)
    end;

    frameCallback = function (self, elapsed)
	
		local x,y,z = unpack(player_ctrl.speedoPos)
        self.labels.contents[1].text.text = string.format("%+5.0f %+5.0f %+5.0f", x, y, z)
		
		local speed_amount = player_ctrl.speedoSpeed
		if type(speed_amount) == "string" then 
			self.labels.contents[2].text.text = speed_amount
		else
			local speed_units
			if self.metricUnits then
			   speed_amount = speed_amount*60*60/1000
			   speed_units="KPH"
			else
			   speed_amount = speed_amount*60*60/METRES_PER_MILE
			   speed_units="MPH"
			end       
			self.labels.contents[2].text.text = string.format("%d %s", speed_amount, speed_units)
		end
    end;
}
