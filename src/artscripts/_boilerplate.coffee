fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
# SimplexNoise = require 'simplex-noise'
path = require 'path'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
GenArt = require './GenArt'

# Make new instance
art = new GenArt(seed)
art.filename = path.basename(__filename, '.js') + '-' + seed
art.count = 8
art.numTicks = 5000
art.bgColor = 'white'
art.fillColor = 'black'
# art.simplex = new SimplexNoise

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

art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++
  #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
  @data.forEach((d,i) =>
    # Modify the data

    noiseValue = @simplex.noise2D(d.x, d.y)

    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -2, max: 2}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -2, max: 2}

    if noiseValue > 0
      d.x += @chance.floating {min: -2, max: 2}
    else
      d.y += @chance.floating {min: -2, max: 2}

    # Paint the data
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
  genart = new GenArt(seed)
  genart.init({save: true})

if(require.main == module)
  run()

module.exports = art
