fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
SimplexNoise = require 'simplex-noise'
path = require 'path'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
GenArt = require './GenArt'

# Make new instance
art = new GenArt(seed)
art.filename = path.basename(__filename, '.js') + '-' + seed
art.count = art.width
art.numTicks = 2000
art.bgColor = '#999'
art.fillColor = 'black'
art.simplex = new SimplexNoise

art.makeParticles = ->
  console.log('Making ' + @count + ' particles')
  amp = @chance.integer {min: 20, max: 100}
  @data = d3.range(@count).map (d,i) =>
    # offsetAmount = @chance.integer {min: 25, max: 500}
    # offset = {}
    # offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    # offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    # x = (@width / 2 )
    # x = (@width / 2) * @chance.floating({min: 0.1, max: 1.9})
    # y = (@height / 2) * @chance.floating({min: 0.99, max: 1.01})

    x = i
    y = Math.sin(x*Math.PI/180)

    if y >= 0
      y = (@height / 2) - (y-0) * amp
      d.color = 'red'
    else if y < 0
      y = (@height / 2) + (0-y) * amp
      d.color = 'blue'

    # x = Math.sin(x * Math.PI /180) * 5
    # y = Math.sin(x * Math.PI/180 * 5)

    c = d3.hsl(d.color)
    # c.h += @chance.natural({min: 0, max: 14})
    # c.opacity = @opacity

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
  @theta += 0.02
  #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')

  @data.forEach((d,i) =>
    # Modify the data

    noiseValue = @simplex.noise2D(d.x, d.y) * @chance.integer {min: 1, max: 15}

    # if @chance.bool {likelihood: 50}
    #   d.y += @chance.floating {min: -2, max: 2}
    #
    if @chance.bool {likelihood: 50}
      d.y += noiseValue

    # c = d3.hsl(d.color)
    # c.h += @chance.floating({min: 0.1, max: 2})
    # c.opacity -= 0.001
    # d.color = c.toString()

    # Paint the data
    @ctx.beginPath()
    @ctx.rect d.x, d.y, 1, 1
    @ctx.fillStyle = d.color
    @ctx.fill()
    @ctx.closePath()
  )


if(require.main == module)
  # Make the art
  art.init({save: true})

module.exports = GenArt
