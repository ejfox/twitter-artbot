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
    # @numTicks = 9000 # Max number of times to tick over those particles

    @opacity = 0.1

    # Canvas width and height
    @width = 600
    @height = 600
    console.log 'width', @width, 'height', @height

    @count = 200
    @numTicks = 5000

    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    # make bg
    @ctx.fillStyle = '#DBE2CE'
    @ctx.fillRect(0, 0, @width, @height)

    if @chance.bool { likelihood: 95 }
      @ctx.globalCompositeOperation = 'multiply'

  init: (options = {}, callback) =>
    @makeParticles()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()

  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    @data = d3.range(@count).map (d,i) =>

      halfWidth = @width / 2
      x = halfWidth + @chance.integer {min: -halfWidth, max: halfWidth}
      y = @height / 2

      colors = ['#FFDE2C', '#FA9921', '#FF0D5D']
      color = @chance.pickone colors
      c = d3.hsl(color)

      {
        radius: 1
        x: x
        y: y
        # color: c.toString()
        color: 'black'
        vx: 0
        vy: 0
      }

  tick: =>
    @ticks++

    @data.forEach((d,i) =>
      c = d3.hsl d.color
      # c.h += @chance.natural({min: 0, max: 90})
      c.opacity = @opacity
      d.color = c.toString()

      d.y = ny


      @ctx.beginPath()
      @ctx.arc(d.x, d.y, d.radius, 0, 2*Math.PI)
      @ctx.closePath()
      @ctx.fillStyle = d.color
      @ctx.fill()
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

  genart.init({save: true})

module.exports = GenArt
if(require.main == module)
  run()
