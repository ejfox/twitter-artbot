fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Canvas = require 'canvas'
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
    @count = 50 # Max number of particles to create
    @numTicks = 20 # Max number of times to tick over those particles

    # Randomize count/ticks based on maxes we just set
    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @numTicks})

    # Canvas width and height
    @width = 1250
    @height = 1250
    console.log 'width', @width, 'height', @height

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    # Canvas.registerFont '../fonts/InputMonoCondensed-Bold.ttf', {
    #   family: 'InputCompressedBold'
    # }

    # make bg
    @ctx.fillStyle = 'white'
    @ctx.fillRect(0, 0, @width, @height)

  init: (options = {}, callback) =>
    @makeParticles()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()


  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    baseText = [ "We are all alone, born alone,"
    "die alone, and—in spite of True Romance magazines"
    "we shall all someday look back"
    "on our lives and see that, in spite of our company,"
    "we were alone the whole way."
    "I do not say lonely—at least, not all the time"
    "but essentially, and finally, alone."
    "This is what makes your self-respect so important,"
    "and I don't see how you can respect yourself"
    "if you must look in the hearts and minds of others"
    "for your happiness."
    ]

    i = 0
    @data = d3.range(@count).map =>
      i++
      x = (@width / 2 ) #+ @chance.floating({min: -200, max: 200})
      # y = (@height / 2 ) + @chance.floating({min: -200, max: 200})

      y = (@height / 2 )

      c = d3.hsl('black')
      # c.h += @chance.natural({min: 0, max: 14})

      {
        x: x
        y: y
        i: i
        color: c.toString()
        text: @chance.pickone baseText
        radius: @chance.integer {min: 18, max: @width / 2}
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

      if @chance.bool()
        @ctx.beginPath()
        @ctx.rect d.x - (d.radius / 2), d.y - (d.radius / 2), d.radius, d.radius
      else
        @ctx.beginPath()
        @ctx.arc(d.x, d.y, d.radius, 0, 2*Math.PI)
        @ctx.closePath()


      # @ctx.fill()
      @ctx.strokeStyle = 'rgba(10,7,7,0.2)'
      @ctx.stroke()

      textSize = (d.radius / 16) + @chance.integer {min: 1, max: 92}

      # @ctx.font = textSize + ' serif'
      @ctx.font = textSize + ' InputCompressedBold'

      @ctx.fillStyle = d.color
      @ctx.translate d.x, d.y

      text = d.text.split('')

      startAngle = (Math.PI)
      @ctx.textBaseline = 'middle'
      @ctx.textAlign = 'center'

      for i in [0..d.text.length]
        chardWid = textSize / @chance.floating {min: 0.5, max: 2}

        if @chance.bool {likelihood: 5}
          chardWid *= 1.5

        letter = text[i]

        if letter is 'e'
          if @chance.bool {likelihood: 5}
            letter = '3'

        if letter is 'o'
          if @chance.bool {likelihood: 5}
            letter = '0'
          else if @chance.bool {likelihood: 5}
            letter = 'ō'

        if letter is 'E'
          if @chance.bool {likelihood: 5}
            letter = '3'
          else if @chance.bool {likelihood: 5}
            letter = '{'

        if letter is '.'
          if @chance.bool {likelihood: 5}
            letter = '^'
          else if @chance.bool {likelihood: 5}
            letter = '>>>'

        if letter is 'x'
          if @chance.bool {likelihood: 5}
            letter = 'X'
          else if @chance.bool {likelihood: 5}
            letter = 'xxx'

        
        if letter
          @ctx.rotate (chardWid/2) / (d.radius - textSize)
          @ctx.fillText(letter, 0, (0 - d.radius + textSize / 2))
          @ctx.rotate (chardWid/2) / (d.radius - textSize)
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
