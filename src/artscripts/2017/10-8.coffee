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
_ = require 'lodash'

deg2rad = Math.PI / 180

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './../GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  # count: 69
  count: 3
  randomizeCount: true
  numTicks: 9960
  randomizeTicks: true
  bgColor: 'white'
  fillColor: 'black'
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
  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 25, max: 300}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    x = (@width / 2 ) + offset.x
    y = (@height / 2 ) + offset.y

    x = _.clamp(x, 0, @width)
    y = _.clamp(y, 0, @height)

    c = d3.hsl('white')
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    {
      x: x
      y: y
      color: c.toString()
      angle: 0
      # angleStep: @chance.floating({min: 0.01, max: 12})
      angleStep: @chance.floating({min: -6, max: 12})
    }

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


    d.angleStep += noiseValue * @chance.floating({min: 0.001, max: 12})
    d.x = d.x + Math.cos(d.angle * deg2rad)
    d.y = d.y + Math.sin(d.angle * deg2rad)

    d.angle += d.angleStep

    d.angleStep = _.clamp(d.angleStep, -12, 12)

    if d.angle > 360
      d.angle = 0

    # if @chance.bool {likelihood: 50}
    #   d.x += @chance.floating {min: -1, max: 1}

    # if @chance.bool {likelihood: 50}
    #   d.y += @chance.floating {min: -1, max: 1}

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # if noiseValue > 0
    #   d.x += @chance.floating {min: -2, max: 2}
    # else
    #   d.y += @chance.floating {min: -2, max: 2}

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    @ctx.rect d.x, d.y, 1, 1
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
