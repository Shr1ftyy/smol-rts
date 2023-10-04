package main

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

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
    camera: rl.Camera,
    currentlySelected: [dynamic]^Entity,
    selecting: bool,
    selectionRect: rl.Rectangle,
    selectionStart: rl.Vector2,
    selectionEnd: rl.Vector2,
    xVec: rl.Vector3,
    yVec: rl.Vector3,
    zVec: rl.Vector3,
    groundDims: rl.Rectangle,
    level: rl.Model,
    levelScale: f32
};

// rl.LoadFontEx("resources/fonts/CascadiaCode/CascadiaCode.ttf", 20, 0, 250);

Manager_new :: proc 
(// global game font
    _gameFont: rl.Font,
    _screenWidth: int,
    _screenHeight: int,
    _lastUpdateTime: f64,
    _lastDrawTime: f64,
    _camera: rl.Camera,
    _level: rl.Model,
    _levelScale: f32
) -> Manager
{
    manager := Manager {
        _gameFont,
        _screenWidth,
        _screenHeight,
        _lastUpdateTime,
        _lastDrawTime,
        make(EntityMap),
        _camera,
        make([dynamic]^Entity),
        false,
        rl.Rectangle{0, 0, 0, 0},
        rl.Vector2{0.0, 0.0},
        rl.Vector2{0.0, 0.0},
        rl.Vector3{0.0, 0.0, 0.0},
        rl.Vector3{0.0, 0.0, 0.0},
        rl.Vector3{0.0, 0.0, 0.0},
        rl.Rectangle{0.0, 0.0, 100.0, 100.0},
        _level,
        _levelScale
    }

    // manager.level.transform[0][0] *= _levelScale
    // manager.level.transform[1][1] *= _levelScale
    // manager.llevel.transform[2][2] *= _levelScale


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
 Manager_deleteEntity :: proc (
    _manager: ^Manager,
    _entity: ^Entity,
)
{
    delete_key(&_manager^.entities, _entity^.id) 
}

Manager_update :: proc
(
    _manager: ^Manager,
    _dt: f32,
)
{
    // rl.UpdateCamera(&(_manager^.camera), rl.CameraMode.FIRST_PERSON)
    if (rl.IsKeyDown(rl.KeyboardKey.W)) { // Move camera forward (W key)
        _manager^.camera.position.z -= 1
        _manager^.camera.target.z -= 1
    }
    if (rl.IsKeyDown(rl.KeyboardKey.S)) { // Move camera backward (S key)
        _manager^.camera.position.z += 1
        _manager^.camera.target.z += 1
    }
    if (rl.IsKeyDown(rl.KeyboardKey.A)) { // Move camera left (A key)
        _manager^.camera.position.x -= 1
        _manager^.camera.target.x -= 1
    }
    if (rl.IsKeyDown(rl.KeyboardKey.D)) { // Move camera right (D key)
        _manager^.camera.position.x += 1
        _manager^.camera.target.x += 1
    }
    
    // Zoom with the mouse wheel
    _manager^.camera.fovy -= rl.GetMouseWheelMove() * 2.0

    if (rl.IsMouseButtonDown(rl.MouseButton.LEFT))
    {
        pos := rl.GetMousePosition()
        if(!_manager^.selecting)
        {
            _manager^.selecting = true

            _manager^.selectionRect.x = pos.x
            _manager^.selectionRect.y = pos.y
            _manager^.selectionStart = pos
        }

        _manager^.selectionEnd = pos

        xOffset := _manager^.selectionEnd.x - _manager^.selectionStart.x
        yOffset := _manager^.selectionEnd.y - _manager^.selectionStart.y

        _manager^.selectionRect.width = abs(xOffset)
        _manager^.selectionRect.height = abs(yOffset)

        if (_manager^.selectionEnd.x < _manager^.selectionStart.x)
        {
            _manager.selectionRect.x = _manager^.selectionEnd.x
        }
        if (_manager^.selectionEnd.y < _manager^.selectionStart.y)
        {
            _manager.selectionRect.y = _manager^.selectionEnd.y
        }
    }    
    else if (!rl.IsMouseButtonDown(rl.MouseButton.LEFT))
    {
        _manager^.selectionRect.width = 0
        _manager^.selectionRect.height = 0
        _manager^.selecting = false
    }

    for id in _manager^.entities
    {

        entity := _manager^.entities[id]
        if entity^.type == EntityType.UNIT
        {
            Unit_update(transmute(^Unit)entity, _manager, _dt)
        }
        else
        {
            Entity_update(entity, _manager, _dt)
        }
    }
}

Manager_draw :: proc
(
    _manager: ^Manager,
)
{
    rl.DrawModel(_manager^.level, {0, 0, 0}, _manager^.levelScale, rl.WHITE)
    rl.DrawCubeWires({_manager^.groundDims.x, 0, _manager^.groundDims.y}, _manager^.groundDims.width, 0.1, _manager^.groundDims.height, rl.PINK)
    // rl.DrawBoundingBox(rl.GetModelBoundingBox(_manager^.level), rl.RED)
    normalMaterial := rl.LoadMaterialDefault()
    // rl.DrawMesh(_manager^.level.meshes[0], normalMaterial, _manager^.level.transform)
    for id in _manager^.entities
    {

        entity := _manager^.entities[id]
        if entity^.type == EntityType.UNIT
        {
            Unit_draw(transmute(^Unit)entity)
        }
        else
        {
            Entity_draw(entity)
        }
    }
}