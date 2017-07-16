fs = require 'fs-extra'
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

    @opacity = 0.99

    # Canvas width and height
    @width = 900
    @height = 900
    console.log 'width', @width, 'height', @height

    @text = "Hello world"

    @count = 99
    @numTicks = 9999
    # @numTicks = 320

    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 50, max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    @clampNum = @chance.floating {min: 2, max: 12, fixed: 2}

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

    @text += ' ' + @count + ' particles'

    # colors = ['#FA9921', '#FF0D5D', '#ff0dad', '#090645',
    # '#23cf68', '#87d606', '#111e4f', 'rgba(158, 12, 3, 0.5)']
    colors = ['']
    color = @chance.pickone colors

    circleSize = @chance.integer {min: 6, max: @width / 20}
    circleCount = @chance.integer {min: 2, max: 6}
    circleColor = @chance.pickone colors

    @centers = d3.range(circleCount).map (d,i) =>
      cColor = @chance.pickone colors
      x = @chance.integer {min: 0, max: @width}
      # x = @width / 2
      y = @chance.integer {min: 0, max: @height}
      # y = 0
      # @ctx.beginPath()
      # @ctx.arc(x, y, circleSize, 0, 2*Math.PI)
      # @ctx.closePath()
      # @ctx.fillStyle = cColor
      # @ctx.fill()
      return {
        x: x
        y: y
        color: cColor
      }

    @data = d3.range(@count).map (d,i) =>

      halfWidth = @width / 2
      x = halfWidth + @chance.integer {min: -halfWidth, max: halfWidth}
      #y = @height / 2
      # y = @chance.integer {min: 0, max: 40}
      y = 0
      c = d3.hsl(color)

      {
        id: i
        radius: 1
        x: x
        y: y
        color: c.toString()
        # color: 'black'
        opacity: @opacity
        vx: 0
        vy: 0
        dead: false
        deadmarked: false
        cattraction: @chance.integer {min: 1.2, max: 9}
        center: @chance.integer {min: 0, max: @centers.length - 1}

      }

  tick: (callback) =>
    @ticks++

    gvy = @chance.floating {min: -1, max: 1}
    gvx = @chance.floating {min: -1, max: 1}

    clampNum = @clampNum
    # console.log 'Move clamp: ', clampNum

    @data.forEach((d,i) =>
      if d.y >= @height
        d.y = 0
      if d.x >= @width
        d.x = 0


      # myC = @chance.pickone @centers
      myC = @centers[d.center]

      d.vy = gvy + d.vy + @chance.floating {min: -2, max: 2.5, fixed: 2}
      d.vy = _.clamp(d.vy, -clampNum, clampNum)
      d.vx = gvx + d.vx + @chance.floating {min: -2, max: 2, fixed: 2}
      d.vx = _.clamp(d.vx, -clampNum, clampNum)

      if @chance.bool { likelihood: (i * 0.01) }
        d.radius += (d.vx + d.vy) / 10


      # if @chance.bool {likelihood: 95}
      #   if d.x < myC.x
      #     d.x += (d.vx / @chance.floating {min: 1.4, max: 8, fixed: 2})
      #   if d.x > myC.x
      #     d.x -= (d.vx / @chance.floating {min: 1.4, max: 8, fixed: 2})
      #   if d.y < myC.y
      #     d.y += (d.vy / @chance.floating {min: 1.4, max: 8, fixed: 2})
      #   if d.y > myC.y
      #     d.y -= (d.vy / @chance.floating {min: 1.4, max: 8, fixed: 2})

      cColor = d3.hsl myC.color
      dColor = d3.hsl d.color

      if cColor.h < dColor.h
        dColor.h -= @chance.floating {min: -0.1, max: 1, fixed: 2}
        d.color = dColor.toString()
        if cColor.s < dColor.s
          dColor.s -= @chance.floating {min: -0.1, max: 1, fixed: 2}
          d.color = dColor.toString()

      if @chance.bool { likelihood: (i * 0.001) }
        d.radius += 0.1

      if @chance.bool { likelihood: (i * 0.01) }
        if d.y > @height / 2
          d.vy--

      if @chance.bool { likelihood: (@ticks * 0.001) }
        d.dead = true

      if @chance.bool { likelihood: (d.i * 0.001) }
        d.radius = 0.11

      if @chance.bool { likelihood: (@ticks * 0.001) }
        @chance.integer {min: 0, max: @centers.length - 1}

      d.y = d.y + (d.vy / 4)
      # d.y += @chance.integer {min: -1, max: 1}
      d.x = d.x + (d.vx / 4)
      # d.x += @chance.integer {min: -1, max: 1}

      d.x = _.clamp(d.x, 0, @width)
      d.y = _.clamp(d.y, 0, @height)

      c = d3.hsl d.color
      if @chance.bool()
        c.h += @chance.floating({min: 0, max: 0.25})
        # if @chance.bool()
        #   c.l += @chance.floating({min: -0.1, max: 0.1})
        #   if @chance.bool()
        #     c.opacity -= @chance.floating({min: -0.01, max: 0.01})
      c.opacity = d.opacity
      d.color = c.toString()




      if !d.dead
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
