# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/01/2017
# Notes:

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
clColors = require('nice-color-palettes/500')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './../GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

coolWords =   [
  'able'
  'bad'
  'best'
  'better'
  'big'
  'black'
  'certain'
  'clear'
  'different'
  'early'
  'easy'
  'economic'
  'federal'
  'free'
  'full'
  'good'
  'great'
  'hard'
  'high'
  'human'
  'important'
  'international'
  'large'
  'late'
  'little'
  'local'
  'long'
  'low'
  'major'
  'military'
  'national'
  'new'
  'old'
  'only'
  'other'
  'political'
  'possible'
  'public'
  'real'
  'recent'
  'right'
  'small'
  'social'
  'special'
  'strong'
  'sure'
  'true'
  'white'
  'whole'
  'young'
]

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 4
  numTicks: 1
  bgColor: '#e4dfd1'
  fillColor: 'black'
  randomizeCount: false
  randomizeTicks: true
  opacity: 0.4
  blendMode: 'multiply'
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# `makeParticles()` is called at the start of the script and creates
# the particles which are manipulated and drawn on every tick
art.makeParticles = ->
  @word = @chance.pickone coolWords
  # @colors = @chance.pickone clColors
  @colors = ['#217BC3', '#E82117', '#F2DB00']
  @blendMode = @chance.pickone ['multiply', 'xor']
  @textUppercase = @chance.bool()

  @opacity = @chance.floating {min: 0.6, max: 0.9}

  @circles = @chance.bool()

  @count = @word.length
  # @count = 12

  @ctx.font = '8px monospace'
  @ctx.fillStyle = 'black'
  @ctx.fillText(@word, 10, 18)

  @data = d3.range(@count).map (d,i) =>
    offsetAmount = @chance.integer {min: 5, max: @width/3.2}
    offset = {}
    # offset.x = @chance.floating({min: -(offsetAmount * 1.5), max: offsetAmount})
    offset.y = @chance.floating({min: -(offsetAmount * 1.5), max: offsetAmount})
    x = 220 + (i * 100)
    y = (@height / 1.5 ) + offset.y

    # c = d3.hsl(@fillColor)
    c = d3.hsl @chance.pickone @colors
    # c = d3.hsl(@chance.pickone ['red', 'yellow', 'blue'])
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    {
      x: x
      y: y
      radius: (offsetAmount*2)
      color: c.toString()
      text: @word[i]
      # text: @chance.pickone @word
    }
  return @data

# `tick()` is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y)
    #
    #
    # # Simplex noise is always random, not seeded
    # # This will introduce randomness even with the same seed
    # # Use with care, and for subtle effects
    # if noiseValue > 0
    #   d.x += @chance.floating {min: -2, max: 2}
    # else
    #   d.y += @chance.floating {min: -2, max: 2}

    ###########################
    # Then paint the particle #
    ###########################
    @ctx.beginPath()
    @ctx.font = d.radius + 'px sans-serif';
    # @ctx.fillStyle = @fillColor
    text = d.text
    if @textUppercase
      text = d.text.toUpperCase()

    @ctx.textAlign = 'center'
    @ctx.fillStyle = d.color # Color per-particle
    @ctx.fillText(text, d.x, d.y)
    # if @chance.bool {likelihood: 50}
    #   d.x += @chance.floating {min: -200, max: 200}

    if @chance.bool {likelihood: 50}
      d.y += @chance.floating {min: -200, max: 200}

    # @ctx.rect d.x, d.y, 1, 1 # Square 1x1 pixel
    if @chance.bool() && @circles
      @ctx.arc d.x, d.y, d.radius/10, 0, 2*Math.PI # Or a circle

    # @ctx.fillStyle = @fillColor # Or use a global fill color for all

    @ctx.fill()
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
  art.seed = seed
  art.init({save: true})

if(require.main == module)
  run()

module.exports = art
