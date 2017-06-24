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

  count = rand 350
  data = d3.range(count).map ->
    i++
    x = rand(width)
    y = rand(height)
    color = 'rgb(237, 11, 79)'
    c = d3.hsl color
    c.h += rand(120)
    {
      x1: rand(width)
      y1: rand(height)
      x2: rand(92)
      y2: rand(92)
      width: 2
      height: i
      color: c.toString()
      size: 4
    }

  for [0..100]
    # ctx.fillStyle = 'rgba(255,255,255,0.1)';
    # ctx.fillRect(0, 0, width, height);

    data.forEach((d,i) ->
      if rand(100) > 50
        d.x = d.x++
      else
        d.x = d.x--

      if d.y % 3
        d.y++
      size = rand d.size + i

      color = d.color
      c = d3.hsl color
      c.h += rand(8)
      c.s -= rand(1)
      c.opacity = 0.25
      d.color = c.toString()
      if rand(100) > 20
        ctx.strokeStyle = d.color
      else
        ctx.strokeStyle = '#FFF'

      ctx.strokeRect((d.x1 - size),(d.y1 - size),size,size)
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
