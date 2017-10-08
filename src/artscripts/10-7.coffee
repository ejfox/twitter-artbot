# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/01/2017
# Notes:

# Converts from degrees to radians.
Math.radians = (degrees) ->
  degrees * Math.PI / 180

# Converts from radians to degrees.
Math.degrees = (radians) ->
  radians * 180 / Math.PI

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
_ = require 'lodash'
seed = Date.now()
clColors = require('nice-color-palettes/500')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

deg2rad = Math.PI / 180

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  numTicks: 5000
  count: 24
  randomizeTicks: true
  randomizeCount: true
  bgColor: 'white'
  constrainEdges: true
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  console.log('Making ' + @count + ' particles')

  @colors = @chance.pickone clColors

  @ctx.fillStyle = @chance.pickone @colors
  @ctx.fillRect(0, 0, @width, @height)

  # composite = @chance.pickone ['source-out', 'multiply', 'screen', 'soft-light', 'xor']
  if @chance.bool {likelihood: 30}
    composite = @chance.pickone ['multiply', 'screen']
    console.log composite
    @ctx.globalCompositeOperation = composite

  xposStart = @chance.integer({min: 40, max: 320})
  xpos = xposStart
  ypos = @chance.integer({min: 20, max: 320})
  particleW = @chance.integer({min: 50, max: 300})
  particleH = @chance.integer({min: 50, max: 300})

  @maxRadius = @chance.integer({min: 10, max: 320})


  @data = []

  row = 0
  i = 0
  while row < @count / 2
    column = 0
    c = d3.hsl @chance.pickone @colors
    c.opacity = @opacity
    while column < @count / 2
      @data.push {
        i: i
        x: xpos
        y: ypos
        targetx: xpos + @chance.integer { min: 40, max: 280}
        targety: ypos + @chance.integer { min: 40, max: 280}
        xStepAmount: @chance.floating { min: 0.1, max: 1}
        yStepAmount: @chance.floating { min: 0.1, max: 1}
        radius: @chance.integer { min: 1, max: 4}
        sinRadius: @chance.integer { min: 50, max: 200}
        # height: particleH / 4
        color: c.toString()
        angle: @chance.integer { min: 0, max: 180}
      }
      i++
      xpos += particleW
      column++
    xpos = xposStart
    ypos += particleH
    row++

  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y) * 0.5

    d.radius += noiseValue
    d.radius + _.clamp(d.radius, 0.5, @maxRadius)

    # if @chance.bool {likelihood: 50}
    #   d.x += @chance.floating {min: -2, max: 2}
    #
    # if @chance.bool {likelihood: 50}
    #   d.y += @chance.floating {min: -2, max: 2}

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # if noiseValue > 0
    #   d.x += @chance.floating {min: -2, max: 2}
    # else
    #   d.y += @chance.floating {min: -2, max: 2}



    # xStepAmount = 0.1
    # yStepAmount = 0.5

    xStepAmount = d.xStepAmount * 0.5
    yStepAmount = d.xStepAmount * 0.5


    # if noiseValue > 0
    if d.x < d.targetx
      d.x += xStepAmount
    if d.x > d.targetx
      d.x -= xStepAmount

    if d.y < d.targety
      d.y += yStepAmount
    if d.y > d.targety
      d.y -= yStepAmount

    # if @chance.bool {likelihood: 1}
    #   randompoint = @chance.pickone @data
    #   d.x = randompoint.x
    #   d.y = randompoint.y

    if @chance.bool {likelihood: 3}
      randompoint = @chance.pickone @data
      if @chance.bool {likelihood: 15}
        randompoint = {
          x: @width / 2
          y: @height / 2
        }
      else if @chance.bool
        randompoint = {
          x: @chance.integer {min: 0, max: @width}
          y: @chance.integer {min: 0, max: @height}
        }
      d.targetx = randompoint.x
      d.targety = randompoint.y

    if @chance.bool()
      d.angle += @chance.floating { min: -xStepAmount / 2, max: xStepAmount / 2}

    d.x = d.x + Math.cos(d.angle * deg2rad)
    d.y = d.y + Math.sin(d.angle * deg2rad)
    d.angle += 1

    if d.angle > 360
      d.angle = 0

    c = d3.hsl(d.color)
    # c.h += @chance.floating({min: -0.01, max: 0.05})
    # c.h = d.angle
    # c.s += @chance.integer({min: -1, max: 2})
    d.color = c.toString()

    if @constrainEdges
      d.x = _.clamp(d.x, 0+d.radius, @width-d.radius)
      d.y = _.clamp(d.y, 0+d.radius, @height-d.radius)

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    @ctx.fillStyle = d.color
    @ctx.fill()

    if d.y is d.targety && d.x is d.targetx
      @ctx.beginPath()
      @ctx.arc d.x - (d.radius / 2), d.y - (d.radius / 2), d.radius * 2, 0, 2*Math.PI
      @ctx.fillStyle = 'red'
      @ctx.fill()

    # @ctx.beginPath()
    # # @ctx.rect d.x, d.y, d.width, d.height
    # @ctx.rect d.x, d.y, 1, 1
    # # @ctx.fillStyle = d.color
    # @ctx.fillStyle = @fillColor
    # @ctx.fill()
    # @ctx.closePath()
    #
    # if d.y is d.targety && d.x is d.targetx
    #   @ctx.beginPath()
    #   # @ctx.rect d.x, d.y, d.width, d.height
    #   @ctx.rect d.x-3, d.y-3, 6, 6
    #   # @ctx.fillStyle = d.color
    #   @ctx.fillStyle = 'red'
    #   @ctx.fill()
    #   @ctx.closePath()
  )


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
