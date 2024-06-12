import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
import GUI from 'lil-gui'
import { GLTFLoader } from 'three/examples/jsm/Addons.js'

import coffeeSmokeVertexShader from './shaders/coffeeSmoke/vertex.glsl'
import coffeeSmokeFragmentShader from './shaders/coffeeSmoke/fragment.glsl'

/**
 * Base
 */
// Debug
const gui = new GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Loaders
const textureLoader = new THREE.TextureLoader()
const gltfLoader = new GLTFLoader()

/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight,
}

window.addEventListener('resize', () => {
  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(
  25,
  sizes.width / sizes.height,
  0.1,
  100
)
camera.position.x = 8
camera.position.y = 10
camera.position.z = 12
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.target.y = 3
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
  antialias: true,
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Model
 */
gltfLoader.load('./bakedModel.glb', (gltf) => {
  gltf.scene.getObjectByName('baked').material.map.anisotropy = 8
  scene.add(gltf.scene)
})

// ********  COFFEE SMOKE  ********

// * PERLIN TEXTURE
const perlinTexture = textureLoader.load('/perlin.png')
perlinTexture.wrapS = THREE.RepeatWrapping
perlinTexture.wrapT = THREE.RepeatWrapping

// Geometry
const smokeGeometry = new THREE.PlaneGeometry(1, 1, 16, 64) //? This number fo segment 'cause will be mor higher than wither

//! these transformation have to be applied to the GEOMETRY not to the MESH
//! in this way 'cause is wanted that the 0,0 of the mesh starts at the bottom of the mes
smokeGeometry.translate(0, 0.5, 0)
smokeGeometry.scale(1.5, 6, 1.5)

// Material
const smokeMaterial = new THREE.ShaderMaterial({
  wireframe: false,
  vertexShader: coffeeSmokeVertexShader,
  fragmentShader: coffeeSmokeFragmentShader,
  transparent: true,
  uniforms: {
    //? Until now, we have been sending uniforms as objects with a value property. While this works fine, Three.js has simplified this process using the Uniform class:
    uPerlinTexture: new THREE.Uniform(perlinTexture),
    uTime: new THREE.Uniform(0),
  },

  side: THREE.DoubleSide,
  depthWrite: false, //? to avoid z fighting
})
// console.log(smokeMaterial.uniforms.uPerlinTexture)
gui.add(smokeMaterial, 'wireframe').name('Smoke wireframe')

// Mesh
const smoke = new THREE.Mesh(smokeGeometry, smokeMaterial)
smoke.position.y = 1.83 //? this is the height of coffee liquid

scene.add(smoke)

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () => {
  const elapsedTime = clock.getElapsedTime()

  // * Update smoke
  smokeMaterial.uniforms.uTime.value = elapsedTime

  // Update controls
  controls.update()

  // Render
  renderer.render(scene, camera)

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()
