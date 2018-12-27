# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 02/24/2018
# Notes: GETTIN BACK AT IT

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
_ = require 'lodash'
clColors = require('nice-color-palettes/500')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require '@ejfox/four-seventeen'


# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 64
  randomizeCount: true
  numTicks: 1500
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
  @colors = @chance.pickone clColors

  @fillColor = @chance.pickone @colors
  @bgColor = @chance.pickone @colors

  if @fillColor is @bgColor
    @bgColor = 'white'

  @ctx.fillStyle = @bgColor
  @ctx.fillRect(0, 0, @width, @height)

  @radiusMax = @chance.integer {min: 2, max: 12}

  console.log('Making ' + @count + ' particles')
  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 25, max: 500}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    x = (@width / 2 ) + offset.x
    y = (@height / 2 ) + offset.y

    c = d3.hsl(@fillColor)
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    if @chance.bool {likelihood: 50}
      @radiusMax++

    {
      x: x
      y: y
      color: c.toString()
      # radius: 2
      radius: @chance.integer {min: 1, max: @radiusMax}
      opacity: 0.9
    }
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    d.radius += noiseValue * 0.1

    if @chance.bool {likelihood: 50}
      d.opacity += noiseValue * 0.1

    d.radius = _.clamp d.radius, 0.1, @width
    d.opacity = _.clamp d.opacity, 0.1, 1

    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -2, max: 2}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -2, max: 2}

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    d.x += @chance.floating {min: -d.radius*0.9, max: d.radius*0.9}
    d.y += @chance.floating {min: -d.radius*0.9, max: d.radius*0.9}

    c = d3.hsl d.color
    c.opacity = d.opacity
    @fillColor = c.toString()

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    # @ctx.rect d.x, d.y, 1, 1
    @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    # @ctx.fillStyle = d.color
    @ctx.fillStyle = @fillColor
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
