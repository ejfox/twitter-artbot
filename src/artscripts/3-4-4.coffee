# Title: Boilerplate Artscript
# Author: EJ Fox <ejfox@ejfox.com>
# Date created: 10/01/2017
# Notes:

# Set up our requirements
# SimplexNoise = require 'simplex-noise'
path = require 'path'
d3 = require 'd3'
D3Node = require 'd3-node'
d3n = new D3Node()
argv = require 'yargs'
  .alias 's', 'seed'
  .argv
seed = Date.now()
_ = require 'lodash'
clColors = require('nice-color-palettes')
parseSVG = require('svg-path-parser')
TextToSVG = require('text-to-svg')
# textToSVG = TextToSVG.loadSync()
textToSVG = TextToSVG.loadSync('fonts/blackjack.otf')
cheerio = require('cheerio')

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 18
  text: 'Love'
  width: 1920
  height: 1080
  numTicks: 417
  minTicks: 24
  randomizeTicks: true
  fontSize: 512
  bgColor: 'white'
  fillColor: 'black'
  opacity: 0.12
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->
  console.log('Making ' + @count + ' particles')
  # @colors = ['#000', '#000', '#000', '#EFEFEF']
  @colors = @chance.pickone clColors
  @color = @chance.pickone @colors
  @ctx.globalCompositeOperation = 'multiply'
  # @ctx.globalCompositeOperation = @chance.pickone ['multiply', 'difference']
  # if @count <= 2
  #   @count = 3

  @fontSize = @chance.floating {min: 192, max: @width * 0.8}

  @text = @chance.pickone [
    # 'Atosa'
    # 'ATOSA'
    # 'atosa'
    # '417'
    '417am'
    '1975'
    'speak'
    'trying'
    'robot'
    'run'
    'random'
    'big'
    'small'
    'know'
    'leave'
    'love'
    # '@'
    # '<3'
    # 'love me'
  ]

  @curveOptions = [
    d3.curveMonotoneX,
    # d3.curveBasisOpen,
    # d3.curveNatural
  ]

  console.log 'NUM TICKSSSSSSS', @numTicks

  colorRange = [@chance.pickone(@colors), @chance.pickone(@colors)]

  if @chance.bool()
    colorRange.push @chance.pickone @colors
    if @chance.bool()
      colorRange.push @chance.pickone @colors

  @colorScale = d3.scaleLinear()
    .domain [0, 1]
    .interpolate d3.interpolateHsl
    .range colorRange
    # .range ['red', 'white', 'blue']

  @line = d3.line()
    .x (d) -> d.x
    .y (d) -> d.y
  #   # .curve d3.curveStep
  #   .curve @chance.pickone @curveOptions
  #   # .curve d3.curveBasisClosed
  #   .curve d3.curveBasisOpen
    .context(@ctx)

  startX = @chance.integer {min: 100, max: @width-100}

  textsvg = textToSVG.getPath(@text, {
    fontSize: @fontSize
    anchor: 'center middle'
    x: @width / 2
    y: @height / 2
  })
  # console.log 'textsvg', textsvg

  # textpath = d3.select(textsvg).select('path')
  $parsedTextpath = cheerio.load(textsvg)
  d = $parsedTextpath('path').attr('d')
  parsedTextpath = parseSVG(d)

  # console.log 'parsedTextpath', parsedTextpath

  # parsedTextpath = parsedTextpath.filter (d) -> d.code is 'L'
  parsedTextpath = parsedTextpath.filter (d) -> d.code isnt 'Z'

  @data = parsedTextpath.map (d,i) =>
    offsetAmount = @chance.integer {min: 0.5, max: @width * 0.16 }

    # d.y += (@height / 2)
    # d.x += (@width / 2)
    # y = i * (@height / (@count - 1))

    # y += i * 25

    if d.code is 'Q'
      d.x = ((d.x + d.x1) / 2)
      d.y = ((d.y + d.y1) / 2)

    @betaStep = 1 / @numTicks
    @beta = 0

    c = d3.hsl('white')
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    {
      x: d.x + @chance.integer({min: -offsetAmount, max: offsetAmount})
      y: d.y + @chance.integer({min: -offsetAmount, max: offsetAmount})
      color: c.toString()
    }

  @ogData = @data
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++

  # console.log '@beta', @beta

  @line.curve(d3.curveBundle.beta(+@beta))
  # @line.curve(d3.curveCardinal.tension(+@beta))
  # @line.curve(d3.curveCatmullRomOpen.alpha(+@beta))


  @beta += @betaStep

  @data.forEach((d,i) =>
    ###########################
    #   Modify each particle  #
    ###########################
    noiseValue = @simplex.noise2D(d.x, d.y) * @chance.floating {min: 0.1, max: 2}

    ogd = @ogData[i]

    if @chance.bool({likelihood: 4})
      d.x += noiseValue
      d.y += noiseValue

    d.x = _.clamp d.x, 0, @width
    d.y = _.clamp d.y, 0, @height

    # if @chance.bool()
    #   if ogd.x < d.x
    #     d.x += noiseValue
    #
    #   if ogd.y < d.y
    #     d.y += noiseValue
    #
    #   if ogd.x > d.x
    #     d.x -= noiseValue
    #
    #   if ogd.y > d.y
    #     d.y -= noiseValue


    # maxStep = ((i * 2) + (@ticks / 10000)) * 0.65
    maxStep = ( i * 0.1 ) + noiseValue

    maxStep = _.clamp maxStep, 0.01, @width/8

    # if @chance.bool {likelihood: 1} and i is 1
    #   d.x += @chance.integer {min: 25, max: 100}
    #   d.y -= @chance.integer {min: 25, max: 100}

    if @chance.bool {likelihood: 5}
      d.x += @chance.floating {min: -maxStep, max: maxStep}

    if @chance.bool {likelihood: 5}
      d.y += @chance.floating {min: -maxStep, max: maxStep}

    # @ctx.beginPath()
    # @ctx.arc d.x, d.y, 2, 0, 2*Math.PI
    # @ctx.stroke()
    # @ctx.fill()
  )

  c = d3.hsl @colorScale(@beta)

  # if @chance.bool({likelihood: 0.1})
  #   # sStep = 0.1
  #   sStep = @chance.floating {min: 0.01, max: 0.1}
  #   c.s += @chance.floating {min: -sStep, max: sStep}
  # c.h += 0.05 #+ (@ticks / 150000)
  # if c.h is 359
  #   d.h = 0

  c.opacity = @opacity
  @color = c.toString()

  @ctx.beginPath()
  @line @data
  @ctx.lineWidth = 1.5
  # @ctx.strokeStyle = 'rgba(0,0,0,0.01)'
  @ctx.strokeStyle = @color
  @ctx.stroke()



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
