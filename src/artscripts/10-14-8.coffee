# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/01/2017
# Notes:

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
global.THREE = require('../../lib/three/three.js')
OBJLoader = require('three-obj-loader')
OBJLoader(global.THREE)
require('../../lib/three/canvasrenderer.js')
require('../../lib/three/projector.js')
clColors = require('nice-color-palettes/100')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 5
  numTicks: 1
  # randomizeTicks: true
  bgColor: 'white'
  fillColor: 'black'
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->

  @loader = new THREE.OBJLoader()

  @loader.load('../../lib/obj/BMWX54.obj',
  (obj) ->
    @colors = @chance.pickone clColors
    console.log('colors ->', @colors)

    @scene = new THREE.Scene()
    bg = @colors[@colors.length-1]
    @colors.pop()
    @scene.background = new THREE.Color(bg)
    @camera = new THREE.PerspectiveCamera(35, 1, 1, 10000)
    # @camera.position.z += @chance.integer {min: -10, max: 188}

    # @camera.position.y = 150
    @camera.position.z = 20

    # @light = new THREE.DirectionalLight( 0xffffff, 0.5 )
    # @light.castShadow = true
    # @light.position.y = 190
    # @light.position.z = 590
    # @scene.add @light

    @light = new THREE.PointLight(new THREE.Color( @chance.pickone(@colors) ), 1.2)
    @light.position.set(0,0,12)
    @light.castShadow = true
    @scene.add @light

    @canvas.style = {}
    @renderer = new THREE.CanvasRenderer({
        canvas: @canvas
    })

    @renderer.shadowMapEnabled = true
    @renderer.shadowMapSoft = true

    @renderer.shaadowMapBias = 0.0039
    @renderer.shadowMapDarkness = 0.5
    @renderer.shadowMapWidth = 1024
    @renderer.shadowMapHeight = 1024

    # @renderer.setClearColor(0xffffff, 1)
    # @renderer.setClearColor(0xffffff, 0)
    @renderer.setSize(@width, @height)
    @renderer.setClearColor(0x3399ff)

    cubeSize = @chance.integer {min: 2, max: 5}
    # segments = @chance.integer {min: 1, max: 4}
    segments = 0
    # geometry = new THREE.BoxGeometry(cubeSize,cubeSize,cubeSize, segments, segments, segments)
    geometry = new THREE.BoxGeometry(cubeSize,cubeSize,cubeSize)
    faces = 0
    # hex = '#999'
    while faces < geometry.faces.length
      # hex = Math.random() * 0xffffff
      hex = @chance.pickone @colors
      # hex2 = @chance.pickone @colors
      geometry.faces[faces].color = new THREE.Color( hex );
      geometry.faces[faces + 1].color = new THREE.Color( hex );
      faces += 2

    # material = new THREE.MeshBasicMaterial({
    #   vertexColors: THREE.FaceColors
    #   overdraw: 0.5
    #   # wireframe: @chance.bool()
    # })

    material = new THREE.MeshLambertMaterial({
      color: new THREE.Color( @chance.pickone(@colors) )
      # color: 0xf6546a
      # wireframe: @chance.bool()
    })

    @cube = new THREE.Mesh(geometry, material)
    # @cube.position.y = 150
    @cube.rotation.y = @chance.pickone [-90, -45, 0, 45, 90]
    @cube.rotation.x = @chance.pickone [-90, -45, 0, 45, 90]
    @cube.rotation.z = @chance.pickone [-90, -45, 0, 45, 90]
    @cube.castShadow = true
    @scene.add(@cube)


    planeGeometry = new THREE.PlaneGeometry(1000, 1000, 0)
    planeMaterial = new THREE.MeshBasicMaterial({
        color: 0xffff00
        side: THREE.DoubleSide
    })

    @plane = new THREE.Mesh(planeGeometry, planeMaterial)
    @plane.receiveShadow = true
    @plane.rotation.y = @chance.pickone [-90, -45, 0, 45, 90]
    @plane.rotation.x = @chance.pickone [-90, -45, 45, 90]
    @plane.rotation.z = @chance.pickone [-90, -45, 0, 45, 90]

    @scene.add @plane

  )



  console.log('Making ' + @count + ' particles')
  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 25, max: 500}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    x = (@width / 2 ) + offset.x
    y = (@height / 2 ) + offset.y

    c = d3.hsl('white')
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    {
      x: x
      y: y
      color: c.toString()
    }
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++

  # @cube.rotation.y += @chance.integer {min: -90, max: 90}
  # @cube.rotation.x += @chance.integer {min: -45, max: 45}
  # @cube.rotation.z += @chance.integer {min: -180, max: 180}

  rotateAmount = 12
  # @cube.rotation.y += @chance.integer {min: -rotateAmount, max: rotateAmount}
  # @cube.rotation.x += @chance.integer {min: -rotateAmount, max: rotateAmount}
  # @cube.rotation.z += @chance.integer {min: -rotateAmount, max: rotateAmount}

  # @cube.geometry.parameters.width += @chance.integer {min: -2, max: 2}

  # @camera.position.y += @chance.integer {min: -180, max: 180}

  # @data.forEach((d,i) =>
  #   ###########################
  #   #   Modify each particle  #
  #   ###########################
  #   noiseValue = @simplex.noise2D(d.x, d.y)
  #
  #   if @chance.bool {likelihood: 50}
  #     d.x += @chance.floating {min: -2, max: 2}
  #
  #   if @chance.bool {likelihood: 50}
  #     d.y += @chance.floating {min: -2, max: 2}
  #
  #   # Simplex noise is always random, not seeded
  #   # This will introduce randomness even with the same seed
  #   # Use with care, and for subtle effects
  #   if noiseValue > 0
  #     d.x += @chance.floating {min: -2, max: 2}
  #   else
  #     d.y += @chance.floating {min: -2, max: 2}
  #
  #   ###########################
  #   # Then paint the particle #
  #   ###########################
  #   # @ctx.beginPath()
  #   # @ctx.rect d.x, d.y, 1, 1
  #   # # @ctx.fillStyle = d.color
  #   # @ctx.fillStyle = @fillColor
  #   # @ctx.fill()
  #   # @ctx.closePath()
  # )

  @renderer.render(@scene, @camera)


run = ->
  # If this is being called from the command line
  # --seed foo
  # would set the seed to "foo"
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()
  art.seed = seed
  art.init({save: true})

if(require.main == module)
  run()

module.exports = art
