# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 03/04/2018
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


clColors = require('nice-color-palettes')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require '@ejfox/four-seventeen'


# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 100
  randomizeCount: true
  numTicks: 8000
  randomizeTicks: true
  bgColor: 'white'
  fillColor: 'black'
  opacity: 0.25
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


  xScale = d3.scaleLinear()
    .domain [1, @count]
    .range [1, @width]


  i = 0
  @data = d3.range(@count).map =>
    i++
    offsetAmount = @chance.integer {min: 12, max: 100}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    # x = (@width / 2 ) #+ offset.x
    x = xScale i
    y = (@height / 2 ) #+ offset.y

    # c = d3.hsl(@chance.pickone(@colors))
    c = d3.hsl(@fillColor)
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    thickness = 1

    if @chance.bool {likelihood: 25}
      thickness = @chance.pickone [1, 2, 4, 8]

    {
      x: x
      y: y
      x1: x
      y1: y
      x2: x #+ @chance.floating({min: -offsetAmount, max: offsetAmount})
      y2: y #+ @chance.floating({min: -offsetAmount, max: offsetAmount})
      color: c.toString()
      thickness: thickness
      v: @chance.integer {min: 1, max: 6}
    }
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++

  @data.forEach((d,i) =>
    # console.log 'd ->', d
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    # d.x = _.clamp d.x, 0, @width
    # d.x1 = _.clamp d.x, 0, @width
    # d.x2 = _.clamp d.x, 0, @width
    #
    # d.y = _.clamp d.y, 0, @height
    # d.y1 = _.clamp d.y, 0, @height
    # d.y2 = _.clamp d.y, 0, @height

    # if @chance.bool {likelihood: 50}
    #   d.x += @chance.floating {min: -d.v, max: d.v}
    #   d.x2 += @chance.floating {min: -d.v, max: d.v}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -d.v, max: d.v}
      d.y1 += @chance.floating {min: -(d.v * 0.5), max: (d.v * 0.5)}
      d.y2 += @chance.floating {min: -d.v, max: d.v}

    # if @chance.bool {likelihood: 2}
    #   d.v = _.clamp d.v, 0, 100
    #   d.v += @chance.floating {min: -d.v, max: d.v}

    # d.x2 = d.x
    # d.y2 = d.y

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects

    d.v = _.clamp d.v, 0, 100
    if noiseValue > 0
      d.x += @chance.floating {min: -d.v, max: d.v}
      d.x1 += @chance.floating {min: -d.v, max: d.v}
      d.x2 += @chance.floating {min: -d.v, max: d.v}
    else
      d.y += @chance.floating {min: -d.v, max: d.v}
      d.y1 += @chance.floating {min: -d.v, max: d.v}
      d.y2 += @chance.floating {min: -d.v, max: d.v}

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    # @ctx.rect d.x, d.y, 1, 1
    # @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    # @ctx.fillStyle = d.color
    @ctx.lineWidth = d.thickness
    @ctx.strokeStyle = d.color

    @ctx.moveTo(d.x1,d.y1)
    @ctx.lineTo(d.x2,d.y2)
    @ctx.stroke()
    # @ctx.fill()
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
