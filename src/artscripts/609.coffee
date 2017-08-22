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
    @opacity = @chance.floating {min: 0.5, max: 0.99, fixed: 2}
    @linkOpacity = @chance.floating {min: 0.01, max: 0.1, fixed: 2}

    sizes = [[1080,720], [900,900], [1200,1200], [900,500]]

    if @chance.bool {likelihood: 10}
      sizes.push [320, 320]

    if @chance.bool {likelihood: 10}
      sizes.push [320, 960]

    size = @chance.pickone sizes

    # Canvas width and height
    @width = size[0]
    @height = size[1]
    console.log 'width', @width, 'height', @height

    @count = 25
    @numTicks = 6000
    @linkCount = @count * @chance.floating {min: 0.5, max: 1.5, fixed: 2}
    # @numTicks = 320

    @count = @chance.integer {min: 5, max: @count}
    @linkCount = @chance.integer {min: 5, max: @linkCount}
    @numTicks = @chance.integer {min: @numTicks / 2, max: @numTicks * 1.5}

    # @colors = [ '#B0E1F0', '#FDADD1', '#FFFFBC', '#A5DDC2',
    #       '#D7D9F8', '#F09BC1', '#E6FFE6', '#C2CDC5', '#BE497E',
    #       '#19426E', '#BFE5FF', '#A5DDC2', '#FAA21F', '#CB3F24'
    #     ]

    @colors = ['#1AF8FA', '#FA023C', '#C8FF00', '#FF0092', '#FFCA1B',
      '#B6FF00','#228DFF', '#BA01FF'
    ]

    @colors = _.shuffle @colors

    if @chance.bool()
      @colors = @colors.splice(0, @chance.integer {min: 1, max: @colors.length - 1})

    if @chance.bool()
      @colors.push '#000000'

    if @chance.bool()
      @colors.push '#FFFFFF'

    @hueChange = @chance.bool()
    @sizeChange = @chance.bool()
    @multiColor = @chance.bool()
    @clampBorders = @chance.bool()
    @useLinks = @chance.bool()
    @oneLinkTarget = @chance.bool()
    @drawLinks = @chance.bool()
    @allLinked = @chance.bool()
    @coloredLinks = @chance.bool {likelihood: 25}
    @straightLines = @chance.bool()
    @connectToCenter = @chance.bool()

    @curveTho = 1.1
    @curveThe = 0.9

    @text += ' ' + @curveTho + 'tho'
    @text += ' ' + @curveThe + 'the'

    @text += ' colors: ' + JSON.stringify(@colors)

    # @count = @chance.integer({min: 1, max: @count})

    @numTicks = @chance.integer({min: (@numTicks / 2), max: @numTicks})

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'

    @clampNum = @chance.floating {min: 1.5, max: 8, fixed: 3}

    @simplex = new SimplexNoise(Math.random)

    # make bg
    # @bgColor =  d3.hsl(@chance.pickone @colors)
    @bgColor =  d3.hsl(@chance.pickone ['#413D3D', '#040004'])

    # if @chance.bool()
    #   if @chance.bool()
    #     @bgColor.h += @chance.floating {min: -92, max: 92, fixed: 2}
    #   else
    #     @bgColor.s += @chance.floating {min: -92, max: 92, fixed: 2}

    @ctx.fillStyle = @bgColor.toString()
    @ctx.fillRect(0, 0, @width, @height)

    if @chance.bool { likelihood: 5 }
      @ctx.globalCompositeOperation = 'multiply'

    if @chance.bool { likelihood: 5 }
      @ctx.globalCompositeOperation = 'difference'

    if @chance.bool { likelihood: 33 }
      @ctx.globalCompositeOperation = 'lighten'

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
    console.log 'curveTho', @curveTho
    console.log 'curveThe', @curveThe
    console.log 'Colors: ', JSON.stringify @colors
    console.log 'One Link Target:', @oneLinkTarget
    console.log 'BG Color: ', @bgColor.toString()
    console.log 'Links: ', @useLinks
    console.log 'Hue change: ', @hueChange
    console.log 'Size change: ', @sizeChange
    console.log 'Multicolor: ', @multiColor

  makeParticles: =>
    console.log('Making ' + @count + ' particles')

    # @text += ' ' + @count + ' particles'

    # colors = ['#FA9921', '#FF0D5D', '#ff0dad', '#090645',
    # '#23cf68', '#87d606', '#111e4f', 'rgba(158, 12, 3, 0.5)']

    c = @chance.pickone @colors

    @data = d3.range(@count).map (d,i) =>
      if @multiColor
        c = @chance.pickone @colors

      radius = @chance.integer {min: 0.1, max: 2.2}

      {
        index: i
        id: i
        # x: @chance.integer {min: 0, max: @width}
        # y: @chance.integer {min: 0, max: @height}
        # x: @width / 2
        # y: @height / 2
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
        distance: @chance.integer {min: @width / 10, max: @width / 5}
        opacity: @linkOpacity
      }

    @data.forEach (d,i) =>
      color = @chance.pickone ['rgba(5,5,5,0.2)', 'rgba(255,255,255,0.5)']
      @links.push {
        source: i
        target: @chance.integer {min: 1, max: @count - 1}
        distance: @chance.integer {min: @width / 20, max: @width / 5}
        color: color
      }

  makeSimulation: =>
    collideMult = @chance.integer {min: 0.8, max: 10}

    alphaDecay = 0.1
    console.log 'alphaDecay: '+alphaDecay
    collideStrength = 0.1
    console.log 'collideStrength: '+collideStrength
    manyBodyStrength = -30
    console.log 'manyBodyStrength: '+manyBodyStrength

    distanceModifier = 1.5

    @simulation = d3.forceSimulation()
      .nodes @data
      .alphaDecay alphaDecay
      .force 'collide', d3.forceCollide((d) -> (d.radius * collideMult)).strength(collideStrength)
      .force 'center', d3.forceCenter(@width/2, @height/2)
      .force 'charge', d3.forceManyBody().strength(manyBodyStrength)
      .force 'links', d3.forceLink(@links).distance((d) -> d.distance * distanceModifier)

    @simulation.stop()

  tick: (callback) =>
    @ticks++

    # if @chance.bool {likelihood: 10}
    #   @curveTho += @chance.floating {min: -1, max: 1, fixed: 2}
    #
    # if @chance.bool {likelihood: 20}
    #   @curveThe += @chance.floating {min: -1, max: 1, fixed: 2}



    @simulation.tick()

    gvy = @chance.floating()
    gvx = @chance.floating()

    stepValue = @chance.floating {min: 0.1, max: 4}

    clampNum = @clampNum
    # console.log 'Move clamp: ', clampNum


    @links.forEach((d,i) =>

      if !@connectToCenter
        @ctx.moveTo(d.source.x, d.source.y)
      else
        @ctx.moveTo(@width/2, @height/2)

      if @chance.bool()
        cpx = d.target.x / @curveTho
        cpy = d.target.y / @curveThe
      else
        cpx = d.target.x / @curveThe
        cpy = d.target.y / @curveTho

      velocityMin = @chance.floating { min: 0.9, max: 4, fixed: 2}

      if d.target.vx < -velocityMin or d.target.vx > velocityMin and d.target.vy < -velocityMin or d.target.vy > velocityMin
        if @straightLines
          @ctx.lineTo(d.target.x, d.target.y)
        else
          @ctx.quadraticCurveTo(cpx, cpy, d.target.x, d.target.y)
    )

    if @coloredLinks
      c = d3.hsl @chance.pickone @colors
    else
      c = d3.hsl '#FFF'
    c.opacity = @linkOpacity
    @ctx.strokeStyle = c.toString()
    @ctx.stroke()

    noiseImpact = @chance.floating { min: 0.9, max: 4}

    # console.log 'tick'
    @data.forEach((d,i) =>
      if d.y > @height || d.y < 0
        # d.y = 0
        d.dead = true
      if d.x > @width || d.x < 0
        # d.x = 0
        d.dead = true

      noiseValue = @simplex.noise2D(d.x, d.y)

      if i is 5
        if @chance.bool()
          d.x += noiseValue
        else
          d.y += noiseValue

      if @chance.bool()
        d.vx += noiseValue * noiseImpact
      else
        d.vx -= noiseValue * noiseImpact
      if @chance.bool()
        d.vy += noiseValue * noiseImpact
      else
        d.vy -= noiseValue * noiseImpact

      if @sizeChange
        d.radius += (noiseValue / noiseImpact )

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
        d.radius = d.radius * 4
        c.opacity = 1

      d.color = c.toString()

      @ctx.beginPath()
      @ctx.arc(d.x, d.y, d.radius, 0, 2*Math.PI)
      @ctx.closePath()
      c = d3.hsl d.color
      c.opacity = d.opacity
      @ctx.fillStyle = c.toString()
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
