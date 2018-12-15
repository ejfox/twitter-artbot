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
GenArt = require './../GenArt'

deg2rad = Math.PI / 180

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  numTicks: 6111
  count: 12
  randomizeTicks: true
  randomizeCount: true
  bgColor: 'white'
  constrainEdges: false
}

pointInCircle = (x, y, cx, cy, radius) ->
  distancesquared = (x - cx) * (x - cx) + (y - cy) * (y - cy)
  distancesquared <= radius * radius

pdistance = (x1,y1,x2,y2) ->
  a = x1 - x2
  b = y1 - y2
  c = Math.sqrt( a*a + b*b );

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  console.log('Making ' + @count + ' particles')

  @colors = @chance.pickone clColors

  @ctx.fillStyle = @colors[@colors.length-1]
  @colors.pop()
  @ctx.fillRect(0, 0, @width, @height)

  # composite = @chance.pickone ['source-out', 'multiply', 'screen', 'soft-light', 'xor']
  if @chance.bool {likelihood: 30}
    # composite = @chance.pickone ['multiply', 'screen']
    composite = 'multiply'
    console.log composite
    @ctx.globalCompositeOperation = composite
    @opacity = 0.45


  xposStart = 12#@chance.integer({min: 5, max: 180})
  xpos = xposStart
  ypos = 12#@chance.integer({min: 5, max: 100})
  particleW = 32#@chance.integer({min: 42, max: 192})
  particleH = 32#@chance.integer({min: 42, max: 192})

  @maxRadius = @chance.integer({min: 1, max: 19})


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
        angleStep: @chance.floating { min: 0.01, max: 1}
        targetx: xpos + @chance.integer { min: 25, max: 100}
        targety: ypos + @chance.integer { min: 25, max: 100}
        # xStepAmount: @chance.floating { min: 0.01, max: 5}
        # yStepAmount: @chance.floating { min: 0.01, max: 5}
        xStepAmount: @chance.floating { min: 0.001, max: 1.2}
        yStepAmount: @chance.floating { min: 0.001, max: 1.2}
        radius: @chance.integer { min: 1, max: 8}
        sinRadius: @chance.integer { min: 10, max: @width}
        # height: particleH / 4
        color: c.toString()
        targetColor: @chance.pickone @colors
        angle: @chance.integer { min: 0, max: 359}
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
    noiseValue = @simplex.noise2D(d.x, d.y) * @chance.floating {min: 0.1, max: 0.7}

    d.radius += noiseValue
    d.radius = _.clamp(d.radius, 0, @maxRadius)


    moveAmount = d.radius * @chance.floating {min: 0.06, max: 0.2}
    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -moveAmount, max: moveAmount}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -moveAmount, max: moveAmount}

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # if noiseValue > 0
    #   d.x += @chance.floating {min: -0.5, max: 0.5}
    # else
    #   d.y += @chance.floating {min: -0.5, max: 0.5}



    # xStepAmount = 0.1
    # yStepAmount = 0.5

    xStepAmount = d.xStepAmount * @chance.floating {min: 0.1, max: 0.7}
    yStepAmount = d.xStepAmount * @chance.floating {min: 0.1, max: 0.7}

    d.distance = pdistance(d.x,d.y,d.targetx,d.targety)


    # if noiseValue > 0
    if d.x < d.targetx
      d.x += xStepAmount
    if d.x > d.targetx
      d.x -= xStepAmount

    if d.y < d.targety
      d.y += yStepAmount
    if d.y > d.targety
      d.y -= yStepAmount


    if _.find(@data, (m) -> pointInCircle(d.x, d.y, m.x, m.y, m.radius+d.radius))
      d.x += xStepAmount * 4
      d.y += yStepAmount * 4



    # if @chance.bool {likelihood: 1}
    #   randompoint = @chance.pickone @data
    #   d.x = randompoint.x
    #   d.y = randompoint.y

    if @chance.bool {likelihood: 2}
      randompoint = @chance.pickone @data
      d.targetx = randompoint.x
      d.targety = randompoint.y

    if @chance.bool()
      d.angle += @chance.floating { min: -xStepAmount / 2, max: xStepAmount / 2}


    d.x = d.x + Math.cos(d.angle * deg2rad)
    d.y = d.y + Math.sin(d.angle * deg2rad)

    d.angle += d.angleStep
    # if @chance.bool()
    #   d.angle += d.angleStep
    # else
    #   d.angle += noiseValue * @chance.floating { min: 0.1, max: 1.2}

    if @chance.bool()
      if d.angle > 360
        d.angle = 0
      if d.angle < 0
        d.angle = 360

    c = d3.hsl(d.color)
    c.h += @chance.floating({min: -0.01, max: 0.05})
    c.h = d.distance * 0.01 + @chance.floating {min: 0.1, max: 0.6} + noiseValue
    # c.s += @chance.integer({min: -1, max: 2})
    d.color = c.toString()

    if @constrainEdges
      d.x = _.clamp(d.x, 0+d.radius, @width-d.radius)
      d.y = _.clamp(d.y, 0+d.radius, @height-d.radius)

    ###########################
    # Then paint the particle #
    ###########################
    # @ctx.beginPath()
    # @ctx.arc d.x+1, d.y+2, d.radius+@chance.integer({min: 1, max: 10}), 0, 2*Math.PI
    # @ctx.fillStyle = 'rgba(255,255,255,0.1)'
    # @ctx.fill()

    @ctx.beginPath()
    @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    @ctx.fillStyle = d.color
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
