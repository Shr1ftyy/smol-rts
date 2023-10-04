package main

import rl "vendor:raylib"
import fmt "core:fmt"

Unit :: struct
{
	using entity: Entity,
	selected: bool,
	moving: bool,
	pointToMoveTo: rl.Vector3,
	lastPosition: rl.Vector3,
    model: rl.Model,
    modelScale: f32,
    yRotation: f32
}

Unit_new :: proc(_hitboxDims: rl.Vector3, _origin: rl.Vector3, _model: rl.Model, _scale: f32) -> Unit
{
    e := Entity_new(_hitboxDims, _origin, EntityType.UNIT)
    p := Unit{e, true, false, rl.Vector3{0.0, 0.0, 0.0}, rl.Vector3{0.0, 0.0, 0.0}, _model, _scale, 0.0}

    return p
}

Unit_draw :: proc(_unit: ^Unit)
{
    if _unit^.selected
    {
        rl.DrawModelWires(_unit^.model, _unit^.position, _unit^.modelScale, rl.GREEN)
    }
    rl.DrawModel(_unit^.model, _unit^.position, _unit^.modelScale, rl.WHITE)
    rl.DrawLine3D(_unit^.position, _unit^.position + rl.Vector3{0, 300, 0}, rl.YELLOW)
}

Unit_update :: proc(_unit: ^Unit, _manager: ^Manager, _dt: f32)
{
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

            transform := _unit^.model.transform
            transform[0][0] *= _unit^.modelScale
            transform[1][1] *= _unit^.modelScale
            transform[2][2] *= _unit^.modelScale

            transform[0][3] = _unit^.position.x
            transform[1][3] = _unit^.position.y
            transform[2][3] = _unit^.position.z

            // Check collision between ray and box
            collision = rl.GetRayCollisionMesh(ray, _unit^.model.meshes[0], transform)
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
        coll := rl.GetRayCollisionMesh(posRay, _manager^.level.meshes[0], _manager^.level.transform)
        fmt.println(coll)

        if(coll.hit)
        {
        	_unit^.moving = true
        	_unit^.pointToMoveTo = coll.point
        }
    }

}