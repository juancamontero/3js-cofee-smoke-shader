uniform float uTime;
uniform sampler2D uPerlinTexture;

varying vec2 vUv;

// * Helpers
#include ../includes/rotate2D.glsl

void main() {

    // * 1  set a new position that can be modified
    vec3 newPosition = position;

    // * 3 twist more randomly
    //? We now need to pick the color on the uPerlinTexture using texture().
    //? We want a value that will change according to the elevation only. For this reason, 
    //? as the first value of the vec2() we are sending to texture(), we are going to put 0.5 and use uv.y as the second value.
    float twistPerlin = texture(uPerlinTexture, vec2(0.5, uv.y * 0.2 - uTime * 0.005)).r;

    // *2 Twist
    // float angle = 2.0; 
    //? so the angle changes according to the height
    // float angle = newPosition.y; 

    //? use perlin to change angle
    // float angle = twistPerlin;

    //?Multiply the angle by 10.0 to make the twist stronger:
    float angle = twistPerlin * 10.0;

    //? the rotation will be done in the Y axis, so only the X and Z axes must be moved
    newPosition.xz = rotate2D(newPosition.xz, angle); 

    // * 4 Wind

    //? We’ve selected 0.25 to avoid picking the same line that we used for the twist (which was set at 0.5). 
    //? Additionally, we are using uTime so that it changes in time, resembling a line going up on the Perlin texture
    vec2 windOffset = vec2(
        texture(uPerlinTexture, vec2(0.25, uTime * 0.01)).r - 0.5, 
        texture(uPerlinTexture, vec2(0.75, uTime * 0.01)).r - 0.5
        );
    // windOffset *= uv.y * 10.0; // multiplied by uVu.y so at the bottom stays at cero

    //? We want the strength to be very low at the bottom, to increase slowly at first, and then to increase fast 
    //? when reaching the top of the smoke, which we can get using a power:
    windOffset *= pow(uv.y, 2.0) * 10.0;
    newPosition.xz += windOffset; //First, let’s increase the strength by multiplying windOffset by 10.0:

    // final position
    // gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);

    // Varyings
    vUv = uv;
}