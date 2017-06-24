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

  count = rand(200)
  data = d3.range(count).map ->
    i++
    {
      x1: (width / 2) * rand(i)
      y1: rand(2)
      x2: rand(25)
      y2: rand(25)
      width: 2
      height: i
    }

  for [0..rand(100)]

    #ctx.fillStyle = 'rgba(255,255,255,0.1)';
    ctx.fillRect(0, 0, width, height);

    data.forEach((d,i) ->
      d.x2 = d.x2 + rand(50)
      d.y2 = d.y2 + rand(50)

      if d.x1 < d.x2
        d.x1++
      else
        d.x2--

      if d.y1 < d.y2
        d.y1++
      else
        d.y2--


      if rand(100) > 90
        d.x1 = d.x1 + rand(100)

      ctx.strokeRect(d.x1,d.x2,(d.x1 - d.x2),(d.y1 - d.y2))
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
