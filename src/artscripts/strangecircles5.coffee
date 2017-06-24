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

  count = rand 250

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
      x: 0
      y: height
      color: colorCatScale(i)
      j: j
      radius: 10
      vx: 1
      vy: 0
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  for i in [1..850]
    cycle = i
    data.forEach((d,i) ->
      step1 = (rand 12) + d.vx + d.radius
      step2 = (rand 12) + d.vy + d.radius

      if rand(100) > 20
        d.vx--
        d.x = d.x - step1
      else
        d.vx++
        d.x = d.x + step1

      if rand(100) > 35
        d.vx--
        d.y = d.y - step2
      else
        d.vx++
        d.y = d.y + step2
      # else
      #   d.y = d.y - rand 2

      # if rand(100) > 90
      #   d.dead = true


      # r = rand(200)
      # g = rand(90)
      # b = rand(255)
      #ctx.fillStyle = "rgba(#{r},#{g},#{b},0.25)";
      color = d.color
      c = d3.hsl color
      c.h += rand(10) * 0.1
      c.opacity = 0.75
      d.color = c.toString()
      ctx.fillStyle = d.color


      ctx.beginPath();
      x = d.x
      y = d.y

      if rand(100) > 30
        d.radius = d.radius + rand(2)

      radius = rand(d.radius)
      startAngle = _.clamp(rand(360) + (d.y / 4), 0, 180) # Starting point on circle
      #endAngle = _.clamp(rand(360), startAngle, 360)
      endAngle = 180
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
