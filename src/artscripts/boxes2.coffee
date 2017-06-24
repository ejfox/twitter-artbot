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
  #ctx.globalCompositeOperation = 'difference'

  width = canvas.width
  height = canvas.height
  i = 0

  # make bg
  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, width, height);

  count = rand 200
  data = d3.range(count).map ->
    i++
    x = rand(width)
    y = rand(height)
    {
      x1: rand(width)
      y1: rand(height)
      x2: rand(42)
      y2: rand(42)
      size: 2
      height: i
    }

  for [0..120]
    if rand(100) > 75
      ctx.fillStyle = 'rgba(255,255,255,0.1)';
    else
      ctx.fillStyle = 'rgba(255,255,255,0.01)';
    ctx.fillRect(0, 0, width, height);

    data.forEach((d,i) ->
      if rand(100) > 50
        d.x = d.x++
      else
        d.x = d.x--

      d.size += rand 8

      if d.x1 > d.x2
        d.x2--
      else
        d.x1++

      ctx.strokeRect((d.x1 - d.x2),(d.y1 - d.y2),d.size + rand(i / 2),d.size + rand(i / 2))
      # ctx.beginPath()
      # ctx.moveTo(0,0)
      # #ctx.lineTo(d.x2, d.y2)
      # ctx.arcTo(d.x1,width/2,d.xy1,height/2,50);
      # ctx.stroke()

  )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
