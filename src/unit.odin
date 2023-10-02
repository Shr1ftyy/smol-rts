package main

import rl "vendor:raylib"
import fmt "core:fmt"

Unit :: struct
{
	using entity: Entity,
	selected: bool,
	moving: bool,
	pointToMoveTo: rl.Vector3,
	lastPosition: rl.Vector3
}

Unit_new :: proc(_hitboxDims: rl.Vector3, _origin: rl.Vector3) -> Unit
{
    e := Entity_new(_hitboxDims, _origin, EntityType.UNIT)
    p := Unit{e, false, false, rl.Vector3{0.0, 0.0, 0.0}, rl.Vector3{0.0, 0.0, 0.0}}

    return p
}

Unit_draw :: proc(_unit: ^Unit)
{
    if _unit^.selected
    {
        rl.DrawCubeWires(_unit^.position, _unit^.hitboxDims.x + 0.2, _unit^.hitboxDims.y + 0.2, _unit^.hitboxDims.z + 0.2, rl.GREEN);
    }
    rl.DrawCube(_unit^.position, _unit^.hitboxDims.x, _unit^.hitboxDims.y, _unit^.hitboxDims.z, rl.RED)
}

Unit_update :: proc(_unit: ^Unit, _manager: ^Manager, _dt: f32)
{
    // if (rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D))
    // {
    //     _unit^.position.x += 0.1 * _dt;
    // }
    // if (rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A))
    // {
    //     _unit^.position.x -= 0.1 * _dt
    // }
    // if (rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W))
    // {
    //     _unit^.position.z -= 0.1 * _dt;
    // }
    // if (rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S))
    // {
    //     _unit^.position.z += 0.1 * _dt;
    // }

    _unit^.lastPosition = _unit^.position

    if (_unit^.moving)
    {
    	directionVec := _unit^.pointToMoveTo - _unit^.position
    	directionVec = norm(directionVec)
    	_unit^.position = _unit^.position + (0.1 * _dt * directionVec) 

    	if
    	(
    		_unit^.position.x >= _unit^.pointToMoveTo.x && _unit^.lastPosition.x < _unit^.pointToMoveTo.x
    		|| _unit^.position.x <= _unit^.pointToMoveTo.x && _unit^.lastPosition.x > _unit^.pointToMoveTo.x
    		|| _unit^.position.y >= _unit^.pointToMoveTo.y && _unit^.lastPosition.y < _unit^.pointToMoveTo.y
    		|| _unit^.position.y <= _unit^.pointToMoveTo.y && _unit^.lastPosition.y > _unit^.pointToMoveTo.y
    		|| _unit^.position.z >= _unit^.pointToMoveTo.z && _unit^.lastPosition.z < _unit^.pointToMoveTo.z
    		|| _unit^.position.z <= _unit^.pointToMoveTo.z && _unit^.lastPosition.z > _unit^.pointToMoveTo.z
		)
		{
			_unit^.moving = false
			_unit^.position = _unit^.pointToMoveTo
		}
    }

    collision: rl.RayCollision = { false, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0} };     // Ray collision hit info
    clicked := false

    if (rl.IsMouseButtonPressed(rl.MouseButton.LEFT))
    {
		fmt.println("clicked")
        if !collision.hit
        {
        	fmt.println("selected")
            ray := rl.GetMouseRay(rl.GetMousePosition(), _manager^.camera);

            // Check collision between ray and box
            collision = rl.GetRayCollisionBox(ray,
                        (rl.BoundingBox){(rl.Vector3){ _unit^.position.x - _unit^.hitboxDims.x/2, _unit^.position.y - _unit^.hitboxDims.y/2, _unit^.position.z - _unit^.hitboxDims.z/2 },
                                      (rl.Vector3){ _unit^.position.x + _unit^.hitboxDims.x/2, _unit^.position.y + _unit^.hitboxDims.y/2, _unit^.position.z + _unit^.hitboxDims.z/2 }});
        	fmt.println(collision)
        	clicked = true
        }
        else
        {
			collision.hit = false;
        } 
    }

    if collision.hit
    {
    	_unit^.selected = true
    }
    else if _unit^.selected && clicked && !collision.hit
    {
    	_unit^.selected = false
    }

    if (rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) && _unit^.selected)
    {
    	pos := rl.GetMousePosition()
    	posRay := rl.GetMouseRay(pos, _manager^.camera)
        // Check collision between ray and floor
        coll := rl.GetRayCollisionBox(posRay,
                    (rl.BoundingBox){(rl.Vector3){ _manager^.groundDims.x - _manager^.groundDims.width/2, 0.0,  _manager^.groundDims.y - _manager^.groundDims.height/2},
                    (rl.Vector3){ _manager^.groundDims.x + _manager^.groundDims.width/2, 0.0,  _manager^.groundDims.y + _manager^.groundDims.height/2}});
        if(coll.hit)
        {
        	_unit^.moving = true
        	_unit^.pointToMoveTo = coll.point
        }
    }

}