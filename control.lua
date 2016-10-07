--require "defines"

DEBUG = false
--[[
General notes for those planning to utilize this API:
 - do not combine entities from multiple mods, unless it's the vehicle 'turrets' included in this APIs
 - add this mod as a dependancy unless you want unexpected weird behavior
 - the teleport command works on many entities besides vehicles, but the behavior is probably not what you might expect.
 Known issues:
 - the bullets shot from turrets appear far from the actual barrel. this is because the bullets may impact other entities on the vehicle
 
--]]


--register_design: registers a multi-entity design with base and subordinate entities
-- subordinate entities will use a direction based translation to remain in sync with the 
-- base entity. (untested) It should be possible to have designs where the base entity is subordinate
-- a different entity. offset is stored as a polar coordinate.
-- format:
-- remote.call("msu_turrets_V1","register_design", {base= <base_entity>, subordinates=
-- {{entity=<subordinate_entity>,rotation = {theta=<num>,r=<num>},shift = {x=<num>, y=<num>}})
--IE: remote.call("msu_turrets_V1","register_design", {base = "msucargowagon", subordinates = {{ entity="msugunturret", rotation = {theta=0,r=0}, shift={x=0,y=0} }} })
--unregister_design: removes an entity registration
-- Note: unregister_design is UNTESTED: designs are removed as needed when mod config changes
-- accepts 1 argument, the name of the entry to be removed:
-- format: 
-- remote.call("msu_turrets_V1","unregister_design", "base_entity_name")



remote.add_interface("msu_turrets_V1", {

	register_design = function(designTable) 
    if not designTable.base or not designTable.subordinates then
      debugPrint("invalid data passed when attempting to register a subordinate design");
      return
    end
    if global.designs[designTable.base] then
      debugPrint("Existing design exists for entity ".. designTable.base)
	  return
    end
    global.designs[designTable.base] = designTable
	debugPrint("design added")
    end,
	
	unregister_design = function(entityName) global.designs[entityTable] = nil end,
})--add_interface

script.on_init( function() on_init_handler() end)
script.on_load( function() on_init_handler() end)
 
-- generate the custom event id
function on_init_handler()
	global.designs = global.designs or {}
	global.subs = global.subs or {}
	script.on_event(defines.events.on_built_entity, function(event) onBuiltEventHandler(event) end)
	script.on_event(defines.events.on_tick, function(event) onTickEventHandler(event) end)
end

script.on_configuration_changed( function() on_mod_changes(data) end)

function on_mod_changes(data)
	local delete = {}
	
	debugPrint(serpent.dump(global.designs))
		for _,design in pairs(global.designs) do
			debugPrint(design.base)
			if not game.entity_prototypes[design.base] then 
				table.insert(delete,design.base)
				debugPrint("design removed due to mod removal: "..design.base)
			end
		end
		for _,entry in ipairs(delete) do
			global.designs[entry] = nil
		end
	debugPrint(serpent.dump(global.designs).." ")
end

function onBuiltEventHandler(event)
--see if we have a matching entity to run this
if not global.designs then return end
  if not global.designs[event.created_entity.name] then return end
	local err, err_text = pcall(addSubordinates, event)
end

-- creates the subordinate entities and then adds them of the list of entity's that need to be updated each tick
function addSubordinates(event)
	debugPrint("adding subs for "..event.created_entity.name)
	design = global.designs[event.created_entity.name]
  surface = event.created_entity.surface
  base = event.created_entity
	for _, subordinate in ipairs(design.subordinates) do
	newSub = surface.create_entity{
    name = subordinate.entity,
    position = base.position,
    force = base.force}
    global.subs[#global.subs+1] = {base_entity = base, sub_entity = newSub, rotation = subordinate.rotation, offset = subordinate.offset, frames =  subordinate.frames, car = subordinate.car}
    --debugPrint(serpent.dump(global.subs))
   
    if not newSub.valid then
      error("subordinate failed to place")
    end
	end

end

--not needed, we will check for an error when the base entity no longer exists
--we will handle the removal of subordinates in the onTickEventHandler
--function removeSubordinates(event)
function onTickEventHandler(event)
    if global.subs == nil then return end
	remove= {}
  for key, entity_pair in pairs(global.subs) do
    if (entity_pair.base_entity.valid and entity_pair.sub_entity.valid) then
    --valid base entity
	  
      entity_pair.sub_entity.teleport(transform(entity_pair.base_entity.position,entity_pair.rotation, entity_pair.offset,  math.floor(entity_pair.base_entity.orientation * entity_pair.frames)/entity_pair.frames))
	  entity_pair.sub_entity.orientation = entity_pair.base_entity.orientation
	  if entity_pair.car then 
		entity_pair.sub_entity.speed = entity_pair.base_entity.speed
	  end
    else
		if (entity_pair.sub_entity.valid) then
			entity_pair.sub_entity.destroy()
		end
	if (entity_pair.base_entity.valid) then
			entity_pair.base_entity.destroy()
	end
    debugPrint("entity_pair invalidated")
      table.insert(remove,key)
    end
  end
  removeInvalidSubordinates(remove)
end

function removeInvalidSubordinates(remove)

  for i,value in pairs(remove) do
    table.remove(global.subs,value)
  end
  
end

--performs pivot on origin and polar/rectangular conversion
function transform(base,rotation,offset,direction)
	--graph: y+ is north, pi/2 is x+
	local theta = direction * math.pi * 2 + rotation.theta - math.pi/2
	if theta > (math.pi*2) then theta = theta - (math.pi *2) end -- 
	return {x = rotation.r * math.cos(theta) + base.x + offset.x, y = rotation.r/1.41421356 * math.sin(theta) + base.y + offset.y }
end

function debugPrint(message)
	if DEBUG then
		for i=1,#game.players,1 do
			game.players[i].print("turretAPIV1: " .. message)
		end
	end
end

function debugTeleport(position)
	if DEBUG then
		for i=1,#game.players,1 do
			game.players[i].teleport(position)
		end
	end
end