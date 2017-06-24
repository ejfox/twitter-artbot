// Generated by CoffeeScript 1.12.6
(function() {
  var argv, canvasModule, d3, d3Node, d3n, fs, makeArt, randGen, run;

  fs = require('fs');

  d3 = require('d3');

  d3Node = require('d3-node');

  canvasModule = require('canvas-prebuilt');

  randGen = require('random-seed');

  d3n = new d3Node({
    canvasModule: canvasModule
  });

  argv = require('yargs').alias('s', 'seed').argv;

  run = function() {
    var seed;
    if (argv.seed) {
      seed = argv.seed;
    } else {
      seed = Date.now();
    }
    return makeArt(seed);
  };

  makeArt = function(seed) {
    var canvas, count, ctx, data, fileOutput, height, i, j, rand, ref, width;
    rand = new randGen();
    rand.seed(seed);
    console.log('seed', seed);
    canvas = d3n.createCanvas(850, 625);
    ctx = canvas.getContext('2d');
    width = canvas.width;
    height = canvas.height;
    i = 0;
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, width, height);
    count = rand(200);
    data = d3.range(count).map(function() {
      i++;
      return {
        x1: (width / 2) * rand(i),
        y1: rand(2),
        x2: rand(25),
        y2: rand(25),
        width: 2,
        height: i
      };
    });
    for (j = 0, ref = rand(100); 0 <= ref ? j <= ref : j >= ref; 0 <= ref ? j++ : j--) {
      ctx.fillRect(0, 0, width, height);
      data.forEach(function(d, i) {
        d.x2 = d.x2 + rand(50);
        d.y2 = d.y2 + rand(50);
        if (d.x1 < d.x2) {
          d.x1++;
        } else {
          d.x2--;
        }
        if (d.y1 < d.y2) {
          d.y1++;
        } else {
          d.y2--;
        }
        if (rand(100) > 90) {
          d.x1 = d.x1 + rand(100);
        }
        return ctx.strokeRect(d.x1, d.x2, d.x1 - d.x2, d.y1 - d.y2);
      });
    }
    fileOutput = './dist/' + seed + '.png';
    console.log('canvas output --> ' + fileOutput);
    canvas.pngStream().pipe(fs.createWriteStream(fileOutput));
    return canvas;
  };

  module.exports = makeArt;

  if (require.main === module) {
    run();
  }

}).call(this);
