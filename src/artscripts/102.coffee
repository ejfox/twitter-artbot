fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
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

  data = d3.range(999).map ->
    i++
    {
      x1: rand(width)
      y1: rand(height)
      x2: rand(width)
      y2: rand(width / 2) * rand(1)
      width: 2
      height: i
    }

  data.forEach((d,i) ->
    ctx.beginPath()
    ctx.moveTo(d.x1, d.y1)
    ctx.lineTo(d.x2, d.y2)
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
