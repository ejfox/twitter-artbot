// Generated by CoffeeScript 1.12.6
(function() {
  var Chance, GenArt, _, argv, canvasModule, d3, d3Node, fs, path, run,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs-extra');

  d3 = require('d3');

  _ = require('lodash');

  d3Node = require('d3-node');

  canvasModule = require('canvas-prebuilt');

  Chance = require('chance');

  path = require('path');

  argv = require('yargs').alias('s', 'seed').argv;

  GenArt = (function() {
    function GenArt(seed) {
      this.tickTil = bind(this.tickTil, this);
      this.tick = bind(this.tick, this);
      this.makeParticles = bind(this.makeParticles, this);
      this.init = bind(this.init, this);
      var d3n;
      console.log('Seed:', seed);
      d3n = new d3Node({
        canvasModule: canvasModule
      });
      this.seed = seed;
      this.chance = new Chance(this.seed);
      this.opacity = 0.99;
      this.width = 900;
      this.height = 900;
      console.log('width', this.width, 'height', this.height);
      this.text = "Hello world";
      this.count = 99;
      this.numTicks = 9999;
      this.count = this.chance.integer({
        min: 1,
        max: this.count
      });
      this.numTicks = this.chance.integer({
        min: 50,
        max: this.numTicks
      });
      this.canvas = d3n.createCanvas(this.width, this.height);
      this.ctx = this.canvas.getContext('2d');
      this.clampNum = this.chance.floating({
        min: 2,
        max: 12,
        fixed: 2
      });
      this.ctx.fillStyle = '#DBE2CE';
      this.ctx.fillRect(0, 0, this.width, this.height);
      if (this.chance.bool({
        likelihood: 95
      })) {
        this.ctx.globalCompositeOperation = 'multiply';
      }
    }

    GenArt.prototype.init = function(options, callback) {
      if (options == null) {
        options = {};
      }
      this.makeParticles();
      this.tickTil(this.numTicks);
      if (options.save) {
        this.saveFile();
      }
      if (callback) {
        return callback();
      }
    };

    GenArt.prototype.makeParticles = function() {
      var circleColor, circleCount, circleSize, color, colors;
      console.log('Making ' + this.count + ' particles');
      this.text += ' ' + this.count + ' particles';
      colors = [''];
      color = this.chance.pickone(colors);
      circleSize = this.chance.integer({
        min: 6,
        max: this.width / 20
      });
      circleCount = this.chance.integer({
        min: 2,
        max: 6
      });
      circleColor = this.chance.pickone(colors);
      this.centers = d3.range(circleCount).map((function(_this) {
        return function(d, i) {
          var cColor, x, y;
          cColor = _this.chance.pickone(colors);
          x = _this.chance.integer({
            min: 0,
            max: _this.width
          });
          y = _this.chance.integer({
            min: 0,
            max: _this.height
          });
          return {
            x: x,
            y: y,
            color: cColor
          };
        };
      })(this));
      return this.data = d3.range(this.count).map((function(_this) {
        return function(d, i) {
          var c, halfWidth, x, y;
          halfWidth = _this.width / 2;
          x = halfWidth + _this.chance.integer({
            min: -halfWidth,
            max: halfWidth
          });
          y = 0;
          c = d3.hsl(color);
          return {
            id: i,
            radius: 1,
            x: x,
            y: y,
            color: c.toString(),
            opacity: _this.opacity,
            vx: 0,
            vy: 0,
            dead: false,
            deadmarked: false,
            cattraction: _this.chance.integer({
              min: 1.2,
              max: 9
            }),
            center: _this.chance.integer({
              min: 0,
              max: _this.centers.length - 1
            })
          };
        };
      })(this));
    };

    GenArt.prototype.tick = function(callback) {
      var clampNum, gvx, gvy;
      this.ticks++;
      gvy = this.chance.floating({
        min: -1,
        max: 1
      });
      gvx = this.chance.floating({
        min: -1,
        max: 1
      });
      clampNum = this.clampNum;
      return this.data.forEach((function(_this) {
        return function(d, i) {
          var c, cColor, dColor, myC;
          if (d.y >= _this.height) {
            d.y = 0;
          }
          if (d.x >= _this.width) {
            d.x = 0;
          }
          myC = _this.centers[d.center];
          d.vy = gvy + d.vy + _this.chance.floating({
            min: -2,
            max: 2.5,
            fixed: 2
          });
          d.vy = _.clamp(d.vy, -clampNum, clampNum);
          d.vx = gvx + d.vx + _this.chance.floating({
            min: -2,
            max: 2,
            fixed: 2
          });
          d.vx = _.clamp(d.vx, -clampNum, clampNum);
          if (_this.chance.bool({
            likelihood: i * 0.01
          })) {
            d.radius += (d.vx + d.vy) / 10;
          }
          cColor = d3.hsl(myC.color);
          dColor = d3.hsl(d.color);
          if (cColor.h < dColor.h) {
            dColor.h -= _this.chance.floating({
              min: -0.1,
              max: 1,
              fixed: 2
            });
            d.color = dColor.toString();
            if (cColor.s < dColor.s) {
              dColor.s -= _this.chance.floating({
                min: -0.1,
                max: 1,
                fixed: 2
              });
              d.color = dColor.toString();
            }
          }
          if (_this.chance.bool({
            likelihood: i * 0.001
          })) {
            d.radius += 0.1;
          }
          if (_this.chance.bool({
            likelihood: i * 0.01
          })) {
            if (d.y > _this.height / 2) {
              d.vy--;
            }
          }
          if (_this.chance.bool({
            likelihood: _this.ticks * 0.001
          })) {
            d.dead = true;
          }
          if (_this.chance.bool({
            likelihood: d.i * 0.001
          })) {
            d.radius = 0.11;
          }
          if (_this.chance.bool({
            likelihood: _this.ticks * 0.001
          })) {
            _this.chance.integer({
              min: 0,
              max: _this.centers.length - 1
            });
          }
          d.y = d.y + (d.vy / 4);
          d.x = d.x + (d.vx / 4);
          d.x = _.clamp(d.x, 0, _this.width);
          d.y = _.clamp(d.y, 0, _this.height);
          c = d3.hsl(d.color);
          if (_this.chance.bool()) {
            c.h += _this.chance.floating({
              min: 0,
              max: 0.25
            });
          }
          c.opacity = d.opacity;
          d.color = c.toString();
          if (!d.dead) {
            _this.ctx.beginPath();
            _this.ctx.arc(d.x, d.y, d.radius, 0, 2 * Math.PI);
            _this.ctx.closePath();
            _this.ctx.fillStyle = d.color;
            _this.ctx.fill();
          }
          if (callback) {
            return callback;
          }
        };
      })(this));
    };

    GenArt.prototype.tickTil = function(count) {
      var i, j, ref;
      console.log('Ticking ' + this.data.length + ' particles ' + count + ' times');
      console.time('ticked for');
      i = 0;
      for (j = 0, ref = count; 0 <= ref ? j <= ref : j >= ref; 0 <= ref ? j++ : j--) {
        i++;
        this.tick();
      }
      return console.timeEnd('ticked for');
    };

    GenArt.prototype.saveFile = function(filename) {
      var fileOutput, pngFile, stream;
      if (!filename) {
        filename = path.basename(__filename, '.js') + '-' + this.seed;
      }
      fileOutput = './dist/' + filename + '.png';
      pngFile = fs.createWriteStream(fileOutput);
      stream = this.canvas.pngStream();
      stream.on('data', function(chunk) {
        return pngFile.write(chunk);
      });
      return stream.on('end', function() {
        return console.log('canvas saved --> ' + fileOutput);
      });
    };

    return GenArt;

  })();

  run = function() {
    var genart, seed;
    if (argv.seed) {
      seed = argv.seed;
    } else {
      seed = Date.now();
    }
    genart = new GenArt(seed);
    if (argv.count) {
      genart.count = argv.count;
    }
    if (argv.ticks) {
      genart.numTicks = argv.ticks;
    }
    return genart.init({
      save: true
    });
  };

  module.exports = GenArt;

  if (require.main === module) {
    run();
  }

}).call(this);
