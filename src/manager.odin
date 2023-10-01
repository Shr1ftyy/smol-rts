package main

import rl "vendor:raylib"

Manager :: struct
{
    // global game font
    gameFont: rl.Font,
    // screen dimensions
    screenWidth: int,
    screenHeight: int,
    // game clock -> used for physics
    lastUpdateTime: f64,
    lastDrawTime: f64,
    // entity map
    entities: EntityMap,
    // powerups that need to be spawned in the next frame
    
    // Manager(int _screenWidth, int _screenHeight, Vector2 _topLeft, Vector2 _bottomRight, float _spacing);
    // void addEntity(Entity* _entity);
    // void deleteEntity(EntityId _id);
    // void update();
    // void draw();
};

// rl.LoadFontEx("resources/fonts/CascadiaCode/CascadiaCode.ttf", 20, 0, 250);

Manager_new :: proc 
(// global game font
    _gameFont: rl.Font,
    _screenWidth: int,
    _screenHeight: int,
    _lastUpdateTime: f64,
    _lastDrawTime: f64,
) -> Manager
{

    manager := Manager {
        _gameFont,
        _screenWidth,
        _screenHeight,
        _lastUpdateTime,
        _lastDrawTime,
        make(EntityMap)
    }

    return manager
}

Manager_addEntity :: proc
(
    _manager: ^Manager,
    _entity: ^Entity,
)
{
    _manager^.entities[_entity^.id] = _entity 
}

Manager_update :: proc
(
    _manager: ^Manager,
    _dt: f32,
)
{
    for id in _manager^.entities
    {
        entity := _manager^.entities[id]
        Entity_update(entity, _manager, _dt)
    }
}

Manager_draw :: proc
(
    _manager: ^Manager,
)
{
    for id in _manager^.entities
    {
        entity := _manager^.entities[id]
        Entity_draw(entity)
    }
}