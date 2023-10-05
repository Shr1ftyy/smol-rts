package main

// import rl "vendor:raylib"
// import fmt "core:fmt"

// Unit :: struct
// {
// 	using entity: Entity,
// 	selected: bool,
// 	moving: bool,
// 	pointToMoveTo: rl.Vector2,
// 	lastPosition: rl.Vector2
// }

// Unit_new :: proc(_hitboxDims: rl.Vector2, _origin: rl.Vector2) -> Unit
// {
//     e := Entity_new(_hitboxDims, _origin, EntityType.UNIT)
//     p := Unit{e, false, false, rl.Vector3{0.0, 0.0}, rl.Vector3{0.0, 0.0}}

//     return p
// }

// Unit_draw :: proc(_unit: ^Unit)
// {
//     if _unit^.selected
//     {
//         rl.DrawCubeWires(_unit^.position, _unit^.hitboxDims.x + 0.2, _unit^.hitboxDims.y + 0.2, _unit^.hitboxDims.z + 0.2, rl.GREEN);
//     }
//     rl.DrawCube(_unit^.position, _unit^.hitboxDims.x, _unit^.hitboxDims.y, _unit^.hitboxDims.z, rl.RED)
// }

// Unit_update :: proc(_unit: ^Unit, _manager: ^Manager, _dt: f32)
// {


// }