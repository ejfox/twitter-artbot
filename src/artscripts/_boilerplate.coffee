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
    @seed = seed # The seed for the art

    @chance = new Chance(@seed) # init chance.js - chancejs.com
    @count = 2900 # Max number of particles to create
    @numTicks = 2000 # Max number of times to tick over those particles

    # Randomize count/ticks based on maxes we just set
    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @numTicks})

    # Canvas width and height
    @width = 1700
    @height = 1250
    console.log 'width', @width, 'height', @height

    # Create the canvas with D3 Node
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
  # If this is being called from the command line

  # --seed foo
  # would set the seed to "foo"
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()
  genart = new GenArt(seed)

  # --count 100
  # would make 100 particles
  if argv.count
    genart.count = argv.count

  # --ticks 10
  # would make it tick 10 times
  if argv.ticks
    genart.numTicks = argv.ticks

  genart.init()
  genart.saveFile()

module.exports = GenArt
if(require.main == module)
  run()
