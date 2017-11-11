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

class GenArt
  constructor: (seed, options) ->
    @seed = seed # The seed for the art
    @count = 500 # Max number of particles to create
    @numTicks = 1 # Max number of times to tick over those particles
    @bgColor = 'black' # Canvas background color
    @opacity = 1 # Default opacity of our particles
    # @text = 'Hello world!' # The text for our tweet, should we want to overwrite it

    # Canvas width and height
    @width = 1080
    @height = 1080

    if options
      console.log('Options received!', options)
      Object.assign(this, options)

  makeCanvas: ->
    # Create the canvas with D3 Node
    d3n = new d3Node { canvasModule }
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    # Make the background color
    @ctx.fillStyle = @bgColor
    @ctx.fillRect(0, 0, @width, @height)

  init: (options = {}, callback) =>
    # # Randomize count/ticks based on maxes we just set
    # @count = @chance.integer({min: 1, max: @count})
    # @numTicks = @chance.integer({min: 1, max: @numTicks})
    #
    @chance = new Chance(@seed) # init chance.js - chancejs.com
    @simplex = new SimplexNoise() # This is always random despite the seed

    if @randomizeCount
      countMin = _.clamp(@count * 0.25, 1, 100)
      @count = @chance.integer {min: @count * 0.25, max: @count}

    if @randomizeTicks
      @numTicks = @chance.integer {min: @numTicks * 0.1, max: @numTicks}
      if @minTicks
        @numTicks = _.clamp @numTicks, @minTicks, @numTicks

    console.log('----------------------------------------')
    console.log('Init seed:', @seed)
    # console.log('Chance float:', @chance.floating())
    console.log('Chance random:', @chance.random())
    # console.log('Simplex 1,1:', @simplex.noise2D(1,1))
    console.log 'width', @width, 'height', @height

    @makeCanvas()
    @makeParticles()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()


  makeParticles: =>
    console.log('Making ' + @count + ' particles')
    @data = d3.range(@count).map =>
      offsetAmount = 250
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

  tick: =>
    if !@ticks
      ticks = 0
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
    @data.forEach((d,i) =>
      # Modify the data

      if @chance.bool {likelihood: 50}
        d.x += @chance.floating {min: -8, max: 8}

      if @chance.bool {likelihood: 50}
        d.y += @chance.floating {min: -8, max: 8}

      # Paint the data
      @ctx.beginPath()
      @ctx.rect d.x, d.y, 2, 2
      @ctx.fillStyle = d.color
      @ctx.fill()
      @ctx.closePath()
    )

  tickTil: (count) ->
    console.log 'Ticking ' + @data.length + ' particles ' + count + ' times'
    console.time('Ticked for')
    for [0..count]
      @tick()
    console.timeEnd('Ticked for')

  saveFile: (filename, callback) ->
    # console.log 'callback: ', callback
    if !filename and !@filename
      filename = path.basename(__filename, '.js') + '-' + @seed
    else if !filename and @filename
      filename = @filename

    fileOutput = './dist/' + filename + '.png'
    file = fs.createWriteStream(fileOutput)

    # Save image locally to /dist/
    stream = @canvas.pngStream().pipe(file)

    stream.on 'finish', ->
      # console.log 'write stream finished'
      console.log('canvas output --> ' + fileOutput)
      if callback
        callback()

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

if(require.main == module)
  run()

module.exports = GenArt
