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

  count = 200

  colorScale = d3.scaleLinear()
    .domain(0,count)
    .range('#CCC ', '#000')

  redPoints = d3.range(3).map ->
    {
      x: rand(width)
      y: rand(height)
    }

  data = d3.range(count).map ->
    z = width
    j = Math.abs((i % z) - (z/2));

    i++

    {
      i: i
      x: rand(width)
      y: rand(height)
      b: _.clamp(rand(255) + j, 0, 255)
      j: j
    }

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  for i in [1..200]
    cycle = i
    data.forEach((d,i) ->
      d.y = d.y + rand(3)
      ctx.fillStyle = 'rgba(0,0,0,0.25)';
      ctx.fillRect(d.x, d.y, rand(width/8), 2);
    )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
