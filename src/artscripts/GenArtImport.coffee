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
seed = Date.now()
GenArt = require './GenArt'

# Make new instance
art = new GenArt(seed)
art.numTicks = 150
art.bgColor = '#999'
art.fillColor = 'black'
art.opacity = 0.5

art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++
  #console.log(@ticks, 'Ticking on ' + @data.length + ' particles')
  @data.forEach((d,i) =>
    # Modify the data

    if @chance.bool {likelihood: 50}
      d.x += @chance.floating {min: -8, max: 8}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -8, max: 8}

    # Paint the data
    @ctx.beginPath()
    @ctx.rect d.x, d.y, 2, 2
    # @ctx.fillStyle = d.color
    @ctx.fillStyle = @fillColor
    @ctx.fill()
    @ctx.closePath()
  )


# Make the art
art.init({save: true})
