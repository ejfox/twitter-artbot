fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Image = canvasModule.Image
Chance = require 'chance'
path = require 'path'
request = require 'request'
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
    @numTicks = 1 # Max number of times to tick over those particles

    # Randomize count/ticks based on maxes we just set
    @count = @chance.integer({min: 1, max: @count})
    #@numTicks = @chance.integer({min: 1, max: @numTicks})

    # Canvas width and height
    @width = 700
    @height = 700
    console.log 'width', @width, 'height', @height

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

  init: (options = {}, callback) =>
    url = 'http://source.unsplash.com/collection/363/#{@width}x#{@height}/'

    request.get({url: url, encoding: null}, (err, res, body) =>
      console.log 'getting'
      if err
        console.log error

      image = new Image()

      image.onerror = ->
        console.log 'error', arguments

      image.onload = =>
        console.log 'loaded image'
        @ctx.drawImage(image, 0, 0)
        @processImage()
        #@makeParticles()
        @tickTil(@numTicks)

        if options.save
          @saveFile()

        if callback
          callback()

      image.src = body
    )

  processImage: =>
    imageData = @ctx.getImageData(0, 0, @width, @height)
    pixels = imageData.data
    pixelData = []

    @count = pixels.length

    hueOffset = 0
    maxOffset = @chance.integer {min: 0, 255}

    @data = d3.range(@count).map (d,i) =>

      if @chance.bool {likelihood: 5}
        i = i - @chance.integer {min: -20, 500}

      x = (i / 4) % @width
      y = Math.floor((i / 4) / @width)

      r = pixels[i]
      g = pixels[i + @chance.integer({min:1, max: 3})]
      b = pixels[i + @chance.integer({min:-1, max: 2})]
      a = pixels[ i + @chance.integer({min:1, max: 3})]

      c = d3.hsl("rgba(#{r},#{g},#{b},#{a})")
      #c.s = 0

      # hueOffset++
      # if hueOffset >= maxOffset
      #   hueOffset = -maxOffset
      # c.h += hueOffset
      # c.h += @chance.integer {min: -25, max: 25}

      # console.log('pixel', x, y, c.toString())

      {
        x: x
        y: y
        color: c.toString()
        c: c
        r: r
        g: g
        b: b
        a: a
      }

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
      #randOffset = 14
      # if d.x < 0
      #   d.x = @width / 2
      # else if d.x > @width
      #   d.x = @width /2
      #
      # if d.y < 0
      #   d.y = @height / 2
      # else if d.y > @height
      #   d.y = @height / 2
      #
      # if @chance.d100() > 50
      #   d.x -= @chance.integer({min: -5, max: 5})
      # if @chance.d100() > 50
      #   d.y -= @chance.integer({min: -5, max: 5})

      # c = d3.hsl d.color
      # c.h += @chance.natural({min: 0, max: 90})
      # d.color = c.toString()

      # console.log 'x', d.x, 'y', d.y

      size = 1
      if @chance.bool { likelihood: 25 }
        size = @chance.natural {min: 0, max: 5}
      #size = @chance.natural {min: 1, max: 5}
      # if @chance.bool {likelihood: 5}
      #   size = 10
      # else
      #   size = 1
      # if @chance.bool {likelihood: 15}
      @ctx.beginPath()
      @ctx.rect (d.x - (size / 2)), (d.y - - (size / 2)), size, size
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

  genart.init({save: true})

module.exports = GenArt
if(require.main == module)
  run()
