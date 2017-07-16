fs = require 'fs-extra'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
path = require 'path'
SimplexNoise = require 'simplex-noise'
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

    # @opacity = 0.99
    @opacity = 1

    # Canvas width and height
    @width = 720
    @height = 720
    console.log 'width', @width, 'height', @height

    @text = "Hello world"

    @count = 100
    @numTicks = 9000
    # @numTicks = 320

    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: (@numTicks / 2), max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    @clampNum = @chance.floating {min: 2, max: 12, fixed: 2}

    @simplex = new SimplexNoise()

    # make bg
    bgColor =  d3.hsl('#F5DACF')

    @noiseStep = @chance.floating {min: 0.5, max: 8, fixed: 2}

    # if @chance.bool()
    #   if @chance.bool()
    #     bgColor.h += @chance.floating {min: -92, max: 92, fixed: 2}
    #   else
    #     bgColor.s += @chance.floating {min: -92, max: 92, fixed: 2}

    @ctx.fillStyle = bgColor.toString()
    @ctx.fillRect(0, 0, @width, @height)

    if @chance.bool { likelihood: 15 }
      operation = @chance.pickone ['multiply', 'difference']
      @ctx.globalCompositeOperation = operation

  init: (options = {}, callback) =>
    @makeParticles()
    @makeSimulation()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()

  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    @text += ' ' + @count + ' particles'

    # colors = ['#FA9921', '#FF0D5D', '#ff0dad', '#090645',
    # '#23cf68', '#87d606', '#111e4f', 'rgba(158, 12, 3, 0.5)']
    colors = [ '#FB998C', '#FDC46A', '#749383', '#96B5A3']


    @data = d3.range(@count).map (d,i) =>
      c = @chance.pickone colors
      {
        id: i
        # x: @chance.integer {min: 0, max: @width}
        # y: @chance.integer {min: 0, max: @height}
        # x: @width / 2
        # y: @height / 2
        color: c.toString()
        # color: 'black'
        vx: 10
        opacity: @opacity
        radius: @chance.integer {min: 0.5, max: 4}
      }

  makeSimulation: =>
    @simulation = d3.forceSimulation()
      .force 'collide', d3.forceCollide (d) =>
        d.radius * @chance.integer {min: 2, max: 20}

      if @chance.bool {likelihood: 85}

        centerX = @width / 2
        centerY = @height / 2

        if @chance.bool {likelihood: 20}
          centerX += @chance.integer {min: -200, max: 200}

        if @chance.bool {likelihood: 20}
          centerY += @chance.integer {min: -200, max: 200}

        @simulation.force 'center', d3.forceCenter(centerX, centerY)

      if @chance.bool {likelihood: 45}
        @simulation.force 'charge', d3.forceManyBody().distanceMax(@width/4).strength(10)

      @simulation.nodes @data

    @simulation.stop()

  tick: (callback) =>
    @ticks++


    @simulation.tick()
    @simulation.tick()
    if @chance.bool()
      @simulation.alpha 0.8


    gvy = @chance.floating()
    gvx = @chance.floating()

    stepValue = @chance.floating {min: 0.8, max: 1.6}

    clampNum = @clampNum
    # console.log 'Move clamp: ', clampNum


    # console.log 'tick'
    @data.forEach((d,i) =>
      noiseValue = @simplex.noise2D(d.x, d.y)

      d.radius *= (noiseValue / 2)


      d.x = _.clamp(d.x, 0, @width)
      d.y = _.clamp(d.y, 0, @height)

      d.radius = _.clamp(d.radius, 1, 90)

      c = d3.hsl d.color
      c.opacity = d.opacity
      d.color = c.toString()

      @ctx.beginPath()
      @ctx.arc(d.x, d.y, d.radius, 0, 2*Math.PI)
      @ctx.closePath()
      @ctx.fillStyle = d.color
      @ctx.fill()

      if callback
        callback
    )

  tickTil: (count) =>
    console.log 'Ticking ' + @data.length + ' particles ' + count + ' times'

    console.time('ticked for')
    i = 0
    for [0..count]
      i++
      @tick()

    console.timeEnd('ticked for')

  saveFile: (filename) ->
    if !filename
      filename = path.basename(__filename, '.js') + '-' + @seed
    fileOutput = './dist/' + filename + '.png'

    pngFile = fs.createWriteStream(fileOutput)
    stream = @canvas.pngStream()

    stream.on 'data', (chunk) ->
      pngFile.write chunk

    stream.on 'end', ->
      console.log 'canvas saved --> ' + fileOutput

run = ->
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
