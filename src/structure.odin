package main

import rl "vendor:raylib"
import fmt "core:fmt"

Structure :: struct
{
    using entity: Entity,
    sprite: rl.Texture2D,
    spriteCenter: rl.Vector2,
    placed: bool
}


Structure_new :: proc(_src: rl.Vector2, _textureDims: rl.Vector2, _hitboxDims: rl.Vector2, _outputDims: rl.Vector2, _origin: rl.Vector2, _sprite: rl.Texture2D, _spriteCenter: rl.Vector2) -> Structure
{
    e := Entity_new(_src, _textureDims, _hitboxDims, _outputDims, _origin, EntityType.STRUCTURE)
    s := Structure{e, _sprite, _spriteCenter, false}

    return s
}

Structure_draw :: proc(_structure: ^Structure, _manager: ^Manager)
{ 
    srcRec := rl.Rectangle{_structure.src.x, _structure.src.y, _structure.textureDims.x, _structure.textureDims.y}
    destRec := rl.Rectangle{_structure^.position.x, _structure^.position.y, _structure.hitboxDims.x, _structure.hitboxDims.y}

    offset := -_structure^.spriteCenter
    if !_structure^.placed
    {
        rl.DrawTexturePro(_structure^.sprite, srcRec,  destRec,  rl.Vector2{_structure.hitboxDims.x/2, _structure.hitboxDims.y - _structure.hitboxDims.x/4}, 0.0, rl.GREEN)
    } else
    {
        rl.DrawTexturePro(_structure^.sprite, srcRec,  destRec,  rl.Vector2{_structure.hitboxDims.x/2, _structure.hitboxDims.y - _structure.hitboxDims.x/4}, 0.0, rl.WHITE)
    }
}

Structure_update :: proc(_structure: ^Structure, _manager: ^Manager, _dt: f32)
{ 
    if !_structure^.placed
    {
        _structure^.position = _manager^.currentTilePos
    }
    // fmt.println(_structure^.position)
}