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

coolWords = [
  'Assemblage'
  'Becoming'
  'Beleaguer'
  'Brood'
  'Bucolic'
  'Bungalow'
  'Conflate'
  'Dissemble'
  'Elixir'
  'Eloquence'
  'Embrocation'
  'Ephemeral'
  'Epiphany'
  'Erstwhile'
  'Ethereal'
  'Evanescent'
  'Evocative'
  'Fetching'
  'Furtive'
  'Glamour'
  'Harbinger'
  'Imbue'
  'Incipient'
  'Ineffable'
  'Inure'
  'Labyrinthine'
  'Leisure'
  'Lilt'
  'Lissome'
  'Lithe'
  'Love'
  'Moiety'
  'Murmurous'
  'Nemesis'
  'Offing'
  'Opulent'
  'Panacea'
  'Panoply'
  'Plethora'
  'Quintessential'
  'Ratatouille'
  'Ravel'
  'Redolent'
  'Ripple'
  'Serendipity'
  'Summery'
  'Sumptuous'
  'Surreptitious'
  'Talisman'
  'Umbrella'
  'Untoward'
  'Wherewithal'
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

# Require GenArt which is the skeleton
# around which all ArtScripts are built
GenArt = require './GenArt'

# Filenames follow the format $ArtScript-$seed.png
# For example: `_boilerplate-1506887448254.png`

# Set some options for our artscript
options = {
  width: 720
  height: 720
  filename: path.basename(__filename, '.js') + '-' + seed
  count: 10
  randomizeCount: true
  numTicks: 10
  randomizeTicks: true
  bgColor: 'white'
  fillColor: 'black'
}

# Clone skeleton GenArt ArtScript
# So we can modify it
art = new GenArt(seed, options)

# Overwrite the GenArt makeParticles function and customize
# This is called at the start of the script and creates
# The particles which are manipulated and drawn every tick
art.makeParticles = ->

  @ctx.font = '20px sans-serif';
  @ctx.fillStyle = @fillColor
  @ctx.fillText('I\'m in charge now... Let\'s make some art', 50, 48);
  @ctx.fillText('Follow these instructions to the best of your ability', 50, 96);

  console.log('Making ' + @count + ' particles')
  @data = d3.range(@count).map =>
    offsetAmount = @chance.integer {min: 25, max: 500}
    offset = {}
    offset.x = @chance.floating({min: -offsetAmount, max: offsetAmount})
    offset.y = @chance.floating({min: -offsetAmount, max: offsetAmount})
    x = (@width / 2 ) + offset.x
    y = (@height / 2 ) + offset.y

    c = d3.hsl('white')
    # c.h += @chance.natural({min: 0, max: 14})
    c.opacity = @opacity

    {
      x: x
      y: y
      color: c.toString()
    }
  return @data

# Overwrite the GenArt tick function and customize
# This function is called every time the art is ticked
art.tick = ->
  if !@ticks
    @ticks = 0
  @ticks++


  @shapes = [
    'squares'
    'circles'
    'lines'
    'arrows'
    'triangles'
    'squiggles'
  ]

  @shape = [
    'square'
    'circle'
    'line'
    'arrow'
    'triangle'
    'squiggle'
    'word'
  ]

  colors = [
    'red'
    'blue'
    'yellow'
    'gray'
    'dark red'
    'pink'
    'maroon'
    'purple'
    'light blue'
    'dark blue'
  ]

  positions = [
    'top'
    'bottom'
    'left'
    'right'
    'middle'
    'somewhere'
    'wherever'
    'each corner'
  ]

  @initactions = [
    # 'Maybe use a pencil'
    # 'Maybe use a marker'
    'Maybe use a brush with '+@chance.pickone(colors)
    'Clear your mind'
    'Stand for this one if you want'
    'Draw a word in the center of the page'
    'Make this as unappealing as possible'
    'Make this as balanced as possible'
    'Make this as symmetrical as possible'
    'Make these lines as thin as possible'
    'Make these lines as straight as possible'
    'Make things overlap as little as possible'
    'This one is going to be unlike any of the others'
    'Dont worry about this one'
    'Pretend this work will sell for $1000'
    'This is one no one will like but me'
    'Do this one as tiny as possible'
    'Make this work sum up your day'
    'This is going to be the last one'
    'Focus on an emotion'
    'Make this something like a self portrait'
  ]

  @actions = [
    'Draw one ' + @chance.pickone(@shape)
    'Draw ' + @count+' '+@chance.pickone(@shapes)
    # 'Draw ' + @count/2+' '+@chance.pickone(@shapes)
    # 'Fill ' + @chance.integer({min: 1, max: 5}) + ' area(s) with '+@chance.pickone(colors)
    'Draw ' + @chance.integer({min: 2, max: 5}) + ' shapes with '+@chance.pickset(colors,2)[0]+' and '+@chance.pickset(colors,2)[1]
    'Draw 1 ' + @chance.pickone(@shape) + ' and connect it with a '+@chance.pickone(@shape)
    'Draw a ' + @chance.pickone(@shape) + ' on the '+@chance.pickone(positions)
    'Draw a sqiggly line on the '+@chance.pickone(positions)
    'Draw a ' + @chance.pickone(@shape) + ' in the area with the most whitespace'
    'Draw a ' + @chance.pickone(@shape) + ' in a corner'
    'Draw a word... maybe something like ' + @chance.pickone(coolWords).toLowerCase() + '?'
    'Draw a line from ' + @chance.pickone(positions) + ' to ' + @chance.pickone(positions)
    'Draw a line from ' + @chance.pickone(positions) + ' to the middle'
    'Draw a curved line from ' + @chance.pickone(positions) + ' to the middle'
    'Draw a tiny ' + @chance.pickone(@shape)
    'Draw ' + @count*2 + ' tiny ' + @chance.pickone(@shapes)
    'Draw a huge ' + @chance.pickone(@shape)
    'Choose to ignore the following instruction'
    'Add a bit of ' + @chance.pickone(colors)
  ]

  # console.log 'ticks --> ' + @ticks

  if @ticks is 1
    instruction = 'Now... ' + @chance.pickone @initactions
  else
    instruction = 'Now... ' + @chance.pickone @actions

  if @ticks > 3 and @chance.bool {likelihood: 5}
    instruction = 'Now... ' + 'Repeat the previous instruction'
    instruction = 'Now... ' + 'Repeat the previous instruction, if you choose'
    instruction = 'Now... ' + 'Repeat the previous instruction, but as quickly as possible'
    instruction = 'Now... ' + 'Repeat the previous instruction, but as slowly as possible'
    instruction = 'Now... ' + 'Repeat the previous instruction, but without lifting your hand'

  if @ticks > 5 and @chance.bool {likelihood: 10}
    instruction = 'Now... ' + 'Connect up to ' + @chance.integer({min: 2, max: @count}) + ' things'

  if @ticks > 6 and @chance.bool {likelihood: 10}
    instruction = 'Now... ' + 'Read a poem'
    instruction = 'Now... ' + 'Destroy a portion of the work'
    instruction = 'Now... ' + 'Put on new music'
    instruction = 'Now... ' + 'Go outside'
    instruction = 'Now... ' + 'Listen to a song... put a lyric into the work'

  if @chance.bool {likelihood: 1}
    instruction = 'Now... ' + 'Quit now if you want'

  if @ticks < 6 and @chance.bool {likelihood: 5}
    instruction = 'Now...' + 'Perform the next instruction with your eyes closed'

  console.log instruction

  if !@lines
    @lines = 0

  @lines++
  @ctx.font = '14px sans-serif';
  y = 100 + (@lines * 40)
  @ctx.fillStyle = @fillColor
  @ctx.fillText(@lines + ': '+instruction, 50, y);

  # @data.forEach((d,i) =>
  #   ###########################
  #   #   Modify each particle  #
  #   ###########################
  #   noiseValue = @simplex.noise2D(d.x, d.y)
  #
  #   if @chance.bool {likelihood: 50}
  #     d.x += @chance.floating {min: -2, max: 2}
  #
  #   if @chance.bool {likelihood: 50}
  #     d.y += @chance.floating {min: -2, max: 2}
  #
  #   # Simplex noise is always random, not seeded
  #   # This will introduce randomness even with the same seed
  #   # Use with care, and for subtle effects
  #   if noiseValue > 0
  #     d.x += @chance.floating {min: -2, max: 2}
  #   else
  #     d.y += @chance.floating {min: -2, max: 2}
  #
  #   ###########################
  #   # Then paint the particle #
  #   ###########################
  #   @ctx.beginPath()
  #   @ctx.rect d.x, d.y, 1, 1
  #   # @ctx.fillStyle = d.color
  #   @ctx.fillStyle = @fillColor
  #   @ctx.fill()
  #   @ctx.closePath()
  # )


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
