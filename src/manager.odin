package main

import rl "vendor:raylib"
import fmt "core:fmt"
import math "core:math"

Manager :: struct
{
    // global game font
    gameFont: rl.Font,
    // screen dimensions
    screenWidth: i32,
    screenHeight: i32,
    // game clock -> used for physics
    lastUpdateTime: f64,
    lastDrawTime: f64,
    // entity map
    entities: EntityMap,
    camera: rl.Camera2D,
    currentlySelected: [dynamic]^Entity,
    selecting: bool,
    selectionRect: rl.Rectangle,
    selectionStart: rl.Vector2,
    selectionEnd: rl.Vector2,
    groundDims: rl.Rectangle,
    tileDims: rl.Vector2,
    cameraOffset: rl.Vector2,
    currentTilePos: rl.Vector2,
    currentBuilding: i32,
    numBuildings: i32,
    buildings: [dynamic]Structure,
    numPlacedBuildings: i32,
    placedBuildings: [dynamic]Structure
};

Manager_new :: proc 
(// global game font
    _gameFont: rl.Font,
    _screenWidth: i32,
    _screenHeight: i32,
    _lastUpdateTime: f64,
    _lastDrawTime: f64,
    _camera: rl.Camera2D,
    _groundDims: rl.Rectangle,
    _tileDims: rl.Vector2,
    _numBuildings: i32,
    _buildings: [dynamic]Structure
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
        _groundDims,
        _tileDims,
        rl.Vector2{0, 0},
        rl.Vector2{0, 0},
        0,
	    _numBuildings,
        _buildings,
        0,
        make([dynamic]Structure)
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

Manager_deleteEntity :: proc
(
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
    if (rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D))
    {
        _manager^.cameraOffset.x += 0.5 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A))
    {
        _manager^.cameraOffset.x -= 0.5 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W))
    {
        _manager^.cameraOffset.y -= 0.5 * _dt;
    }
    if (rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S))
    {
        _manager^.cameraOffset.y += 0.5 * _dt;
    }

    _manager^.camera.zoom += rl.GetMouseWheelMove() * 0.2

    _manager^.currentBuilding = abs(_manager^.currentBuilding + i32(rl.GetMouseWheelMove() * 1)) % (_manager^.numBuildings)

	sWidth := rl.GetScreenWidth()
	sHeight := rl.GetScreenHeight()

    center := rl.Vector2{f32(sWidth/2) - _manager^.cameraOffset.x,
                         f32(sHeight/2) - _manager^.cameraOffset.y
    }

    target := rl.Vector2{f32((_manager^.tileDims.x/2) * _manager^.groundDims.width),
       f32((_manager^.tileDims.y/2) * _manager^.groundDims.height),
    }

    offSet := center - target - _manager^.cameraOffset

    _manager^.camera = rl.Camera2D{center, target, 0.0, _manager^.camera.zoom}

    Structure_update(&_manager^.buildings[_manager^.currentBuilding], _manager, _dt)

    if (rl.IsMouseButtonPressed(rl.MouseButton.LEFT))
    {
    	fmt.println("appended")
	    newStructure := _manager^.buildings[_manager^.currentBuilding]
	    newStructure.placed = true
	    inject_at_elem(&_manager^.placedBuildings, 0, newStructure)
	    _manager^.numPlacedBuildings += i32(1);
	    sort_sprites(&(_manager^.placedBuildings), _manager^.numPlacedBuildings)
    }
}

Manager_draw :: proc
(
    _manager: ^Manager,
)
{
    for i: i32 = 0; i < i32(_manager^.groundDims.width)+1; i += 1
    {
        for j: i32 = 0; j < i32(_manager^.groundDims.height)+1; j += 1
        {
            pos := rl.Vector2{f32(i * i32(_manager^.tileDims.x)), f32(j * i32(_manager^.tileDims.y))}
            // rl.DrawPixel(i32(pos.x), i32(pos.y), rl.BLACK)
            isopos := world_to_iso_transform(pos, _manager.tileDims)
            topLeft := pos + rl.Vector2{-_manager^.tileDims.x/2, -_manager^.tileDims.y/2}
            topLeft = world_to_iso_transform(topLeft, _manager.tileDims)
            topRight := pos + rl.Vector2{_manager^.tileDims.x/2, -_manager^.tileDims.y/2}
            topRight = world_to_iso_transform(topRight, _manager.tileDims)
            bottomRight := pos + rl.Vector2{_manager^.tileDims.x/2, _manager^.tileDims.y/2}
            bottomRight = world_to_iso_transform(bottomRight, _manager.tileDims)
            bottomLeft := pos + rl.Vector2{-_manager^.tileDims.x/2, +_manager^.tileDims.y/2}
            bottomLeft = world_to_iso_transform(bottomLeft, _manager.tileDims)

            points: [^]rl.Vector2
            b := [?]rl.Vector2{topLeft, topRight, bottomRight, bottomLeft, topLeft}
            points = raw_data(b[:])
            rl.DrawLineStrip(points, 5, rl.BLACK)
            rl.DrawPixel(i32(isopos.x), i32(isopos.y), rl.BLUE)
        }
    }

    // selection

    mousePos := rl.GetMousePosition()
    worldPosOG := rl.GetScreenToWorld2D(mousePos, _manager^.camera)
    worldPos := worldPosOG
    worldPos.x = worldPos.x < 0 ? (f32((i32(worldPos.x) / i32(_manager^.tileDims.x))) * _manager^.tileDims.x) - _manager^.tileDims.x/2 : (f32((i32(worldPos.x) / i32(_manager^.tileDims.x))) * _manager^.tileDims.x) + _manager^.tileDims.x/2
    worldPos.y = worldPos.x < 0 ? f32(math.round_f32(f32(i32(worldPos.y) / i32(_manager^.tileDims.y/2)))) * _manager^.tileDims.y/2 : f32(math.round_f32(f32(i32(worldPos.y) / i32(_manager^.tileDims.y/2)))) * _manager^.tileDims.y/2 + _manager^.tileDims.y/2

    selectRect := rl.Rectangle{worldPos.x - _manager^.tileDims.x/2, worldPos.y - _manager^.tileDims.y/4, _manager^.tileDims.x, _manager^.tileDims.y/2}

    // rl.DrawPixel(i32(pos.x), i32(pos.y), rl.BLACK)
    topCorner := worldPos + rl.Vector2{0, -_manager^.tileDims.y/4}
    rightCorner := worldPos + rl.Vector2{_manager^.tileDims.x/2, 0}
    bottomCorner := worldPos + rl.Vector2{0, _manager^.tileDims.y/4}
    leftCorner := worldPos + rl.Vector2{-_manager^.tileDims.x/2, 0}

    // top left corner
    if rl.CheckCollisionPointTriangle(worldPosOG, leftCorner, rl.Vector2{selectRect.x, selectRect.y}, topCorner)
    {
    	worldPos.x -=  _manager^.tileDims.x/2
    	worldPos.y -=  _manager^.tileDims.y/4
    } else if rl.CheckCollisionPointTriangle(worldPosOG, topCorner, rl.Vector2{selectRect.x + _manager^.tileDims.x, selectRect.y}, rightCorner)
    {
    	worldPos.x +=  _manager^.tileDims.x/2
    	worldPos.y -=  _manager^.tileDims.y/4
    } else if rl.CheckCollisionPointTriangle(worldPosOG, rightCorner, rl.Vector2{selectRect.x + _manager^.tileDims.x, selectRect.y + _manager^.tileDims.y/2}, bottomCorner)
    {
    	worldPos.x +=  _manager^.tileDims.x/2
    	worldPos.y +=  _manager^.tileDims.y/4
    } else if rl.CheckCollisionPointTriangle(worldPosOG, bottomCorner, rl.Vector2{selectRect.x , selectRect.y + _manager^.tileDims.y/2}, leftCorner)
    {
    	worldPos.x -=  _manager^.tileDims.x/2
    	worldPos.y +=  _manager^.tileDims.y/4
    }

    topCorner = worldPos + rl.Vector2{0, -_manager^.tileDims.y/4}
    rightCorner = worldPos + rl.Vector2{_manager^.tileDims.x/2, 0}
    bottomCorner = worldPos + rl.Vector2{0, _manager^.tileDims.y/4}
    leftCorner = worldPos + rl.Vector2{-_manager^.tileDims.x/2, 0}

    selectRect = rl.Rectangle{worldPos.x - _manager^.tileDims.x/2, worldPos.y - _manager^.tileDims.y/4, _manager^.tileDims.x, _manager^.tileDims.y/2}

    points: [^]rl.Vector2
    b := [?]rl.Vector2{topCorner, rightCorner, bottomCorner, leftCorner, topCorner}
    points = raw_data(b[:])

    // rl.DrawTriangleLines(leftCorner, rl.Vector2{selectRect.x, selectRect.y}, topCorner, rl.BLUE)
    // rl.DrawTriangleLines(topCorner, rl.Vector2{selectRect.x + _manager^.tileDims.x, selectRect.y}, rightCorner, rl.BLUE)
    // rl.DrawTriangleLines(rightCorner, rl.Vector2{selectRect.x + _manager^.tileDims.x, selectRect.y + _manager^.tileDims.y/2}, bottomCorner, rl.BLUE)
    // rl.DrawTriangleLines(bottomCorner, rl.Vector2{selectRect.x , selectRect.y + _manager^.tileDims.y/2}, leftCorner, rl.BLUE)

    rl.DrawLineStrip(points, 5, rl.RAYWHITE)

	rl.DrawPixel(i32(worldPos.x), i32(worldPos.y), rl.PURPLE)
    _manager^.currentTilePos = worldPos;

    for i: i32 = 0; i < _manager^.numPlacedBuildings; i += 1
    {
	    Structure_draw(&(_manager^.placedBuildings[i]), _manager)

    }
    Structure_draw(&_manager^.buildings[_manager^.currentBuilding], _manager)
    // rl.DrawRectangleLinesEx(selectRect, 1.0, rl.RED)
}