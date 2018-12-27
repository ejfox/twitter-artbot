# Title: 10-1
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
GenArt = require '@ejfox/four-seventeen'


# Make our .png filename (which references the name of the ArtScript)
# For example if your ArtScript was named `_boilerplate`
# Your output would be `_boilerplate-1506887448254.png`
filename = path.basename(__filename, '.js') + '-' + seed

# Set some options for our artscript
options = {
  filename: filename
  count: 25
  numTicks: 100
  bgColor: 'black'
  fillColor: 'white'
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  console.log('Making ' + @count + ' particles')
  offsetAmount = @chance.integer {min: 25, max: 750}
  @data = d3.range(@count).map =>
    targetOffsetAmount = @chance.integer {min: @width/2, max: @width}
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
      targetX: x + @chance.floating({min: -targetOffsetAmount, max: targetOffsetAmount})
      targetY: y + @chance.floating({min: -targetOffsetAmount, max: targetOffsetAmount})
      color: c.toString()
    }
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++

  increase = Math.PI * 2 / @numTicks
  angle = 0

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    # if Math.round(d.x) is Math.round(d.targetX)
    #   d.x = @chance.floating {min: 0, max: @width}
    #
    # if Math.round(d.y) is Math.round(d.targetY)
    #   d.y = @chance.floating {min: 0, max: @height}

    # d.x += 20 * Math.cos( angle ) + 60
    # d.y += 20 * Math.sin( angle ) + 60

    angle += increase

    if @chance.bool {likelihood: 50}
      if d.x < d.targetX
        d.x += @chance.floating {min: 0, max: 2}
      else if d.x < d.targetX
        d.x += @chance.floating {min: -2, max: 0}

    if @chance.bool {likelihood: 50}
      if d.y < d.targetY
        d.y += @chance.floating {min: 0, max: 2}
      else if d.y < d.targetY
        d.y += @chance.floating {min: -2, max: 0}


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
