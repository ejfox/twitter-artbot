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

    @opacity = 0.6

    # Canvas width and height
    @width = 1200
    @height = 1200
    console.log 'width', @width, 'height', @height

    @count = 66
    @numTicks = 6666

    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 666, max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    @clampNum = @chance.floating {min: 2, max: 24, fixed: 2}

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

    colors = ['#FA9921', '#FF0D5D', '#ff0dad', '#090645',
    '#23cf68', '#87d606', '#111e4f', 'rgba(158, 12, 3, 0.5)']
    color = @chance.pickone colors

    circleSize = @chance.integer {min: 6, max: @width / 20}
    circleCount = @chance.integer {min: 1, max: 6}
    circleColor = @chance.pickone colors

    @centers = d3.range(circleCount).map (d,i) =>
      x = @chance.integer {min: 0, max: @width}
      y = @chance.integer {min: 0, max: @height}
      @ctx.beginPath()
      @ctx.arc(x, y, circleSize, 0, 2*Math.PI)
      @ctx.closePath()
      @ctx.fillStyle = circleColor
      @ctx.fill()
      return {
        x: x
        y: y
      }

    @data = d3.range(@count).map (d,i) =>

      halfWidth = @width / 2
      x = halfWidth + @chance.integer {min: -halfWidth, max: halfWidth}
      #y = @height / 2
      y = @chance.integer {min: 0, max: 40}
      c = d3.hsl(color)

      {
        id: i
        radius: 1
        x: x
        y: y
        color: c.toString()
        # color: 'black'
        vx: 0
        vy: 0
        dead: false
        deadmarked: false
      }

  tick: =>
    @ticks++

    gvy = @chance.integer {min: -3, max: 3}
    gvx = @chance.integer {min: -3, max: 3}

    clampNum = @clampNum
    # console.log 'Move clamp: ', clampNum

    @data.forEach((d,i) =>



      if d.y is @height
        d.vy = -24
      # if @width - d.x < 50
      #   d.vx = -

      _.each(@data, (cd,ci) =>
        if cd.x is d.x
          d.vx += @chance.integer {min: -8, max: 8}
        if cd.y is d.y
          d.vy += @chance.integer {min: -8, max: 8}
      )

      d.vy = gvy + d.vy + @chance.floating {min: -4, max: 4.5, fixed: 2}
      d.vy = _.clamp(d.vy, -clampNum, clampNum)
      d.vx = gvx + d.vx + @chance.floating {min: -4, max: 4, fixed: 2}
      d.vx = _.clamp(d.vx, -clampNum, clampNum)

      if @chance.bool { likelihood: (i * 0.001) }
        d.radius += 0.1

      if @chance.bool { likelihood: (i * 0.01) }
        if d.y > @height / 2
          d.vy--

      if @chance.bool { likelihood: (d.id * 0.01) }
        d.dead = true

      if @chance.bool { likelihood: (d.i * 0.001) }
        d.radius = 0.11

      d.y = d.y + (d.vy / 4)
      # d.y += @chance.integer {min: -1, max: 1}
      d.x = d.x + (d.vx / 4)
      # d.x += @chance.integer {min: -1, max: 1}

      d.x = _.clamp(d.x, 0, @width)
      d.y = _.clamp(d.y, 0, @height)

      c = d3.hsl d.color
      if @chance.bool()
        c.h += @chance.floating({min: 0, max: 0.25})

        if @chance.bool()
          c.l += @chance.floating({min: -0.25, max: 0.25})
      c.opacity = @opacity
      d.color = c.toString()


      if !d.dead
        @ctx.beginPath()
        @ctx.arc(d.x, d.y, d.radius, 0, 2*Math.PI)
        @ctx.closePath()
        @ctx.fillStyle = d.color
        @ctx.fill()
      else if !d.deadmarked
        d.deadmarked = true
        @ctx.beginPath()
        @ctx.arc(d.x, d.y, 2, 0, 2*Math.PI)
        @ctx.closePath()
        @ctx.fillStyle = 'rgba(0,0,0,0.1)'
        @ctx.fill()
      else
        @ctx.beginPath()
        @ctx.arc(d.x, d.y, d.radius / 2, 0, 2*Math.PI)
        @ctx.closePath()
        c.opacity = @opacity / 2
        c.s = 0
        d.color = c.toString()
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
