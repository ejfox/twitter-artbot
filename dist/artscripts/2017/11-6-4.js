// Generated by CoffeeScript 1.12.6
(function() {
  var GenArt, _, argv, art, clColors, d3, options, path, run, seed;

  path = require('path');

  d3 = require('d3');

  argv = require('yargs').alias('s', 'seed').argv;

  seed = Date.now();

  _ = require('lodash');

  clColors = require('nice-color-palettes/100');

  GenArt = require('@ejfox/four-seventeen');

  options = {
    filename: path.basename(__filename, '.js') + '-' + seed,
    count: 50,
    randomizeCount: true,
    numTicks: 5000,
    randomizeTicks: true,
    bgColor: 'white',
    fillColor: 'black'
  };

  art = new GenArt(seed, options);

  art.makeParticles = function() {
    var startX;
    console.log('Making ' + this.count + ' particles');
    this.colors = this.chance.pickone(clColors);
    this.color = this.chance.pickone(this.colors);
    this.ctx.globalCompositeOperation = 'multiply';
    if (this.count <= 2) {
      this.count = 3;
    }
    this.curveOptions = [d3.curveBasisClosed, d3.curveBasisOpen];
    this.line = d3.line().x(function(d) {
      return d.x;
    }).y(function(d) {
      return d.y;
    }).curve(d3.curveBasisOpen).context(this.ctx);
    startX = this.chance.integer({
      min: 100,
      max: this.width - 100
    });
    this.data = d3.range(this.count).map((function(_this) {
      return function(d, i) {
        var c, offset, offsetAmount, x, y;
        offsetAmount = _this.chance.integer({
          min: 125,
          max: _this.width / 2
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
        y = _this.chance.integer({
          min: 0,
          max: _this.height
        });
        y += i * 25;
        c = d3.hsl('white');
        c.opacity = _this.opacity;
        return {
          x: startX,
          y: y,
          color: c.toString(),
          radius: 4
        };
      };
    })(this));
    return this.data;
  };

  art.tick = function() {
    var c, sStep;
    if (!this.ticks) {
      this.ticks = 0;
    }
    this.ticks++;
    this.data.forEach((function(_this) {
      return function(d, i) {
        var maxStep, noiseValue;
        noiseValue = _this.simplex.noise2D(d.x, d.y) * 2;
        d.x += noiseValue;
        d.y += noiseValue;
        d.x = _.clamp(d.x, 0, _this.width);
        d.y = _.clamp(d.y, 0, _this.height);
        maxStep = (i * 2) * 0.65;
        if (i === _this.data.length - 1) {
          maxStep *= 2;
        }
        maxStep = _.clamp(maxStep, 0, _this.width / 4);
        if (_this.chance.bool({
          likelihood: 20
        })) {
          d.x += _this.chance.floating({
            min: -maxStep,
            max: maxStep
          });
        }
        if (_this.chance.bool({
          likelihood: 20
        })) {
          return d.y += _this.chance.floating({
            min: -maxStep,
            max: maxStep
          });
        }
      };
    })(this));
    c = d3.hsl(this.color);
    if (this.chance.bool()) {
      sStep = 0.1;
      c.s += this.chance.floating({
        min: -sStep,
        max: sStep
      });
    }
    if (this.chance.bool()) {
      c.h += 0.1 + (this.ticks / 10000);
    }
    if (c.h === 359) {
      d.h = 0;
    }
    c.opacity = 0.05;
    this.color = c.toString();
    this.ctx.beginPath();
    this.line(this.data);
    this.ctx.lineWidth = 1.5;
    if (this.chance.bool()) {
      this.ctx.strokeStyle = this.color;
    } else {
      this.ctx.strokeStyle = this.bgColor;
    }
    return this.ctx.stroke();
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