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

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 69
  numTicks: 69
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

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -2, max: 2}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -2, max: 2}

    if noiseValue > 0
      d.x += @chance.floating {min: -2, max: 2}
    else
      d.y += @chance.floating {min: -2, max: 2}

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
  genart = new GenArt(seed, options)
  genart.init({save: true})

if(require.main == module)
  run()

module.exports = art
