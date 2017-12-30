fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
Chance = require 'chance'
SimplexNoise = require 'simplex-noise'
path = require 'path'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
GenArt = require './GenArt'

# Make new instance
art = new GenArt(seed)
art.filename = path.basename(__filename, '.js') + '-' + seed
art.count = 24
art.numTicks = 92
art.bgColor = '#FFF'
art.fillColor = 'black'
art.simplex = new SimplexNoise

art.makeParticles = ->
  console.log('Making ' + @count + ' particles')
  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 25, max: 500}
    offset = {}
    # offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    x = (@width / 2 )
    y = (@height / 2 ) + offset.y

    c = d3.hsl('black')
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    if @chance.bool {likelihood: 1}
      x = 0
    if @chance.bool {likelihood: 1}
      x = @width

    {
      x: x
      y: y
      color: c.toString()
      radius: @chance.integer {min: 5, max: 120}
      shape: @chance.pickone ['circle', 'triangle', 'line']
    }
  return @data

art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++
  #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
  @data.forEach((d,i) =>
    # Modify the data

    noiseValue = @simplex.noise2D(d.x, d.y)

    if @chance.bool {likelihood: 50}
      d.radius *= noiseValue * 4.5

    if @chance.bool {likelihood: 2}
      d.radius *= 2

    if @chance.bool {likelihood: 2}
      d.radius *= 0.5

    if @chance.bool {likelihood: 1}
      d.radius *= 4

    d.radius = _.clamp(d.radius, 1, @width)

    # if @chance.bool {likelihood: 50}
    #   d.x += @chance.floating {min: -2, max: 2}

    if @chance.bool {likelihood: 40}
      d.y += @chance.floating {min: -4, max: 4} * noiseValue

    if @chance.bool {likelihood: 8}
      d.y *= noiseValue * 6

    if @chance.bool {likelihood: 8}
      d.y *= noiseValue * -6

    if @chance.bool {likelihood: 70}
      d.y = _.clamp(d.y, 0, @height)

    # Paint the data
    c = d3.hsl(d.color)
    c.opacity -= 0.01
    d.color = c.toString()

    @ctx.beginPath()
    if d.shape is 'circle'
      # @ctx.rect d.x, d.y, 1, 1
      arc = @chance.integer {min: 1, max: 2}
      @ctx.arc(d.x,d.y,d.radius,0,arc*Math.PI);
    else if d.shape is 'triangle'
      if @chance.bool()
        @ctx.moveTo(d.x - d.radius, d.y);
      if @chance.bool()
        @ctx.lineTo(d.x + d.radius, d.y);
      if @chance.bool()
        @ctx.lineTo(d.x, d.y + (d.radius * 1.3));
    else if d.shape is 'line'
      if @chance.bool()
        @ctx.moveTo(d.x, d.y - d.radius);
        @ctx.lineTo(d.x, d.y + d.radius);
      else
        @ctx.moveTo(d.x - d.radius, d.y);
        @ctx.lineTo(d.x + d.radius, d.y);
    # @ctx.fillStyle = d.color
    @ctx.fillStyle = 'none'
    # @ctx.fill()
    if @chance.bool()
      @ctx.closePath()

    @ctx.strokeStyle = d.color
    @ctx.stroke()
  )


if(require.main == module)
  # Make the art
  art.init({save: true})

module.exports = art
