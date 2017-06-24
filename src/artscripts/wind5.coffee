fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
_ = require 'lodash'
canvasModule = require 'canvas-prebuilt'
randGen = require 'random-seed'
d3n = new d3Node { canvasModule }
argv = require 'yargs'
  .alias 's', 'seed'
  .argv

run = ->
  if argv.seed
    seed = argv.seed
  else
    seed = Date.now()
  makeArt seed
makeArt = (seed) ->
  rand = new randGen()
  rand.seed(seed)

  console.log('seed', seed)

  canvas = d3n.createCanvas 850,625
  ctx = canvas.getContext '2d'

  width = canvas.width
  height = canvas.height
  i = 0

  count = rand 1500

  colorScale = d3.scaleLinear()
    .domain(0,count)
    .range('#CCC ', '#000')

  colorCatScale = d3.scaleOrdinal()

  catColors = ['#49AEC0', '#FEBF00']

  if rand(100) > 50
    catColors.push('#d6f445')

  if rand(100) > 50
    catColors.push('#45a5f4')

  if rand(100) > 80
    catColors.push('#f445b3')

  if rand(100) > 80
    catColors.push('#255054')

  if rand(100) > 80
    catColors.push('#ffbb7c')

  if rand(100) > 90
    catColors.push('#f40f5a')

  if rand(100) > 90
    catColors.push('#0ff41f')

  if rand(100) > 90
    catColors.push('#1f0426')

  colorCatScale.range(catColors)

  data = d3.range(count).map ->
    z = 150
    j = Math.abs((i % z) - (z/2));

    i++

    {
      i: i
      x: rand(width)
      y: rand(height)
      color: colorCatScale(j)
      j: j * 2
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  cycles = rand(4000)
  for i in [1..cycles]
    cycle = i
    data.forEach((d,i) ->
      if d.x < width/2
        d.x = d.x + rand 4

      if d.y > height/2
        d.y = d.y - rand 4
      else
        d.y = d.y + rand 4

      if rand(100) > 50 && d.y - (height/2)
        d.y = d.y + rand 2

       if rand(100) > 98
         d.dead = true


      # r = rand(200)
      # g = rand(90)
      # b = rand(255)
      #ctx.fillStyle = "rgba(#{r},#{g},#{b},0.25)";
      color = d.color
      c = d3.hsl color
      #c.h += rand(2)
      #c.opacity = 0.4
      d.color = c.toString()
      ctx.fillStyle = d.color
      if !d.dead
        ctx.fillRect(d.x, d.y, 1, 1);
    )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
