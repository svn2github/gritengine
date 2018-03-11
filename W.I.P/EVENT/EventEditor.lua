-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `node_bar` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	draggingPos = vec2(0, 0);
	cornered=true;
	texture=`/common/hud/CornerTextures/Filled04.png`;
	
	
	init = function (self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks = true
		
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging == true then			
			self.parent.parent.position = vec2((select(3, get_mouse_events()) - self.draggingPos.x), (select(4, get_mouse_events()) - self.draggingPos.y))
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = vec2((select(3, get_mouse_events())), (select(4, get_mouse_events()))) - vec2(self.parent.parent.position.x, self.parent.parent.position.y)
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
	
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.size = vec2(self.parent.parent.size.x, self.size.y)
		end
	end;
}

hud_class `CrazyLine` {
	alpha = 1;
	size = vec(200, 5);
	zOrder = 0;
	colour = vector3(1, 1, 1);
	texture = `../icons/line.png`;

	init = function (self)
		self.needsFrameCallbacks = true
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		--print("fgh")
		if self.mnode ~=nil then
			local mmpos = vec2((select(3, get_mouse_events()))-gfx_window_size().x/2, (select(4, get_mouse_events())) - gfx_window_size().y/2 )
			self.orientation = math.deg(math.atan2(mmpos.x - (self.mnode.derivedPosition.x-gfx_window_size().x/2), mmpos.y - (self.mnode.derivedPosition.y-gfx_window_size().y/2)) )+90
			self.position = vec2((mmpos.x + (self.mnode.derivedPosition.x-gfx_window_size().x/2))/2, (mmpos.y+(self.mnode.derivedPosition.y- gfx_window_size().y/2))/2)
			self.size = vec2(math.sqrt(math.pow(mmpos.x - (self.mnode.derivedPosition.x-gfx_window_size().x/2), 2) + math.pow(mmpos.y - (self.mnode.derivedPosition.y- gfx_window_size().y/2),  2)), self.size.y)
		end
	end;

}


hud_class `CrazyLine2` {
	alpha = 1;
	size = vec(200, 5);
	zOrder = 0;
	colour = vector3(1, 1, 1);
	texture = `../icons/line.png`;

	init = function (self)
		self.needsFrameCallbacks = true
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		--print("fgh")
		if self.mnode ~=nil and self.p2 ~=nil then
			local p2pos = vec2(self.p2.derivedPosition.x-gfx_window_size().x/2, self.p2.derivedPosition.y-gfx_window_size().y/2)
			self.orientation = math.deg(math.atan2(p2pos.x - (self.mnode.derivedPosition.x-gfx_window_size().x/2), p2pos.y - (self.mnode.derivedPosition.y-gfx_window_size().y/2)) )+90
			self.position = vec2((p2pos.x + (self.mnode.derivedPosition.x-gfx_window_size().x/2))/2, (p2pos.y+(self.mnode.derivedPosition.y- gfx_window_size().y/2))/2)
			self.size = vec2(math.sqrt(math.pow(p2pos.x - (self.mnode.derivedPosition.x-gfx_window_size().x/2), 2) + math.pow(p2pos.y - (self.mnode.derivedPosition.y- gfx_window_size().y/2),  2)), self.size.y)
		end
	end;

}


-- if crazyline ~= nil then safe_destroy(crazyline)end

-- crazyline = {}
-- crazyline = gfx_hud_object_add(`CrazyLine`, {
	-- parent=hud_center;
-- })

connectingline = nil

editorlines={}

function mconnect(hudobj)
	--print("pa")
	connectingline = hudobj
	return gfx_hud_object_add(`CrazyLine`, {
		parent=hud_center;
		--parent=editor_interface.windows.event_editor;
		mnode=hudobj;
	})
end

function mconnect_definitive(point1, point2)
	connectingline = nil
	editorlines[#editorlines+1] = gfx_hud_object_add(`CrazyLine2`, {
		parent=hud_center;
		--parent=editor_interface.windows.event_editor;
		mnode=point1;
		p2=point2;
	})
end

hud_class `hook_connector` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 0, 0);
	dragging = false;
	type = "input";
	
	init = function (self)
		self.needsInputCallbacks = true
	end;
	
	destroy = function (self)
		self.needsInputCallbacks = false
		safe_destroy(self.templine)
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.texture = `../icons/node_con.png`
			self.templine = mconnect(self)
		-- means that the user is already trying to connect a line that isn`t started by this object (so, if inside, can be the end point of the line)
		elseif ev == "-left" and self.inside and connectingline ~= nil and connectingline ~= self and connectingline.type ~= self.type then
			connectingline.connected = true
			safe_destroy(connectingline.templine)
			mconnect_definitive(connectingline, self)
			self.texture = `../icons/node_con.png`
			self.connected = true
		-- the user not connected to any node, so destroy the line and revert the texture
		elseif ev == "-left" and not self.connected then
			self.dragging = false
			safe_destroy(self.templine)
			self.texture = `../icons/node.png`
        end
    end;
}

hud_class `nodebutton` {

	padding=vec(8,6);

	texture = `../icons/ndx.png`;
	baseColour = vec(1,1,1) * 0.25;
	hoverColour = vec(1, 0.5, 0) * 0.5;
	clickColour = vec(1, 0.5, 0);

	init = function (self)
		self.needsInputCallbacks = true

		self.dragging = false;
		self.inside = false
		if self.greyed == nil then self.greyed = false end

		self:refreshState();
	end;

	destroy = function (self)
	end;

	refreshState = function (self)
		if self.greyed then

			self.colour = self.baseColour
		else

			if self.dragging and self.inside then
				self.colour = self.clickColour
			elseif self.inside then
				self.colour = self.hoverColour
			else
				self.colour = self.baseColour
			end
		end
	end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		self:refreshState()
	end;

	buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
		elseif ev == "-left" then
			if self.dragging and self.inside and not self.greyed then
				self:pressedCallback()
			end
			self.dragging = false
		end
		self:refreshState()
	end;

	pressedCallback = function (self)
		error "Button has no associated action."
	end;
}

hud_class `Node` {
	alpha = 1;
	size = vec(200, 65);
	zOrder = 0;
	colour = vector3(1, 1, 1);
	title = "Level Start";
	lastitem=0;
	
	init = function (self)
		self.needsFrameCallbacks = true
		self.needsInputCallbacks = true

		self.connectors = {}
		self.out_con = {}
		self.var_con = {}
		
		self.draggable_area = gfx_hud_object_add(`node_bar`, {
			self.titlePositioner;
			--position = vec2(0, self.size.y-24);
			size = vec2(self.size.x, 24);
			colour = vector3(0.2, 0.2, 0.2);
			--zOrder = 2;
			alpha=0.9;
		})
		
		self.titleBarPositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self;
			offset = vec2(0, self.draggable_area.size.y/2);
			factor = vec2(0, 0.5);
		})	

		self.draggable_area.parent = self.titleBarPositioner

		self.titlePositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.draggable_area;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		})

		self.window_title = gfx_hud_text_add(`/common/fonts/Arial12`)
		self.window_title.parent = self.titlePositioner
		self.window_title.colour = vector3(1, 1, 1)
		self.window_title.position = vec(0, 0)
		self:setTitle(self.title)
		-- used just for initialize
		self.title = nil


		self.close_btn = gfx_hud_object_add(`nodebutton`, {				
				caption = "";
				padding = vec(15, 2);
				texture=`../icons/ndx.png`;
				needsParentResizedCallbacks = true;
				parentResizedCallback = function(self, psize) self.position = vec2(psize.x/2-self.size.x/2, self.position.y) end;
				baseColour = vec(1,1,1);
				hoverColour = vec(1, 0.5, 0) * 0.75;
				clickColour = vec(1, 0.5, 0);
		})
		
		self.buttonPositioner = gfx_hud_object_add(`/common/hud/Positioner`, {
			parent = self.draggable_area;
			offset = vec2(-self.close_btn.size.x/2-5, 0);
			factor = vec2(0.5, 0);
		})
		
		self.close_btn.parent = self.buttonPositioner 
		self.close_btn.pressedCallback = function (self)
			--self.parent.parent.parent.parent.enabled = false
			print("tt")
		end;

	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
	frameCallback = function (self, elapsed)
		
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside

    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then

		elseif ev == "-left" then

        end
    end;
	
	setTitle = function(self, name)
		self.window_title.text  = name
		self.window_title.position = vec2(self.window_title.size.x / 2, self.window_title.position.y)
	end;


	reorganize = function(self)
	-- Set Node size
		local minsize = 80
		local con_n = math.max(#self.connectors, #self.out_con)
		
		-- find the miminal x size for the node, based on text sizes
		for i=1, #con_n do
			-- if the line have input and output connectors
			if(self.connectors[i] ~= nil and self.out_con[i] ~= nil)then			
				if ((self.connectors[i].titlex.text.size.x + self.out_con[i].titlex.text.size.x) > minsize) then
					minsize = self.connectors[i].titlex.text.size.x + self.out_con[i].titlex.text.size.x + 20
				end
			-- just output
			elseif(self.connectors[i] == nil and self.out_con[i] ~= nil)then
				if (self.out_con[i].titlex.text.size.x > minsize) then
					minsize = self.out_con[i].titlex.text.size.x
				end	
			-- just input
			elseif(self.connectors[i] ~= nil and self.out_con[i] == nil)then
				if (self.connectors[i].titlex.text.size.x > minsize) then
					minsize = self.connectors[i].titlex.text.size.x
				end
			end
		end

		-- if have variable connectors add a extra space
		local var_space = 0
		local var_size = 0
		if self.var_con[1] ~= nil then
			
			for i = 1, #self.var_con do

				
				var_size = var_size + (self.var_con[i].titlex.text.size.x*2)
				
			end
			
			if var_size > minsize then
				minsize = var_size
			end
			
			var_space = 20
		end
		
		minsize = minsize+25
		
		self.size = vec2(minsize or self.size.x, (con_n * 20) + 6 + var_space)

		local cx = {}
		if #self.var_con <= 0 then
			cx = self.size.x
		else
			cx = math.floor(self.size.x/(#self.var_con)+0.7)
		end			
		
		
		if self.var_con[1] ~= nil then
			for i = 1, #self.var_con do
				self.var_con[i].titlex.position = vec(

				
				 ((i-1) * cx) -((cx/2) * (#self.var_con-1))+0.5---self.size.x/2+cx/2

				, -self.size.y/2+10)
				self.var_con[i].titlex.size=vec(cx, self.var_con[i].titlex.size.y)
				self.var_con[i].titlex:updateChildrenSize()
			end
		end	

	-- Set connectors sizes and positions
		-- input
		for i = 1, #self.connectors do
			self.connectors[i].titlex.size = vec2(self.size.x-10, self.connectors[i].titlex.size.y)
			self.connectors[i].titlex.position = vec2(self.connectors[i].titlex.position.x,self.size.y/2 -self.connectors[i].titlex.size.y/2 -self.connectors[i].titlex.size.y*(i-1))
			self.connectors[i].titlex:updateChildrenSize()
			
			-- the hook position
			self.connectors[i].cnt.position = vec2(-self.size.x/2-self.connectors[i].cnt.size.x/2, self.connectors[i].cnt.position.y)
		end
		
		-- output
		for i = 1, #self.out_con do
			self.out_con[i].titlex.size = vec2(self.size.x-10, self.out_con[i].titlex.size.y)
			self.out_con[i].titlex.position = vec2(self.out_con[i].titlex.position.x,self.size.y/2 -self.out_con[i].titlex.size.y/2 - self.out_con[i].titlex.size.y*(i-1))
			self.out_con[i].titlex:updateChildrenSize()
			
			-- the hook position
			self.out_con[i].cnt.position = vec2(self.size.x/2+self.out_con[i].cnt.size.x/2, self.out_con[i].cnt.position.y)
		end
	end;
	
	addConnector = function(self, name)
		self.connectors[#self.connectors+1] = {}
		local mname = name or "None"

		self.connectors[#self.connectors].titlex = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=vec2(self.size.x-5, 20);
			textColour=vec(0, 0, 0);
			alignment="LEFT";
			value=mname;
			alpha=0;
		})		

		-- hook
		self.connectors[#self.connectors].cnt = gfx_hud_object_add(`hook_connector`, {size = vec2(12, 10), parent=self.connectors[#self.connectors].titlex, position=vec2(self.connectors[#self.connectors].titlex.size.x/2+9, 0), colour=vec(1, 1, 1), texture="../icons/node.png", orientation=180, type='input'})
		self:reorganize()
		return self.connectors[#self.connectors]
	end;
	
	addOutConnector = function(self, name)
		self.out_con[#self.out_con+1] = {}

		local mname = name or "None"
		self.out_con[#self.out_con].titlex = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=vec2(self.size.x-5, 20);
			textColour=vec(0, 0, 0);
			alignment="RIGHT";
			value=mname;
			alpha=0;
			colour = random_colour();
		})	
		self.out_con[#self.out_con].cnt = gfx_hud_object_add(`hook_connector`, {size = vec2(12, 10), parent=self.out_con[#self.out_con].titlex, position=vec2(self.out_con[#self.out_con].titlex.size.x/2+9, 0), colour=vec(1, 1, 1), texture="../icons/node.png", type='output'})
		self:reorganize()
		return self.out_con[#self.out_con]
	end;

	addVarConnector = function(self, name)
		self.var_con[#self.var_con+1] = {}
		local mname = name or "None"

		self.var_con[#self.var_con].titlex = gfx_hud_object_add(`/common/hud/Label`, {
			parent = self;
			size=vec2(50, 20);
			textColour=vec(0, 0, 0);
			alignment="CENTER";
			value=mname;
			alpha=1;
			position=vec2(0, -self.size.y/2+10);
			colour = random_colour();
		})
		local ck = 0
		if self.var_con[#self.var_con].titlex.colour.x + self.var_con[#self.var_con].titlex.colour.y + self.var_con[#self.var_con].titlex.colour.z <= 1.5 then
			ck = 1
		end
		self.var_con[#self.var_con].titlex.text.colour = vec(ck, ck, ck)
		self.var_con[#self.var_con].titlex.size = vec(self.var_con[#self.var_con].titlex.text.size.x, self.var_con[#self.var_con].titlex.size.y)
		self.var_con[#self.var_con].titlex:updateChildrenSize()
		-- hook
		self.var_con[#self.var_con].cnt = gfx_hud_object_add(`hook_connector`, { size = vec2(12, 10), parent=self.var_con[#self.var_con].titlex, position=vec2(0, -self.var_con[#self.var_con].titlex.size.y/2-6), colour=vec(1, 1, 1), texture="../icons/node.png", orientation=90, type='var'})
		self:reorganize()
		return self.var_con[#self.var_con]
	end;	
}

event_editor_hud_nodes = {}

event_editor_hud_vars = {}

function event_editor_create_node(ndtype, pos)
	if ndtype == nil then return end
	event_editor_hud_nodes[#event_editor_hud_nodes+1] = gfx_hud_object_add(`Node`, {
		parent = hud_center;
		-- parent=editor_interface.windows.event_editor;
		position = pos or vec(0, 0);
	})
	event_editor_hud_nodes[#event_editor_hud_nodes]:setTitle(ndtype.name or "default")
	
	if ndtype.inputs ~= nil then
		for i = 1, #ndtype.inputs do
			event_editor_hud_nodes[#event_editor_hud_nodes]:addConnector(ndtype.inputs[i])
		end
	end
	
	if ndtype.outputs ~= nil then
		for i = 1, #ndtype.outputs do
			event_editor_hud_nodes[#event_editor_hud_nodes]:addOutConnector(ndtype.outputs[i])
		end
	end
	
	if ndtype.variables ~= nil then
		for i = 1, #ndtype.variables do
			event_editor_hud_nodes[#event_editor_hud_nodes]:addVarConnector(ndtype.variables[i][1])
		end	
	end
end

-- type(tp) == "string"
function create_definitive_node(tp, ps)
	local ndtp = event_editor:get_node_type(tp)
	if ndtp ~= nil then
		local hn = create_node(ndtp)
		event_editor_create_node(hn, ps)
		
	end
end
