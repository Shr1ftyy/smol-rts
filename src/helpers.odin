package main

import math "core:math"
import intrinsics "core:intrinsics"

cross_3d :: proc(a, b: $T/[3]$E) -> T
where intrinsics.type_is_numeric(E) 
{
	x := a[1]*b[2] - a[2]*b[1]
	y := a[2]*b[0] - a[0]*b[2]
	z := a[0]*b[1] - a[1]*b[0]
	return T{x, y, z}
}

mag :: proc(vec: $T/[3]$E) -> E
where intrinsics.type_is_numeric(E)
{
	mag := math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2])
	return mag
}


norm :: proc(vec: $T/[3]$E) -> T
where intrinsics.type_is_numeric(E)
{
	mag := mag(vec)
	b := T{vec[0] / mag, vec[1] / mag, vec[2] / mag} 
	return b
}


// RotateVector3D rotates a 3D vector around the origin by specified angles.
rotate_3d :: proc(v: $T/[3]$E, angleX, angleY, angleZ: f32) -> T 
where intrinsics.type_is_numeric(E) 
{
    // Convert angles to radians
    radiansX := angleX * (math.PI / 180)
    radiansY := angleY * (math.PI / 180)
    radiansZ := angleZ * (math.PI / 180)

    // Compute sin and cos values for each angle
    sinX := f32(math.sin_f64(f64(radiansX)))
    cosX := f32(math.cos_f64(f64(radiansX)))
    sinY := f32(math.sin_f64(f64(radiansY)))
    cosY := f32(math.cos_f64(f64(radiansY)))
    sinZ := f32(math.sin_f64(f64(radiansZ)))
    cosZ := f32(math.cos_f64(f64(radiansZ)))

    // Perform the rotation
    newX := v[0]*(cosY*cosZ) + v[1]*(sinX*sinY*cosZ-cosX*sinZ) + v[2]*(cosX*sinY*cosZ+sinX*sinZ)
    newY := v[0]*(cosY*sinZ) + v[1]*(sinX*sinY*sinZ+cosX*cosZ) + v[2]*(cosX*sinY*sinZ-sinX*cosZ)
    newZ := -v[0]*sinY + v[1]*sinX*cosY + v[2]*cosX*cosY

    return T{newX, newY, newZ}
}