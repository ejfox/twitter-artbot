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

  data = d3.range(count).map ->
    i++
    {
      i: i
      r: _.clamp(rand(255) - ( i * 0.0001 ), 0, 255)
      g: rand(255)
      b: _.clamp(rand(255) + ( i * 0.0001 ), 0, 255)
    }



  data.forEach((d,i) ->
    imgdata.data[4*i] = d.r; # R
    imgdata.data[4*i+1] = d.g; # G
    imgdata.data[4*i+2] = d.b; # B
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
