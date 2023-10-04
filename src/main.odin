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
    rl.InitWindow(800, 450, "raylib [core] example - basic window")

    carModelLocation: cstring = "resources/models/cyberpunk_car/scene.gltf"
    carTextureLocation: cstring = "resources/models/cyberpunk_car/textures/cb_car_baseColor.png"
    carNormalLocation: cstring = "resources/models/cyberpunk_car/textures/cb_car_normal.png"
    carMetalLocation: cstring = "resources/models/cyberpunk_car/textures/cb_car_metallicRoughness.png"

    levelModelLocation: cstring = "resources/models/alien_planet/source/Mesher.obj"
    levelTextureLocation: cstring = "resources/models/alien_planet/textures/SatMaps.png"

    fontLocation: cstring = "resources/fonts/CascadiaCode/CascadiaCode.ttf" 

    carModel := rl.LoadModel(carModelLocation)

    carTexture := rl.LoadTexture(carTextureLocation)
    carNormal := rl.LoadTexture(carNormalLocation)
    carMetal := rl.LoadTexture(carMetalLocation)

    levelModel := rl.LoadModel(levelModelLocation)

    levelTexture := rl.LoadTexture(levelTextureLocation)

    carModel.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = carTexture
    carModel.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture = carNormal
    carModel.materials[0].maps[rl.MaterialMapIndex.METALNESS].texture = carMetal

    levelModel.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = levelTexture

    scale: f32 = 100.0

    // levelModel.transform[0][3] = 0
    // levelModel.transform[1][3] = 0
    // levelModel.transform[2][3] = 0

    levelModel.transform[0][0] *= scale
    levelModel.transform[1][1] *= scale
    levelModel.transform[2][2] *= scale

    // rotation := rl.Matrix{
    //     1, 0, 0, 0,
    //     0, 0, -1, 0,
    //     0, 1, 0, 0,
    //     0, 0, 0, 1
    // } 

    // rotation3x3 := linalg.Matrix3f32{
    //     1, 0, 0,
    //     0, 0, -1,
    //     0, 1, 0,
    // } 

    box := rl.GetModelBoundingBox(levelModel)
    box.min = (scale * box.min)
    box.max = (scale * box.max)

    levelModel.transform[1][3] = box.min.y

    // rotate the terrain -90 degrees since the actual model is rotated lmaooo
    levelModel.transform = levelModel.transform

    gameFont := rl.LoadFont(fontLocation)

    screenWidth := 1280
    screenHeight := 720
    camera := rl.Camera{ { 0.0, 100.0, 300.0 }, { 0.0, 0.0, .0 }, { 0.0, 1.0, 0.0 }, 45.0, rl.CameraProjection.PERSPECTIVE }

    lastTime: f64 = time.duration_milliseconds(transmute(time.Duration)time.now()._nsec)

    gameManager := Manager_new(
        gameFont,
        screenWidth,
        screenHeight,
        lastTime,
        lastTime,
        camera,
        levelModel,
        1.0
    )


    for i := 0; i < 1; i += 1
    {
        u := new(Unit)

        u^ = Unit_new(
            {3.0, 3.0, 3.0},
            {rand.float32() * 25, 3.0, rand.float32() * 25},
            carModel,
            0.01
        )

        pos := rl.Vector2{f32(gameManager.screenWidth/2), f32(gameManager.screenHeight/2)}
        cam := camera

        cam.position = u.position + rl.Vector3{0.0, 500, 0.0}
        cam.target = u.position
        posRay := rl.GetMouseRay(pos, gameManager.camera)

        coll := rl.GetRayCollisionMesh(posRay, gameManager.level.meshes[0], gameManager.level.transform)

        u.position = coll.point

        Manager_addEntity(&gameManager, u)
    }

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() 
    {
        rl.BeginDrawing()
        rl.BeginMode3D(gameManager.camera)


        
        bgColor := rl.Color{8, 36, 52, 255}
        rl.ClearBackground(bgColor)

        rl.DrawBoundingBox(box, rl.RED)

        rl.DrawGrid(10, 10);        // Draw a grid

        // Draw axes
        rl.DrawLine3D(rl.Vector3({0, 0, 0}), rl.Vector3({10, 0, 0}), rl.RED)
        rl.DrawLine3D(rl.Vector3({0, 0, 0}), rl.Vector3({0, 10, 0}), rl.GREEN)
        rl.DrawLine3D(rl.Vector3({0, 0, 0}), rl.Vector3({0, 0, 10}), rl.BLUE)

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