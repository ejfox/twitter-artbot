fs = require 'fs'
d3 = require 'd3'
_ = require 'lodash'
SimplexNoise = require 'simplex-noise'
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

randomSphere = (out, scale) ->
    scale = scale || 1.0
    r = (rand(100)) * 2.0 * Math.PI
    out[0] = Math.cos(r) * scale
    out[1] = Math.sin(r) * scale
    return out

makeArt = (seed) ->
  rand = new randGen()
  rand.seed(seed)
  simplex = new SimplexNoise(rand)

  console.log('seed', seed)

  canvas = d3n.createCanvas 1700,1250
  ctx = canvas.getContext '2d'

  c1 = d3.hsl('rgb(28, 162, '+ rand(195) + ')' )

  if rand(100) > 50
    c1.h += rand(4)
  else
    c1.h -= rand(4)

  c2 = d3.hsl(c1.toString())

  c2.h += _.clamp(rand(255), 15, 255)

  width = canvas.width
  height = canvas.height

  # make bg
  #ctx.fillStyle = 'white';
  ctx.fillStyle = c1.toString()
  ctx.fillRect(0, 0, width, height);
  count = rand(2500)
  data = d3.range(count).map ->
    scale = 100
    r =
    x = (width / 2)
    y = (height / 2)


    randOffset = width
    if rand(100) > 50
      x -= rand(randOffset)
    if rand(100) > 50
      y -= rand(randOffset)
    if rand(100) > 50
      x += rand(randOffset)
    if rand(100) > 50
      y += rand(randOffset)



    # console.log 'x', x, 'y', y

    value = simplex.noise2D(x, y)

    if rand(100) > 75
      c2.h += 1

    {
      x: x
      y: y
      color: c2.toString()
      val: value
    }

  data.forEach((d,i) ->
    ctx.beginPath()
    ctx.rect d.x, d.y, 2, 2
    ctx.fillStyle = d.color
    ctx.fill()
    ctx.closePath()
  )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
