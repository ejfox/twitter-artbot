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
  #ctx.globalCompositeOperation = 'multiply'
  ctx.globalCompositeOperation = 'difference'

  width = canvas.width
  height = canvas.height
  i = 0

  #count = rand 20
  count = 5

  colorScale = d3.scaleLinear()
    .domain(0,count)
    .range('#CCC ', '#000')

  colorCatScale = d3.scaleOrdinal()
    #.range(['#49AEC0', '#FEBF00', '#00feb2', '#fe0072', '#330d70'])
  if rand 100 > 50
    colorCatScale.range ['rgb(108, 244, 142)', 'rgb(39, 182, 227)']
  else
    colorCatScale.range ['#999', '#CCC', '#000', '#FFF']

  data = d3.range(count).map ->
    z = count / width
    j = Math.abs((i % z) - (z/2));

    i++

    {
      i: i
      x: width / 2
      y: height - rand(100)
      color: colorCatScale(i)
      j: j
      radius: rand(10)
      vx: 0
      vy: 4
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  for i in [1..180]
    cycle = i
    data.forEach((d,i) ->

      step1 = rand(22)

      color = d.color
      c = d3.hsl color
      #c.h += rand(10) * 0.1
      c.opacity = 0.25
      d.color = c.toString()
      #ctx.fillStyle = d.color


      ctx.beginPath();

      x = d.x
      d.y = d.y - 1
      y = d.y

      if rand(100) > 30
        d.radius = d.radius + ( step1 / 2 )
      else
        d.radius = d.radius - 4

      radius = rand(d.radius)
      startAngle = 0
      endAngle = cycle
      #anticlockwise = d.i % 2 isnt 0 # clockwise or anticlockwise
      anticlockwise = true

      ctx.arc(x, y, radius, startAngle, endAngle, anticlockwise);

      # if rand(100) > 50
      #   ctx.fill d.color
      # else
      #   ctx.fillStyle = 'none'
      #   ctx.strokeStyle = d.color
      #   ctx.stroke()

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
