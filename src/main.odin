package main

import rl "vendor:raylib"
import fmt "core:fmt"
import time "core:time"
import math "core:math"
import linalg "core:math/linalg"
import rand "core:math/rand"


main :: proc()
{
    flags: rl.ConfigFlags = {rl.ConfigFlag.WINDOW_RESIZABLE}
    rl.SetConfigFlags(flags)

    screenWidth: i32 = 1920
    screenHeight: i32 = 1080

    tileDims := rl.Vector2{32.0, 32.0}
    groundDims := rl.Rectangle{0.0, 0.0, 50.0, 50.0}

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")

    fontLocation: cstring = "resources/fonts/CascadiaCode/CascadiaCode.ttf" 

    tile0Location: cstring = "resources/textures/iso_city/PNG/cityTiles_000.png"
    tile1Location: cstring = "resources/textures/iso_city/PNG/cityTiles_001.png"
    tile2Location: cstring = "resources/textures/iso_city/PNG/cityTiles_002.png"

    gameFont := rl.LoadFont(fontLocation)

    tile0 := rl.LoadTexture(tile0Location)
    tile1 := rl.LoadTexture(tile1Location)
    tile2 := rl.LoadTexture(tile2Location)

    hitBoxDims := rl.Vector2{tileDims.x, f32(tile0.height) * (f32(tileDims.x) / f32(tile0.width))}
    spriteCenter := rl.Vector2{f32(hitBoxDims.x)/2, f32(hitBoxDims.y) - f32(tileDims.x)/4}

    s0 := Structure_new(rl.Vector2{0, 0}, rl.Vector2{f32(tile0.width), f32(tile0.height)}, hitBoxDims, hitBoxDims, {0, 0}, tile0, spriteCenter)
    s1 := Structure_new(rl.Vector2{0, 0}, rl.Vector2{f32(tile0.width), f32(tile0.height)}, hitBoxDims, hitBoxDims, {0, 0}, tile1, spriteCenter)
    s2 := Structure_new(rl.Vector2{0, 0}, rl.Vector2{f32(tile0.width), f32(tile0.height)}, hitBoxDims, hitBoxDims, {0, 0}, tile2, spriteCenter)

    structures := make([dynamic]Structure)

    append(&structures, s0)
    append(&structures, s1)
    append(&structures, s2)

    sWidth := rl.GetScreenWidth()
    sHeight := rl.GetScreenHeight()

    center := rl.Vector2{f32(sWidth/2),
                         f32(sHeight/2)
    }

    target := rl.Vector2{f32((tileDims.x/2) * groundDims.width),
                         f32((tileDims.y/2) * groundDims.height)
    }

    camera := rl.Camera2D{center,target, 0.0, 1.0}

    lastTime: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)

    gameManager := Manager_new(
        gameFont,
        screenWidth,
        screenHeight,
        lastTime,
        lastTime,
        camera,
        groundDims,
        tileDims,
        3,
        structures
    )

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() 
    {
        rl.BeginDrawing()
        rl.BeginMode2D(gameManager.camera)

        bgColor := rl.GREEN
        rl.ClearBackground(bgColor)

        now: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)
        dt: f64 = now - lastTime
        lastTime = now

        Manager_update(&gameManager, f32(dt))
        Manager_draw(&gameManager)


        rl.EndMode2D()
        rl.DrawFPS(5, 5)
        rl.EndDrawing()
    }

    rl.CloseWindow()
}