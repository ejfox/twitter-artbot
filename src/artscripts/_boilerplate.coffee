fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv

class GenArt
  constructor: (seed) ->
    console.log('Seed:', seed)
    d3n = new d3Node { canvasModule }
    @ticks = 0
    @seed = seed
    @width = 1700
    @height = 1250
    console.log 'width', @width, 'height', @height
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'
    @chance = new Chance(@seed)
    @count = @chance.integer({min: 0, max: 900})

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

    @makeParticles()
    @tickTil(200)
    @saveFile()

  makeParticles: ->
    console.log('Making ' + @count + ' particles')
    chance = new Chance(@seed)
    @data = d3.range(@count).map ->
      x = chance.natural({min: 0, max: @width})
      y = chance.natural({min: 0, max: @height})

      # randOffset = @width
      # if chance.d100() > 50
      #   x -= chance.integer({min: 0, max: randOffset})
      # if chance.d100() > 50
      #   y -= chance.integer({min: 0, max: randOffset})
      # if chance.d100() > 50
      #   x += chance.integer({min: 0, max: randOffset})
      # if chance.d100() > 50
      #   y += chance.integer({min: 0, max: randOffset})

      {
        x: x
        y: y
        color: 'black'
      }
    return @data

  tick: ->
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
    @data.forEach((d,i) =>
      console.log 'x', d.x, 'y', d.y
      @ctx.beginPath()
      @ctx.rect d.x, d.y, 12, 12
      @ctx.fillStyle = d.color
      @ctx.fill()
      @ctx.closePath()
    )

  tickTil: (count) ->
    console.log 'Ticking ' + @data.length + ' particles ' + count + ' times'
    for [0..count]
      @tick()

  saveFile: ->
    fileOutput = './dist/' + @seed + '.png'
    console.log('canvas output --> ' + fileOutput);

    # Save image locally to /dist/
    @canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

run = ->
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()

  art = new GenArt(seed)

module.exports = GenArt
if(require.main == module)
  run()
