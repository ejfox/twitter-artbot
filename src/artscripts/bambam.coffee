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
  if rand(100) > 50
    ctx.globalCompositeOperation = 'multiply'
  else
    ctx.globalCompositeOperation = 'difference'

  width = canvas.width
  height = canvas.height
  i = 0

  count = 420

  colorScale = d3.scaleLinear()
    .domain(0,count)
    .range('#CCC ', '#000')

  colorCatScale = d3.scaleOrdinal()

  if rand(100) > 50
    colorCatScale.range(['#49AEC0', '#FEBF00'])
  else
    colorCatScale.range(['#49AEC0', '#FEBF00'])

  redPoints = d3.range(3).map ->
    {
      x: rand(width)
      y: rand(height)
    }

  data = d3.range(count).map ->
    z = 150
    j = Math.abs((i % z) - (z/2));

    i++

    {
      i: i
      x: width / 2
      y: height * 0.98
      color: colorCatScale(i)
      j: j * 2
      radius: _.clamp((rand(i)) / 45, 1, width / 2)
      opacity: 0.01
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  for i in [1..25]
    cycle = i
    data.forEach((d,i) ->
      d.x = d.x + rand 192
      d.x = d.x - rand 192

      if rand(100)
        d.y = d.y - rand 92
        d.radius = d.radius + 4
      else
        d.y = d.y + rand 92
        d.radius = d.radius - 4

      if rand(100) > 95
        d.opacity = 1
      else
        d.opacity = 0.01

      color = d.color
      c = d3.hsl color
      c.h += rand(4) * 0.1
      c.opacity = d.opacity
      d.color = c.toString()
      ctx.fillStyle = d.color


      ctx.beginPath();
      x = d.x #+ i * 50; # x coordinate
      y = d.y #+ i * 50; # y coordinate
      radius = _.clamp(d.radius, 1, width / 2)
      startAngle = rand(360); # Starting point on circle
      endAngle = rand(360)
      anticlockwise = d.i % 2 isnt 0 # clockwise or anticlockwise

      ctx.arc(x, y, radius, startAngle, endAngle, anticlockwise);
      if rand(100) > 50
        ctx.fill d.color
      else
        ctx.fillStyle = 'none'
        ctx.strokeStyle = d.color
        ctx.stroke()
    )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
