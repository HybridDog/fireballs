-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- Normal Smoke      --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --

minetest.register_node("fireballs:smoke", {
	description = "Smoke",
	drawtype = "plantlike",
	tiles = {{
		name="fireballs_smoke.png",
	}},
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3},
})

minetest.register_abm({
	nodenames = {"fireballs:smoke"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.env:remove_node(pos)
	end,
})

-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --
-- Normal Smokeball  --
-- -- -- -- -- -- -- --
-- -- -- -- -- -- -- --

minetest.register_entity("fireballs:smokeball", {
	visual = "mesh",
	visual_size = {x=5, y=5},
	mesh = "fireballs_smokeball.x",
	textures = {"fireballs_smokeball_texture.png"},
	velocity = 5,
	light_source = 12,
	on_step = function(self, dtime)
			local pos = self.object:getpos()
			if minetest.env:get_node(self.object:getpos()).name ~= "air" then
				self.hit_node(self, pos, node)
				self.object:remove()
				return
			end
			pos.y = pos.y-1
			for _,player in pairs(minetest.env:get_objects_inside_radius(pos, 1)) do
				if player:is_player() then
					self.hit_player(self, player)
					self.object:remove()
					return
				end
			end
		end,
	hit_player = function(self, player)
		local s = player:getpos()
		local p = player:get_look_dir()
		local vec = {x=s.x-p.x, y=s.y-p.y, z=s.z-p.z}
		player:punch(self.object, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=4},
		}, vec)
		local pos = player:getpos()
		for dx=0,1 do
			for dy=0,1 do
				for dz=0,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if (n == "air") then
	minetest.env:add_node(p, {name="fireballs:smoke"})
					end
				end
			end
		end
	end,
	hit_node = function(self, pos, node)
		for dx=-1,1 do
			for dy=-2,1 do
				for dz=-1,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if (n == "air") then
	minetest.env:add_node(p, {name="fireballs:smoke"})
					end
				end
			end
		end
	end
})

minetest.register_tool("fireballs:smokeball", {
	description = "Smokeball",
	inventory_image = "fireballs_smokeball.png",
	on_use = function(itemstack, placer, pointed_thing)
			local dir = placer:get_look_dir();
			local playerpos = placer:getpos();
			local obj = minetest.env:add_entity({x=playerpos.x+0+dir.x,y=playerpos.y+2+dir.y,z=playerpos.z+0+dir.z}, "fireballs:smokeball")
			local vec = {x=dir.x*3,y=dir.y*3,z=dir.z*3}
			obj:setvelocity(vec)
		return itemstack
	end,
	light_source = 12,
})

minetest.register_craft({
output = "fireballs:smokeball",
recipe = {
{'', 'default:leaves', ''},
{'', 'default:torch', ''},
{'', '', ''},
}
})