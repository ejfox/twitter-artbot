# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/01/2017
# Notes:

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
_ = require 'lodash'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
fs = require 'fs'
seed = Date.now()
global.THREE = require('../../lib/three/three.js')
require('../../lib/three/canvasrenderer.js')
require('../../lib/three/projector.js')
clColors = require('nice-color-palettes/100')
OBJLoader = require 'three-obj-loader'
OBJLoader(THREE)

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 25
  randomizeCount: true
  numTicks: 10
  randomizeTicks: true
  bgColor: 'white'
  fillColor: 'black'
}

objData = require('../models/trump.json')

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  # @loader = new THREE.JSONLoader()
  @loader = require('three-json-loader')(THREE)

  fs.readFile('./lib/obj/sniper-tf2.json', (err, data) =>
    if err
      throw err

    @colors = @chance.pickone clColors
    if @chance.bool()
      @colors.push '#FFF'

    @maxSegments = @chance.integer {min: 4, max: 64}

    # @colors = ['#999', '#CCC', '#000', '#FFF']
    console.log('colors ->', @colors)
    @cubes = []
    @scene = new THREE.Scene()
    bg = @colors[@colors.length-1]
    @colors.pop()
    @scene.background = new THREE.Color(bg)
    camSize = @chance.integer {min: 18, max: 72}
    @camera = new THREE.PerspectiveCamera(camSize, 1, 1, 10000)
    # @camera.position.z += @chance.integer {min: -10, max: 188}

    # @camera.position.y = 150
    @camera.position.z = @chance.integer {min: 12, max: 60}
    @camera.rotation.z = @chance.integer {min: -2, max: 2}
    # @camera.rotation.y = @chance.integer {min: -2, max: 2}
    # @camera.rotation.x = @chance.integer {min: -2, max: 2}

    @light = new THREE.PointLight(new THREE.Color( @chance.pickone(@colors) ), 1.2)
    @light.position.set(0,0,12)
    @light.castShadow = true
    @light.position.y = @chance.integer {min: -25, max: 25}
    @light.position.z = @chance.integer {min: 25, max: 90}
    @scene.add @light

    @canvas.style = {}
    @renderer = new THREE.CanvasRenderer({
        canvas: @canvas
    })

    @renderer.shadowMapEnabled = true
    @renderer.shadowMapSoft = true

    @renderer.shaadowMapBias = 0.0039
    @renderer.shadowMapDarkness = @chance.floating {min: 0.1, max: 0.8}
    @renderer.shadowMapWidth = 1024
    @renderer.shadowMapHeight = 1024

    # @renderer.setClearColor(0xffffff, 1)
    # @renderer.setClearColor(0xffffff, 0)
    @renderer.setSize(@width, @height)
    @renderer.setClearColor(0x3399ff)
  


    @renderer.render(@scene, @camera)
  )



  # # @scene.add @plane





  console.log('Making ' + @count + ' particles')
  @data = d3.range(@count).map =>
    {
      sup: 'sup'
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

  # @cube.rotation.y += @chance.integer {min: -rotateAmount, max: rotateAmount}
  # @cube.rotation.x += @chance.integer {min: -rotateAmount, max: rotateAmount}
  # @cube.rotation.z += @chance.integer {min: -rotateAmount, max: rotateAmount}

  # @cube.geometry.parameters.width += @chance.integer {min: -2, max: 2}

  # @camera.position.y += @chance.integer {min: -180, max: 180}



  # @renderer.render(@scene, @camera)


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
