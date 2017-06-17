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

  count = 250

  colorScale = d3.scaleLinear()
    .domain(0,count)
    .range('#CCC ', '#000')

  colorCatScale = d3.scaleOrdinal()
    .range(['#DD577A', '#49AEC0', '#FFF0CF', '#131723'])

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
      x: rand(width / 2)
      y: rand(height / 2)
      color: colorCatScale(i)
      j: j * 2
      radius: rand(100)
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  for i in [1..100]
    cycle = i
    data.forEach((d,i) ->
      d.x = d.x + rand 5
      d.x = d.x - rand 5

      if rand(100) > 50 && d.y - (height/2)
        d.y = d.y + rand 2

      # if rand(100) > 90
      #   d.dead = true


      # r = rand(200)
      # g = rand(90)
      # b = rand(255)
      #ctx.fillStyle = "rgba(#{r},#{g},#{b},0.25)";
      color = d.color
      c = d3.hsl color
      c.h += rand(2)
      #c.opacity = 0.4
      d.color = c.toString()
      ctx.fillStyle = d.color


      ctx.beginPath();
      x = d.x + i * 50; # x coordinate
      y = d.y + i * 50; # y coordinate
      radius = d.radius + rand(d.radius); # Arc radius
      startAngle = 0; # Starting point on circle
      endAngle = (Math.PI + (Math.PI * i) / 2) + rand(cycle); # End point on circle
      anticlockwise = d.i % 2 isnt 0 # clockwise or anticlockwise

      ctx.arc(x, y, radius, startAngle, endAngle, anticlockwise);
      ctx.fill(d.color)
    )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
