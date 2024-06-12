uniform float uTime;
uniform sampler2D uPerlinTexture; //? sampler2D to store textures

varying vec2 vUv;

void main() {

    // * 3 |Scale and animate
    vec2 smokeUv = vUv; //? cause we cannot modify vUv directly
    smokeUv.x *= 0.5; //? to make bigger
    smokeUv.y *= 0.3; //? to make bigger
    smokeUv.y -= uTime * 0.03;

    //! After a moment, we can only see long lines because the texture isn’t repeating. 
    //! To fix that, in script.js, set the wrapS and wrapT to THREE.RepeatWrapping:

    // * 2 |retrieve texture form uniform
    //! vec4 smoke = texture(uPerlinTexture, vUv);
    //? we need only need one RGB chanel (texture is on gray scale), so make smoke s float
    // float smoke = texture(uPerlinTexture, vUv).r;
    float smoke = texture(uPerlinTexture, smokeUv).r; //? cause we cannot modify vUv directly

    //! the alpha channel must be interpolated so more "holes" of no color can be repruced in the texture
    //? smoothstep performs smooth Hermite interpolation between 0 and 1 when edge0 < x < edge1. 
    //? This is useful in cases where a threshold function with a smooth transition is desired. smoothstep is equivalent to:

    //* 4  Remap
    smoke = smoothstep(0.4, 1.0, smoke);

    // * 5 Edges
    // smoke = 1.0; // todo: for debug, comment!

    //? We are almost done with the fragment, but the edges are too sharp.
    //? To fix that, we are going to use the smoothstep function again in order to lower the alpha “smoothly” on the edges.

    //* left and right
    smoke *= smoothstep(0.0, 0.1, vUv.x);    // * left edge,  multiplied to combine 
    smoke *= smoothstep(1.0, 0.9, vUv.x);    // * right edge,  multiplied to combine 

    //* top and bottom
    smoke *= smoothstep(0.0, 0.1, vUv.y); //* bottom
    smoke *= smoothstep(1.0, 0.4, vUv.y);  //* top

    // Final Color
    // gl_FragColor = vec4(vec3(smoke), 1.0);

    // * 1
    //? When we want to support transparency, we need to set transparent to true in the material
    // gl_FragColor = vec4(vec3(1.0), smoke);

    // * 6 Let’s put a bright brown instead of that white color so that it merges better with the scene:
    gl_FragColor = vec4(0.6, 0.3, 0.2, smoke);
    // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // todo: for debug, comment!

    // * 7 Animate the vertices (on vertex.glsl )

    //? The tonemapping_fragment chunk will add support to the toneMapping. We are not going to set a toneMapping, 
    //? but it’s good practice to anticipate it.
    //? The colorspace_fragment chunk will convert the colors in order to comply with the renderer color space setting.
    #include <tonemapping_fragment> 
    #include <colorspace_fragment>
}
