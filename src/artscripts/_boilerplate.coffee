fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
path = require 'path'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv

class GenArt
  constructor: (seed) ->
    console.log('Seed:', seed)
    d3n = new d3Node { canvasModule }
    @seed = seed

    @chance = new Chance(@seed)
    @count = 2900
    @numTicks = 2000

    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @numTicks})

    @width = 1700
    @height = 1250
    console.log 'width', @width, 'height', @height


    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

  init: =>
    @makeParticles()
    @tickTil(@numTicks)

  makeParticles: =>
    console.log('Making ' + @count + ' particles')
    @data = d3.range(@count).map =>
      x = @chance.natural({min: 0, max: @width})
      y = @chance.natural({min: 0, max: @height})

      c = d3.hsl('red')
      c.h += @chance.natural({min: 0, max: 14})

      {
        x: x
        y: y
        color: c.toString()
      }
    return @data

  tick: =>
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
    @data.forEach((d,i) =>
      randOffset = 14
      # if d.x < 0
      #   d.x = @width / 2
      # else if d.x > @width
      #   d.x = @width /2
      #
      # if d.y < 0
      #   d.y = @height / 2
      # else if d.y > @height
      #   d.y = @height / 2

      if @chance.d100() > 50
        d.x -= @chance.integer({min: 0, max: randOffset})
      if @chance.d100() > 50
        d.y -= @chance.integer({min: 0, max: randOffset})

      c = d3.hsl d.color
      c.h += @chance.natural({min: 0, max: 90})
      d.color = c.toString()

      # console.log 'x', d.x, 'y', d.y
      @ctx.beginPath()
      @ctx.rect d.x, d.y, 2, 2
      @ctx.fillStyle = d.color
      @ctx.fill()
      @ctx.closePath()
    )

  tickTil: (count) ->
    console.log 'Ticking ' + @data.length + ' particles ' + count + ' times'

    console.time('ticked for')
    for [0..count]
      @tick()
    console.timeEnd('ticked for')

  saveFile: (filename) ->
    if !filename
      filename = path.basename(__filename, '.js') + '-' + @seed
    fileOutput = './dist/' + filename + '.png'
    console.log('canvas output --> ' + fileOutput);

    # Save image locally to /dist/
    @canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

run = =>
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()
  genart = new GenArt(seed)

  if argv.count
    genart.count = argv.count
  if argv.ticks
    genart.numTicks = argv.ticks

  genart.init()
  genart.saveFile()

module.exports = GenArt
if(require.main == module)
  run()
