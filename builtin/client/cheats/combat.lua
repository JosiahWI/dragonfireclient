local placed_crystal
local switched_to_totem = 0
local used_sneak = true
local totem_move_action = InventoryAction("move")
totem_move_action:to("current_player", "main", 8)

core.register_globalstep(function(dtime)
	local player = core.localplayer
	if not player then return end
	local control = player:get_control()
	local pointed = core.get_pointed_thing()
	local item = player:get_wielded_item():get_name()
	if core.settings:get_bool("crystal_pvp") then
		if placed_crystal then
			if core.switch_to_item("mobs_mc:totem") then
				switched_to_totem = 5
			end
			placed_crystal = false
		elseif switched_to_totem > 0 then
			if item ~= "mobs_mc:totem"  then
				switched_to_totem = 0
			elseif pointed and pointed.type == "object" then
				pointed.ref:punch()
				switched_to_totem = 0
			else
				switched_to_totem = switched_to_totem
			end
		elseif control.RMB and item == "mcl_end:crystal" then
			placed_crystal = true
		elseif control.sneak then
			if pointed and pointed.type == "node" and not used_sneak then
				local pos = core.get_pointed_thing_position(pointed)
				local node = core.get_node_or_nil(pos)
				if node and (node.name == "mcl_core:obsidian" or node.name == "mcl_core:bedrock") then
					core.switch_to_item("mcl_end:crystal")
					core.place_node(pos)
					placed_crystal = true
				end	
			end
			used_sneak = true
		else
			used_sneak = false
		end
	end
	
	if core.settings:get_bool("autototem") then
		local totem_stack = core.get_inventory("current_player").main[9]
		if totem_stack and totem_stack:get_name() ~= "mobs_mc:totem" then
			local totem_index = core.find_item("mobs_mc:totem")
			if totem_index then
				totem_move_action:from("current_player", "main", totem_index - 1)
				totem_move_action:apply()
				player:set_wield_index(8)
			end
		end
	end
end)
