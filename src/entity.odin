package main

import rl "vendor:raylib"

EntityType :: enum
{
    PLAYER_TYPE,
    PLAYER_BULLET,
    ENEMY_TYPE,
    ENEMY_BULLET,
    POWERUP_TYPE
}

Entity :: struct
{

    id: EntityId,
    hitboxDims: rl.Vector3,
    position: rl.Vector3,
    type: EntityType,
    destroyed: bool,
}

EntityId :: distinct uint
EntityMap :: distinct map[EntityId]^Entity

Entity_new :: proc(_hitboxDims: rl.Vector3, _origin: rl.Vector3, _entityType: EntityType) -> Entity
{
    @(static) _newId: EntityId = 0
    e := Entity{_newId, _hitboxDims, _origin, _entityType, false}
    _newId += 1

    return e
}

Entity_draw :: proc(_entity: ^Entity)
{

    rl.DrawCube(_entity^.position, _entity^.hitboxDims.x, _entity^.hitboxDims.y, _entity^.hitboxDims.z, rl.GREEN)
    rl.DrawCubeWires(_entity^.position, _entity^.hitboxDims.x, _entity^.hitboxDims.y, _entity^.hitboxDims.z, rl.BLUE)
}

Entity_update :: proc(_entity: ^Entity, _manager: ^Manager, _dt: f32)
{
    if (rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D))
    {
        _entity^.position.x += 0.1 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A))
    {
        _entity^.position.x -= 0.1 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W))
    {
        _entity^.position.z -= 0.1 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S))
    {
        _entity^.position.z += 0.1 * _dt;
    }
}