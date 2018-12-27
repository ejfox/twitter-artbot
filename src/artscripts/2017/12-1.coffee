# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/02/2017
# Notes:

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
_ = require 'lodash'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
Chance = require('chance')
clColors = require('nice-color-palettes/100')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require '@ejfox/four-seventeen'


# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 600
  numTicks: 7000
  bgColor: 'rgb(4, 6, 41)'
  fillColor: 'white'
  opacity: 1
  randomizeCount: true
  radius: 1
  drawLinks: false
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  console.log('Making ' + @count + ' particles')
  # @colors = ['#2ed991', '#2ed9c9', '#2e87d9', '#dbdf1d', '#d92e99'
  #   '#d92752', '#2799d9'
  # ]
  @colors = @chance.pickone clColors
  @data = d3.range(@count).map (d,i) =>
    offsetAmount = @chance.integer {min: 250, max: 900}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    # x = (@width / 2 ) + offset.x
    x = 0
    y = (@height / 2 ) + offset.y

    color = @chance.pickone @colors
    c = d3.hsl(color)
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    datum = {
      # x: x
      # y: y
      color: c.toString()
      radius: @radius
      opacity: @opacity
    }

    # if i % 25 >= 1
    #   datum.x = @width / 2
    #   datum.y = @width / 2

    return datum

  @links = d3.range(@count * @chance.floating({min: 0.1, max: 4})).map =>
    {
      # source: @chance.integer({min: 0, max: @data.length-1})
      source: @chance.integer({min: 0, max: @count-1})
      target: @chance.integer({min: 0, max: @count-1})
    }

  for i in [0..@data.length-1]
    @links.push {
      source: 1
      target: i
    }

  @simulation = d3.forceSimulation(@data)
    .alpha(0.999)
    .force 'charge', d3.forceManyBody()
    .force 'collide', d3.forceCollide((d) -> d.radius * 2).iterations(4)
    # .force 'link', d3.forceLink(@links).distance(10).strength(0.1)
    .force 'center', d3.forceCenter(@width/2,@height/2)

  # console.log 'links', @links

  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++

  @simulation.tick()
  # for tick in [0..4]
  #   @simulation.tick()

  if @drawLinks
    if @chance.bool {likelihood: 5}
      @links.forEach( (d,i) =>
        @ctx.beginPath();
        @ctx.moveTo(d.source.x, d.source.y);
        @ctx.lineTo(d.target.x, d.target.y);
        # @ctx.closePath();
        @ctx.strokeStyle = 'rgba(255,255,255,0.5)'
        @ctx.stroke();
      )

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    # maxStep = 2
    #
    # if @chance.bool {likelihood: 5}
    #   d.x += @chance.floating {min: -maxStep, max: maxStep}
    #
    # if @chance.bool {likelihood: 5}
    #   d.y += @chance.floating {min: -maxStep, max: maxStep}

    d.x = _.clamp(d.x, 0, @width)
    d.y = _.clamp(d.y, 0, @height)

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # d.radius += (noiseValue * 0.2) + (d.x / (@width*16))

    if noiseValue > 0 and @chance.bool()
      d.vx += @chance.floating {min: -4, max: 4}
      # d.radius += 0.1
    else if @chance.bool()
      d.vy += @chance.floating {min: -4, max: 4}
      # d.radius -= 0.1

    # Modify color / transparency
    # d.opacity -= 0.001
    c = d3.hsl(d.color)
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = d.opacity
    d.color = c.toString()

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    # @ctx.rect d.x, d.y, 1, 1
    @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    # @ctx.fillStyle = d.color
    # @ctx.fillStyle = @fillColor
    # @ctx.fill()
    @ctx.strokeStyle = d.color
    @ctx.stroke();
    @ctx.closePath()
  )


run = ->
  # If this is being called from the command line
  # --seed foo
  # would set the seed to "foo"
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()
  # genart = new GenArt(seed, options)
  # genart.init({save: true})
  art.seed = seed
  art.init({save: true})

if(require.main == module)
  run()

module.exports = art
