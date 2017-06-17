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

  imgdata = ctx.getImageData 0, 0, width, height

  count = imgdata.data.length

  colorScale = d3.scaleLinear()
    .range(0,count)
    .domain('#FFF', '#000')

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
      b: _.clamp(rand(255), 0, 255)
      j: j
    }


  for i in [1..3]
    cycle = i
    data.forEach((d,i) ->
      pixel = 4*i
      max = rand(80)
      if rand(100 * cycle ) > max
        imgdata.data[4*i] = d.j; # R (0-255)
        imgdata.data[4*i+1] = d.b; # G
        imgdata.data[4*i+2] = d.b; # B
        imgdata.data[4*i+3] = 120; # A
      else
        imgdata.data[4*i] = 255; # R (0-255)
        imgdata.data[4*i+1] = 255; # G
        imgdata.data[4*i+2] = 255; # B
        imgdata.data[4*i+3] = 255; # A

    )


  ctx.putImageData imgdata, 0, 0

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
