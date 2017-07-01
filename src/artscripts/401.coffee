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
    @count = 640 # Max number of particles to create
    # @numTicks = 9000 # Max number of times to tick over those particles

    # Randomize count/ticks based on maxes we just set
    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @count * @chance.integer({min: 10, max: 80})})

    # Canvas width and height
    @width = 1700
    @height = 1250
    console.log 'width', @width, 'height', @height

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
    centerCount = @chance.natural {min: 2, max: 32}
    console.log centerCount + ' centers'

    @data = d3.range(@count).map (d,i)=>
      x = @width / 2 #@chance.natural({min: 0, max: @width})
      y = @height / 2 #@chance.natural({min: 0, max: @height})
      #
      c = d3.hsl('black')
      c.opacity = 0.01
      # c.h += @chance.natural({min: 0, max: 14})

      {
        x: x
        y: y
        color: c.toString()
        cnum: i % centerCount
      }


    @centers = d3.range(centerCount).map =>
      divisor = @chance.integer { min: 2, max: 6}
      moveSize = @width / divisor
      x = (@width / 2) + @chance.integer({min: -moveSize, max: moveSize})
      y = (@height / 2) + @chance.integer({min: -moveSize, max: moveSize})
      colors = ['#FFDE2C', '#FA9921', '#FF0D5D']
      if @chance.bool()
        colors.push '#DBE2CE'
      color = @chance.pickone colors
      c = d3.hsl(color)

      {
        x: x
        y: y
        color: c.toString()
      }

  tick: =>
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
    divisor = @chance.integer { min: 1.1, max: 16}
    randOffset = @chance.integer({min: 2, max: @width / divisor})

    if @ticks % 100
      @centers = @centers.forEach (d,i) ->
        if @chance.bool()
          d.x += randOffset
        if @chance.bool()
          d.y += randOffset

    @data.forEach((d,i) =>
      # if d.x < 0
      #   d.x = @width / 2
      # else if d.x > @width
      #   d.x = @width /2
      #
      # if d.y < 0
      #   d.y = @height / 2
      # else if d.y > @height
      #   d.y = @height / 2

      if @chance.bool { likelihood: 50}
        d.x += @chance.integer({min: -randOffset, max: randOffset})
      if @chance.bool { likelihood: 50}
        d.y += @chance.integer({min: -randOffset, max: randOffset})

      if @chance.bool { likelihood: 4}
        d.cnum = @chance.integer {min: 0, max: @centers.length - 1}

      cNum = d.cnum

      center = @centers[cNum]
      centerN = @centers[cNum + 1]
      centerP = @centers[cNum - 1]

      d.x = _.clamp(d.x, center.x - randOffset, center.x + randOffset)
      d.y = _.clamp(d.y, center.y - randOffset, center.y + randOffset)

      c = d3.hsl center.color
      # c.h += @chance.natural({min: 0, max: 90})
      c.opacity = 0.01
      d.color = c.toString()

      # console.log 'x', d.x, 'y', d.y
      @ctx.beginPath()
      # @ctx.moveTo @width / 2, @height / 2
      if @chance.bool {likelihood: 25}
        d.x = center.x
        d.y = center.y
        @ctx.moveTo d.x, d.y

      o1 = @chance.integer {min: -250, max: 250}
      o2 = @chance.integer {min: -250, max: 250}

      @ctx.quadraticCurveTo(d.x + o1,d.y + o2,d.x,d.y);
      # @ctx.rect d.x, d.y, 2, 2
      # @ctx.fillStyle = d.color
      # @ctx.fill()
      # @ctx.closePath()
      @ctx.strokeStyle = d.color
      @ctx.stroke()
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
