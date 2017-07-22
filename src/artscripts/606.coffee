fs = require 'fs-extra'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
path = require 'path'
seedrandom = require 'seedrandom'
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

    seedrandom(@seed, {global: true})

    # @opacity = 0.99
    @opacity = 0.95

    @text = ''

    # Canvas width and height
    @width = 1080
    @height = 720
    console.log 'width', @width, 'height', @height

    @count = 39
    @numTicks = 7500
    @linkCount = 53
    # @numTicks = 320

    @colors = [ '#B0E1F0', '#FDADD1', '#FFFFBC', '#A5DDC2',
          '#D7D9F8', '#F09BC1', '#E6FFE6', '#C2CDC5', '#BE497E',
          '#19426E', '#BFE5FF', '#A5DDC2', '#FAA21F', '#CB3F24'
        ]

    @hueChange = false
    @sizeChange = true
    @multiColor = true
    @clampBorders = @chance.bool { likelihood: 60}
    @useLinks = true
    @oneLinkTarget = true

    # @count = @chance.integer({min: 1, max: @count})

    @numTicks = @chance.integer({min: (@numTicks / 2), max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    @clampNum = @chance.floating {min: 1.5, max: 8, fixed: 3}

    @simplex = new SimplexNoise(Math.random)

    # make bg
    @bgColor =  d3.hsl(@chance.pickone @colors)

    # if @chance.bool()
    #   if @chance.bool()
    #     @bgColor.h += @chance.floating {min: -92, max: 92, fixed: 2}
    #   else
    #     @bgColor.s += @chance.floating {min: -92, max: 92, fixed: 2}

    @ctx.fillStyle = @bgColor.toString()
    @ctx.fillRect(0, 0, @width, @height)

    if @chance.bool { likelihood: 5 }
      @ctx.globalCompositeOperation = 'multiply'
    else if @chance.bool { likelihood: 2 }
      @ctx.globalCompositeOperation = 'difference'

  init: (options = {}, callback) =>
    @logSettings()
    @makeParticles()
    @makeSimulation()
    @tickTil(@numTicks)

    if options.save
      @saveFile()

    if callback
      callback()

  logSettings: =>
    console.log 'Colors: ', JSON.stringify @colors
    console.log 'One Link Target:', @oneLinkTarget
    console.log 'BG Color: ', @bgColor.toString()
    console.log 'Links: ', @useLinks
    console.log 'Hue change: ', @hueChange
    console.log 'Size change: ', @sizeChange
    console.log 'Multicolor: ', @multiColor

    @text += ' ' + 'uselinks:' + @useLinks
    @text += ' ' + 'onetarget:' + @oneLinkTarget
    @text += ' ' + 'sizeChange:' + @sizeChange

  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    @text += ' ' + @count + ' particles'

    # colors = ['#FA9921', '#FF0D5D', '#ff0dad', '#090645',
    # '#23cf68', '#87d606', '#111e4f', 'rgba(158, 12, 3, 0.5)']

    c = @chance.pickone @colors

    @data = d3.range(@count).map (d,i) =>
      if @multiColor
        c = @chance.pickone @colors

      radius = @chance.integer {min: 2, max: 4}

      {
        index: i
        id: i
        # x: @chance.integer {min: 0, max: @width}
        # y: @chance.integer {min: 0, max: @height}
        x: @width / 2
        y: @height / 2
        color: c.toString()
        # color: 'black'
        opacity: @opacity
        radius: radius
      }

    console.log 'Making '+@linkCount+' links'

    linkTarget = @chance.integer {min: 1, max: @count - 1}

    @links = d3.range(@linkCount).map (d,i) =>
      linkSource = @chance.integer {min: 1, max: @count - 1}
      if !@oneLinkTarget
        linkTarget = @chance.integer {min: 1, max: @count - 1}
      # console.log 'linking ', linkSource, '-->', linkTarget
      {
        source: linkSource
        target: linkTarget
        distance: @chance.integer {min: 10, max: @width / 4}
      }

  makeSimulation: =>
    collideMult = @chance.integer {min: 1, max: 8}

    alphaDecay = @chance.floating {min: 0.00001, max: 0.01, fixed: 6}
    collideStrength = @chance.floating {min: 0.01, max: 0.99, fixed: 3}
    manyBodyStrength = @chance.floating {min: -60, max: 10, fixed: 3}

    @simulation = d3.forceSimulation()
      .nodes @data
      .alphaDecay alphaDecay
      .force 'collide', d3.forceCollide((d) -> (d.radius * collideMult)).strength(collideStrength)
      .force 'center', d3.forceCenter(@width/2, @height/2)
      .force 'charge', d3.forceManyBody().strength(manyBodyStrength)
      .force 'links', d3.forceLink(@links).distance((d) -> d.distance)

    @simulation.stop()

  tick: (callback) =>
    @ticks++


    @simulation.tick()

    gvy = @chance.floating()
    gvx = @chance.floating()

    stepValue = @chance.floating {min: 0.8, max: 1.6}

    clampNum = @clampNum
    # console.log 'Move clamp: ', clampNum


    # console.log 'tick'
    @data.forEach((d,i) =>
      if d.y >= @height
        # d.y = 0
        d.dead = true
      if d.x >= @width
        # d.x = 0
        d.dead = true

      noiseValue = @simplex.noise2D(d.x, d.y)

      if @chance.bool()
        d.vx += noiseValue * 2
      if @chance.bool()
        d.vy += noiseValue * 2

      if @sizeChange
        d.radius += (noiseValue / 4 )

      if @clampBorders
        d.x = _.clamp(d.x + d.radius, d.radius, @width - d.radius)
        d.y = _.clamp(d.y + d.radius, d.radius, @height - d.radius)

      c = d3.hsl d.color
      if @hueChange
        c.h += 0.01
        # if @chance.bool()
        #   c.l += @chance.floating({min: -0.1, max: 0.1})
        #   if @chance.bool()
        #     c.opacity -= @chance.floating({min: -0.01, max: 0.01})
      c.opacity = d.opacity

      if @ticks is (@count - 1)
        c.opacity = 1

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
