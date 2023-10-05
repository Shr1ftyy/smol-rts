package main

import rl "vendor:raylib"

EntityType :: enum
{
    UNIT,
    STRUCTURE
}

Entity :: struct
{

    id: EntityId,
    src: rl.Vector2,
    textureDims: rl.Vector2,
    hitboxDims: rl.Vector2,
    outputDims: rl.Vector2,
    position: rl.Vector2,
    type: EntityType,
    destroyed: bool,
}

EntityId :: distinct uint
EntityMap :: distinct map[EntityId]^Entity

EntityId_getID :: proc() -> EntityId
{ 
    @(static) _newId: EntityId = 0
    id := _newId
    _newId += 1
    return id
}

Entity_new :: proc(_src: rl.Vector2, _textureDims: rl.Vector2, _hitboxDims: rl.Vector2, _outputDims: rl.Vector2, _origin: rl.Vector2, _entityType: EntityType) -> Entity
{
    _newId := EntityId_getID()
    e := Entity{_newId, _src, _textureDims, _hitboxDims, _outputDims, _origin, _entityType, false}

    return e
}

Entity_draw :: proc(_entity: ^Entity)
{ }

Entity_update :: proc(_entity: ^Entity, _manager: ^Manager, _dt: f32)
{ }