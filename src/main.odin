package main

import rl "vendor:raylib"
import fmt "core:fmt"
import time "core:time"

main :: proc()
{
    rl.InitWindow(800, 450, "raylib [core] example - basic window")
        
    shipTextureLocation: cstring = "resources/textures/ship5.png"
    fontLocation: cstring = "resources/fonts/CascadiaCode/CascadiaCode.ttf" 

    shipTexture := rl.LoadTexture(shipTextureLocation) 
    gameFont := rl.LoadFont(fontLocation)

    screenWidth := 1280
    screenHeight := 720
    camera := rl.Camera{ { 0.0, 75.0, 100.0 }, { 0.0, 0.0, 0.0 }, { 0.0, 1.0, 0.0 }, 45.0, rl.CameraProjection.PERSPECTIVE }


    lastTime: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)

    gameManager := Manager_new(
        gameFont,
        screenWidth,
        screenHeight,
        lastTime,
        lastTime,
    )

    e := Entity_new(
        {3.0, 3.0, 3.0},
        {0.0, 3.0, 0.0},
        EntityType.PLAYER_TYPE,
    )

    Manager_addEntity(&gameManager, &e)

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() 
    {
        rl.BeginDrawing()
        rl.BeginMode3D(camera)

        
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
        rl.DrawFPS(10, 10)

        // fmt.println(e)
        rl.EndMode3D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}