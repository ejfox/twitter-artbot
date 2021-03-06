// Generated by CoffeeScript 1.12.6
(function() {
  var GenArt, _, argv, art, clColors, d3, options, path, run, seed;

  path = require('path');

  d3 = require('d3');

  argv = require('yargs').alias('s', 'seed').argv;

  seed = Date.now();

  _ = require('lodash');

  clColors = require('nice-color-palettes');

  GenArt = require('@ejfox/four-seventeen');

  options = {
    filename: path.basename(__filename, '.js') + '-' + seed,
    count: 62,
    randomizeCount: true,
    numTicks: 350,
    randomizeTicks: true,
    bgColor: 'white',
    fillColor: 'black',
    opacity: 0.7
  };

  art = new GenArt(seed, options);

  art.makeParticles = function() {
    console.log('Making ' + this.count + ' particles');
    this.colors = this.chance.pickone(clColors);
    this.data = d3.range(this.count).map((function(_this) {
      return function() {
        var c, offset, offsetAmount, thickness, x, y;
        offsetAmount = _this.chance.integer({
          min: 12,
          max: _this.width * 0.6
        });
        offset = {};
        offset.x = _this.chance.floating({
          min: -offsetAmount,
          max: offsetAmount
        });
        offset.y = _this.chance.floating({
          min: -offsetAmount,
          max: offsetAmount
        });
        x = (_this.width / 2) + offset.x;
        y = (_this.height / 2) + offset.y;
        c = d3.hsl(_this.chance.pickone(_this.colors));
        c.opacity = _this.opacity;
        thickness = 1;
        if (_this.chance.bool({
          likelihood: 25
        })) {
          thickness = _this.chance.pickone([1, 2, 4, 8]);
        }
        return {
          x: x,
          y: y,
          x1: x,
          y1: y,
          x2: x + _this.chance.floating({
            min: -offsetAmount,
            max: offsetAmount
          }),
          y2: y + _this.chance.floating({
            min: -offsetAmount,
            max: offsetAmount
          }),
          color: c.toString(),
          thickness: thickness,
          v: _this.chance.integer({
            min: 1,
            max: 6
          })
        };
      };
    })(this));
    return this.data;
  };

  art.tick = function() {
    if (!this.ticks) {
      this.ticks = 0;
    }
    this.ticks++;
    return this.data.forEach((function(_this) {
      return function(d, i) {
        var noiseValue;
        noiseValue = _this.simplex.noise2D(d.x, d.y);
        if (_this.chance.bool({
          likelihood: 50
        })) {
          d.x += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
          d.x2 += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
        }
        if (_this.chance.bool({
          likelihood: 50
        })) {
          d.y += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
          d.y2 += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
        }
        if (_this.chance.bool({
          likelihood: 2
        })) {
          d.v = _.clamp(d.v, 0, 100);
          d.v += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
          if (d.x1 < (_this.width / 2)) {
            d.x1 += 0.1;
          }
          if (d.y1 < (_this.height / 2)) {
            d.y1 += 0.1;
          }
          if (d.x1 > (_this.width / 2)) {
            d.x1 -= 0.1;
          }
          if (d.y1 > (_this.height / 2)) {
            d.y1 -= 0.1;
          }
        }
        d.v = _.clamp(d.v, 0, 100);
        if (noiseValue > 0) {
          d.x += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
          d.x2 += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
        } else {
          d.y += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
          d.y2 += _this.chance.floating({
            min: -d.v,
            max: d.v
          });
        }
        _this.ctx.beginPath();
        _this.ctx.lineWidth = d.thickness;
        _this.ctx.strokeStyle = d.color;
        _this.ctx.moveTo(d.x1, d.y1);
        _this.ctx.lineTo(d.x2, d.y2);
        _this.ctx.stroke();
        return _this.ctx.closePath();
      };
    })(this));
  };

  run = function() {
    if (argv.seed) {
      seed = argv.seed;
    } else {
      seed = Date.now();
    }
    art.seed = seed;
    return art.init({
      save: true
    });
  };

  if (require.main === module) {
    run();
  }

  module.exports = art;

}).call(this);
