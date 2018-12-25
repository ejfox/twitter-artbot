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
clColors = require('nice-color-palettes/500')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 12
  numTicks: 1200
  bgColor: '#f6f6eb'
  fillColor: 'black'
  randomizeCount: false
  randomizeTicks: false
  radius: 1
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# `makeParticles()` is called at the start of the script and creates
# the particles which are manipulated and drawn on every tick
art.makeParticles = ->
  @colors = @chance.pickone clColors
  @fillColor = @chance.pickone @colors
  # @bgColor = @chance.pickone @colors

  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 0, max: @width / 3}
    offset = {
      x: @chance.floating({min: -offsetAmount, max: offsetAmount})
      y: @chance.floating({min: -offsetAmount, max: offsetAmount})
    }

    x = (@width / 2 ) + offset.x
    y = (@height / 2 ) + offset.y

    c = d3.hsl(@fillColor)
    # c.h += @chance.integer({min: -1, max: 1})
    c.opacity = @opacity

    {
      x: x
      y: y
      radius: @radius
      color: c.toString()
    }
  return @data

# `tick()` is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # noiseValue = @simplex.noise2D(d.x, d.y)
    # d.x += noiseValue
    # d.y += noiseValue

    moveAmount = 2
    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -moveAmount, max: moveAmount}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -moveAmount, max: moveAmount}

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    @ctx.rect d.x, d.y, 1, 1 # Square 1x1 pixel
    # @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI # Or a circle

    @ctx.fillStyle = d.color # Color per-particle
    # @ctx.fillStyle = @fillColor # Or use a global fill color for all

    @ctx.fill()
    @ctx.closePath()
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
