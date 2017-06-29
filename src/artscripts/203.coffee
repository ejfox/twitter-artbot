fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
path = require 'path'
colorLovers = require 'colourlovers'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv

class GenArt
  constructor: (seed) ->
    console.log('Seed:', seed)
    d3n = new d3Node { canvasModule }
    @seed = seed # The seed for the art

    @chance = new Chance(@seed) # init chance.js - chancejs.com
    @count = 15 # Max number of particles to create
    @numTicks = 2500 # Max number of times to tick over those particles

    # Randomize count/ticks based on maxes we just set
    @count = @chance.integer({min: 1, max: @count})
    @numTicks = @chance.integer({min: 1, max: @numTicks})

    # Canvas width and height
    @width = 1700
    @height = 1250
    console.log 'width', @width, 'height', @height

    # Create the canvas with D3 Node
    @canvas = d3n.createCanvas @width, @height
    @ctx = @canvas.getContext '2d'
    @ctx.globalCompositeOperation = @chance.pickone ['multiply', 'lightness'],

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

  init: (options = {}, callback) =>
    colorLovers.get('/palettes', {
        keywords: @chance.pickone ['vintage', 'neon', 'toy'],
        sortBy: 'DESC',
        numResults: 1
        orderCol: @chance.pickone(['dateCreated', 'score', 'name', 'numVotes', 'numViews'])
    },(err, data) =>
      # if(err) throw err
      #console.log('data ->', data)

      rndColor = @chance.integer({min: 1, max: data.length})
      colors = data[rndColor].colors
      colors = colors.map (c) -> '#'+c

      @bg = colors[0]
      @ctx.fillStyle = @bg
      @ctx.fillRect(0, 0, @width, @height)
      # colors.splice(1,1)

      if @chance.bool({likelihood: 10})
        @ctx.fillStyle = '#000'
        @ctx.fillRect(0, 0, @width, @height)

      console.log 'colors ->', colors
      if !err
        @c10 = d3.scaleOrdinal()
          .range(colors)
      else
        @c10 = d3.scaleOrdinal()
          .range ['#FFF', '#000', 'red']

      @makeParticles()
      @tickTil(@numTicks)
      if options.save
        @saveFile()

      if callback
        callback()
    )


  makeParticles: =>
    console.log('Making ' + @count + ' particles')
    @data = d3.range(@count).map =>
      # x = @chance.integer({min: 0, max: @width})
      # y = @chance.integer({min: 0, max: @height})
      x = @width / 2
      y = @height / 2 #@chance.integer {min: 0, max: @height}

      # c = d3.hsl('red')
      # c.h += @chance.natural({min: 0, max: 14})

      # @c10 = d3.scaleOrdinal()
      #   .range(["#FF0000", "#009933" , "#0000FF"]);

      prclColor = @c10

      {
        x: x
        y: y
        color: prclColor(@ticks)
        positions: []
        radius: @chance.integer {min: 0, max: @width * 0.9}
        jitter: @chance.integer {min: 0, max: 100}
      }
    return @data

  tick: =>
    if !@ticks
      ticks = 0
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')

    dLikelies = d3.range(4).map =>
      @chance.integer {min: 0, max: 280}
    @data.forEach((d,i) =>
      randOffset = @chance.integer {min: 2, max: 55}

      d.radius = d.radius - @chance.integer {min: 0, max: 2}
      d.radius = _.clamp(d.radius, 0, @width)
      #
      moveUnit = @chance.integer {min: d.radius / 5, max: d.radius * 5 }


      if @chance.bool({likelihood: _.clamp(dLikelies[0] + 50, 0, 100)})
        d.y += moveUnit
      if @chance.bool({likelihood: _.clamp(dLikelies[1] + 50, 0, 100)})
        d.y -= moveUnit

      if @chance.bool({likelihood: _.clamp(dLikelies[2] + 50, 0, 100)})
        d.x += moveUnit
      if @chance.bool({likelihood: _.clamp(dLikelies[3] + 50, 0, 100)})
        d.x -= moveUnit

      if @chance.bool({likelihood: d.jitter})
        d.y += (moveUnit / 2)
      if @chance.bool({likelihood: d.jitter})
        d.y -= (moveUnit / 2)

      if @chance.bool({likelihood: d.jitter})
        d.x += (moveUnit / 2)
      if @chance.bool({likelihood: d.jitter})
        d.x -= (moveUnit / 2)


      c = d3.hsl d.color
      # c.opacity = 0.8
      c.h += @chance.integer({min: -20, max: 20})
      d.color = c.toString()

      grdEnd = @chance.integer {min: 0, max: d.radius}
      grd = @ctx.createLinearGradient(0,0,grdEnd,grdEnd)
      grd.addColorStop(0,c.toString())
      c.h += @chance.integer({min: -120, max: 120})
      grd.addColorStop(1, c.toString())



      @ctx.beginPath()
      # @ctx.moveTo(d.x, d.y)
      @ctx.arc(d.x, d.y, d.radius, 0, Math.PI * 2, true)

      @ctx.fillStyle = grd
      @ctx.fill()

      #@ctx.fillStyle = 'none'
      #@ctx.strokeStyle = grd
      #@ctx.stroke()
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
