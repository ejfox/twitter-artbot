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
clColors = require('nice-color-palettes/500')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require '@ejfox/four-seventeen'


# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 16
  numTicks: 2400
  bgColor: 'white'
  fillColor: 'white'
  opacity: 1
  randomizeCount: true
  randomizeTicks: true
  radius: 80
  minRadius: 2
  drawLinks: false
  constrainEdges: true
  colorChangeAmount: 0.9
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

  # @colors = ['#FFF']
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
      x: @width / 2
      y: @height / 2
      color: c.toString()
      radius: @radius
      opacity: @opacity
    }

    if i is 1
      datum.radius = @chance.integer {min: 50, max: 150}

    if i % 25 >= 1
      datum.x = @width * 0.2
      datum.y = @height / 2

    return datum

  @links = d3.range(@count * @chance.floating({min: 0.1, max: 10})).map =>
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

  alphaDecay = @chance.floating {min: 0.05, max: 0.25}
  velocityDecay = @chance.floating {min: 0.01, max: 0.25}
  charge = @chance.floating {min: -30, max: 30}
  centerOffsetX = @chance.floating {min: 0.35, max: 1.25}
  centerOffsetY = @chance.floating {min: 0.35, max: 1.25}

  @simulation = d3.forceSimulation(@data)
    # .alpha(0.999)
    .alphaDecay(alphaDecay)
    .velocityDecay(velocityDecay)
    .force 'charge', d3.forceManyBody().strength(charge)
    .force 'collide', d3.forceCollide((d) -> d.radius * 1.2).iterations(8)
    .force 'link', d3.forceLink(@links).distance(10).strength(0.5)
    .force 'center', d3.forceCenter((@width/2)*centerOffsetX,(@height/2)*centerOffsetY)

  # console.log 'links', @links

  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    ticks = 0
  @ticks++

  # @simulation.tick()
  for tick in [0..2]
    @simulation.tick()

  if @drawLinks
    if @chance.bool {likelihood: 5}
      @links.forEach( (d,i) =>
        linkopacity = @chance.floating {min: 0, max: 0.8}
        @ctx.beginPath();
        @ctx.moveTo(d.source.x, d.source.y);
        @ctx.lineTo(d.target.x, d.target.y);
        # @ctx.closePath();
        @ctx.strokeStyle = 'rgba(255,255,255,'+linkopacity+')'
        @ctx.stroke();
      )

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)

    # console.log JSON.stringify(d)

    maxStep = 1

    if @chance.bool {likelihood: 15}
      # d.x += @chance.floating {min: -d.radius*1.2, max: d.radius*1.2}
      d.vx += 0.5
    else if @chance.bool {likelihood: 15}
      # d.y += @chance.floating {min: -d.radius*1.2, max: d.radius*1.2}
      d.vx += 0.5

    if @chance.bool {likelihood: 25}
      d.x += @chance.floating {min: -maxStep, max: maxStep}

    if @chance.bool {likelihood: 25}
      d.y += @chance.floating {min: -maxStep, max: maxStep}

    if i is 1
      d.opacity = 0
      if @chance.bool {likelihood: 70}
        d.x += @chance.integer {min: -2, max: 7}

    if @constrainEdges
      d.x = _.clamp(d.x, 0+d.radius, @width-d.radius)
      d.y = _.clamp(d.y, 0+d.radius, @height-d.radius)
      # d.radius = _.clamp(d.radius, @minRadius, @width)
    # d.radius = _.clamp(d.radius, 0, @height / 2)

    # Simplex noise is always random, not seeded
    # This will introduce randomness even with the same seed
    # Use with care, and for subtle effects
    # d.radius += (noiseValue * 0.2) + (d.x / (@width*16))

    if noiseValue > 0
      d.x += @chance.floating {min: -6, max: 6}
      d.radius -= (noiseValue * 0.66)
    else
      d.y += @chance.floating {min: -6, max: 6}
      d.radius += (noiseValue * 0.05)


    colorChangeAmount = (d.vy + d.vx) * 0.64

    # Modify color / transparency
    # d.opacity -= 0.001
    c = d3.hsl(d.color)
    c.h += colorChangeAmount #@chance.integer({min: -colorChangeAmount, max: colorChangeAmount})
    c.opacity = d.opacity
    d.color = c.toString()

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    # @ctx.rect d.x, d.y, 1, 1
    @ctx.arc d.x, d.y, d.radius, 0, 2*Math.PI
    # @ctx.fillStyle = d.color

    # if d.radius < 5
    @ctx.fillStyle = d.color
    # @ctx.strokeStyle = 'white'
    # @ctx.lineWidth = 0.5
    # else
    #   @ctx.fillStyle = 'white'
    #   @ctx.strokeStyle = d.color
    #   @ctx.lineWidth = 1 + (d.radius * 0.025)
    # @ctx.fillStyle = @fillColor


    if i isnt 1
      @ctx.fill()
      # @ctx.stroke()
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
