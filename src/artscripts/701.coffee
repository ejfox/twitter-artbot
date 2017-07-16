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
    @count = 25 # Max number of particles to create
    @numTicks = 8 # Max number of times to tick over those particles

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

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

  init: (options = {}, callback) =>
    @makeParticles()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()


  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    baseText = [ "pushing my cart through the supermarket"
    "today"
    "the thought passed through my mind"
    "that I could start"
    "knocking cans from the shelves and"
    "also rolls of towels, toilet paper,"
    "silver foil,"
    "I could throw oranges, bananas, tomatoes"
    "through the air, I could take cans of"
    "beer from the refrigerated section and"
    "start gulping them, I could pull up"
    "women's skirts, grab their asses,"
    "I could ram my shopping cart through"
    "the plate-glass window..."
    ]


    @data = d3.range(@count).map =>
      x = (@width / 2 ) + @chance.floating({min: -200, max: 200})
      y = (@height / 2 ) + @chance.floating({min: -200, max: 200})

      c = d3.hsl('black')
      # c.h += @chance.natural({min: 0, max: 14})

      {
        x: x
        y: y
        color: c.toString()
        text: @chance.pickone baseText
        radius: @chance.integer {min: 20, max: @width / 2}
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

      textSize = @chance.integer {min: 9, max: 92}

      @ctx.font = textSize + ' serif'

      @ctx.translate d.x, d.y

      text = d.text.split('')

      startAngle = (Math.PI)
      @ctx.textBaseline = 'middle'
      @ctx.textAlign = 'center'

      for i in [0..d.text.length]
        chardWid = textSize / 2
        letter = text[i]
        if letter
          @ctx.rotate (chardWid/2) / (d.radius / 2 - textSize)
          @ctx.fillText(letter, 0, (0 - d.radius / 2 + textSize / 2))
          @ctx.rotate (chardWid/2) / (d.radius / 2 - textSize)
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
