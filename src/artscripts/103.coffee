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
  count = 505

  colorScale = d3.scaleLinear()
    .range(0,count)
    .domain('#FFF', '#000')

  data = d3.range(count).map ->
    i++
    if i % 3
      color = 'rgba(209,244,255,' + 1 + ')'
    else if i % 5
      color = 'rgba(0,0,0,1)'
    else
      color = 'rgba(255,230,254,' + 1 + ')'
    {
      i: i
      x1: rand(width)
      y1: rand(height)
      x2: rand(width)
      y2: rand(height)
      color: color
    }

  data.forEach((d) ->
    #ctx.globalAlpha = 0.2
    ctx.strokeStyle = d.color
    ctx.beginPath()
    ctx.moveTo(d.x1, d.y1)
    ctx.quadraticCurveTo((d.x2/4), (d.y2 / 5 ), ( d.x2 * d.i ), d.y2)
    ctx.quadraticCurveTo((d.x2/1.5), (d.y2 / 2 ), d.x2, d.y2 + d.i)
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
