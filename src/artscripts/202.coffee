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
    @count = 12 # Max number of particles to create
    @numTicks = 150 # Max number of times to tick over those particles

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

    # make bg
    @ctx.fillStyle = 'white';
    @ctx.fillRect(0, 0, @width, @height);

  init: (options = {}, callback) =>
    colorLovers.get('/palettes', {
        keywords: @chance.pickone ['grey', 'city', 'vintage', 'neon', 'old', 'punk'],
        sortBy: 'DESC',
        numResults: 1
        orderCol: @chance.pickone(['dateCreated', 'score', 'name', 'numVotes', 'numViews'])
    },(err, data) =>
      # if(err) throw err
      #console.log('data ->', data)

      rndColor = @chance.integer({min: 1, max: data.length})
      colors = data[rndColor].colors
      colors = colors.map (c) -> '#'+c


      @ctx.fillStyle = colors[0]
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

      direction = @chance.pickone(['up', 'down', 'left', 'right'])

      prclColor = @c10(direction)

      {
        x: x
        y: y
        color: prclColor
        direction: direction
        positions: []
        radius: @chance.integer {min: @width / 8, max: @width}
      }
    return @data

  tick: =>
    if !@ticks
      ticks = 0
    @ticks++
    #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
    @data.forEach((d,i) =>
      randOffset = @chance.integer {min: 2, max: 55}

      d.radius = d.radius - @chance.integer {min: 0, max: 5}
      if @chance.bool()
        d.radius = _.clamp(d.radius, 0, @width)

      dLikelies = d3.range(2).map =>
        @chance.integer {min: 0, max: 280}
      #
      moveUnit = @chance.integer {min: 2, max: @width / 6 }
      # if d.direction is 'up'
      if @chance.bool({likelihood: _.clamp(dLikelies[0] + 50, 0, 100)})
        d.y += moveUnit
      # else if d.direction is 'down'
      if @chance.bool({likelihood: _.clamp(dLikelies[1] + 50, 0, 100)})
        d.y -= moveUnit
      # else if d.direction is 'left'
      #   if @chance.bool({likelihood: _.clamp(dLikelies[0] + 50, 0, 100)})
      #     d.x -= moveUnit
      #   if @chance.bool({likelihood: dLikelies[4]})
      #     d.y -= moveUnit
      #   if @chance.bool({likelihood: dLikelies[5]})
      #     d.y += moveUnit
      # else if d.direction is 'right'
      #   if @chance.bool({likelihood: _.clamp(dLikelies[0] + 50, 0, 100)})
      #     d.x += moveUnit
      #   if @chance.bool({likelihood: dLikelies[6]})
      #     d.y -= moveUnit
      #   if @chance.bool({likelihood: dLikelies[7]})
      #     d.y += moveUnit
      #
      # if @chance.bool({likelihood: 1})
      #   d.direction = @chance.pickone ['up', 'down', 'left', 'right']

      if @chance.bool({likelihood: 5})
        c = d3.hsl d.color
        c.h += @chance.integer({min: -20, max: 20})
        d.color = c.toString()



      @ctx.beginPath()
      # @ctx.moveTo(d.x, d.y)
      @ctx.arc(d.x, d.y, d.radius, 0, Math.PI * 2, true)

      # @ctx.fillStyle = d.color
      # @ctx.fill()

      @ctx.fillStyle = 'none'
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
