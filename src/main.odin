package main

import rl "vendor:raylib"
import fmt "core:fmt"
import time "core:time"
import rand "core:math/rand"


main :: proc()
{
    rl.InitWindow(800, 450, "raylib [core] example - basic window")
        
    shipTextureLocation: cstring = "resources/textures/ship5.png"
    fontLocation: cstring = "resources/fonts/CascadiaCode/CascadiaCode.ttf" 

    shipTexture := rl.LoadTexture(shipTextureLocation) 
    gameFont := rl.LoadFont(fontLocation)

    screenWidth := 1280
    screenHeight := 720
    camera := rl.Camera{ { 0.0, 50.0, 50.0 }, { 0.0, 0.0, 0.0 }, { 0.0, 1.0, 0.0 }, 90.0, rl.CameraProjection.PERSPECTIVE }


    lastTime: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)

    gameManager := Manager_new(
        gameFont,
        screenWidth,
        screenHeight,
        lastTime,
        lastTime,
        camera
    )


    for i := 0; i < 10; i += 1
    {
        u := new(Unit)

        u^ = Unit_new(
            {3.0, 3.0, 3.0},
            {rand.float32() * 25, 3.0, rand.float32() * 25},
        )

        Manager_addEntity(&gameManager, u)
    }

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() 
    {
        rl.BeginDrawing()
        rl.BeginMode3D(gameManager.camera)

        
        bgColor := rl.Color{8, 36, 52, 255}
        rl.ClearBackground(bgColor)

        rl.DrawGrid(10, 10);        // Draw a grid

        now: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)
        dt: f64 = now - lastTime
        lastTime = now

        // Update
        Manager_update(&gameManager, f32(dt))

        // Draw
        Manager_draw(&gameManager)
        // fmt.println(e)
        rl.EndMode3D()
        rl.DrawFPS(5, 5)

        rl.DrawRectangleLinesEx(gameManager.selectionRect, 2, rl.YELLOW)


        rl.EndDrawing()
    }

    rl.CloseWindow()
}