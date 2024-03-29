// Generated by CoffeeScript 1.12.6
(function() {
  var GenArt, argv, art, clColors, d3, options, path, run, seed;

  path = require('path');

  d3 = require('d3');

  argv = require('yargs').alias('s', 'seed').argv;

  seed = Date.now();

  global.THREE = require('../../lib/three/three.js');

  require('../../lib/three/canvasrenderer.js');

  require('../../lib/three/projector.js');

  clColors = require('nice-color-palettes/100');

  GenArt = require('@ejfox/four-seventeen');

  options = {
    filename: path.basename(__filename, '.js') + '-' + seed,
    count: 5,
    numTicks: 5,
    randomizeTicks: true,
    bgColor: 'white',
    fillColor: 'black'
  };

  art = new GenArt(seed, options);

  art.makeParticles = function() {
    var bg, camSize, planeGeometry, planeMaterial;
    if (this.chance.bool()) {
      this.colors = this.chance.pickone(clColors);
    } else {
      this.colors = ['#999', '#CCC', '#000', '#FFF'];
    }
    console.log('colors ->', this.colors);
    this.cubes = [];
    this.scene = new THREE.Scene();
    bg = this.colors[this.colors.length - 1];
    this.colors.pop();
    this.scene.background = new THREE.Color(bg);
    camSize = this.chance.integer({
      min: 18,
      max: 50
    });
    this.camera = new THREE.PerspectiveCamera(camSize, 1, 1, 10000);
    this.camera.position.z = this.chance.integer({
      min: 15,
      max: 30
    });
    this.light = new THREE.PointLight(new THREE.Color(this.chance.pickone(this.colors)), 1.2);
    this.light.position.set(0, 0, 12);
    this.light.castShadow = true;
    this.light.position.y = this.chance.integer({
      min: -25,
      max: 25
    });
    this.light.position.z = this.chance.integer({
      min: 25,
      max: 90
    });
    this.scene.add(this.light);
    this.canvas.style = {};
    this.renderer = new THREE.CanvasRenderer({
      canvas: this.canvas
    });
    this.renderer.shadowMapEnabled = true;
    this.renderer.shadowMapSoft = true;
    this.renderer.shaadowMapBias = 0.0039;
    this.renderer.shadowMapDarkness = this.chance.floating({
      min: 0.1,
      max: 0.8
    });
    this.renderer.shadowMapWidth = 1024;
    this.renderer.shadowMapHeight = 1024;
    this.renderer.setSize(this.width, this.height);
    this.renderer.setClearColor(0x3399ff);
    planeGeometry = new THREE.PlaneGeometry(1000, 1000, 0);
    planeMaterial = new THREE.MeshBasicMaterial({
      color: 0xffff00,
      side: THREE.DoubleSide
    });
    this.plane = new THREE.Mesh(planeGeometry, planeMaterial);
    this.plane.receiveShadow = true;
    console.log('Making ' + this.count + ' particles');
    this.data = d3.range(this.count).map((function(_this) {
      return function() {
        var c, offset, offsetAmount, x, y;
        offsetAmount = _this.chance.integer({
          min: 25,
          max: 500
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
        x = _this.chance.integer({
          min: -5,
          max: 5
        });
        y = _this.chance.integer({
          min: -5,
          max: 5
        });
        c = d3.hsl('white');
        c.opacity = _this.opacity;
        return {
          x: x,
          y: y,
          color: c.toString()
        };
      };
    })(this));
    return this.data;
  };

  art.tick = function() {
    var rotateAmount, ticks;
    if (!this.ticks) {
      ticks = 0;
    }
    this.ticks++;
    rotateAmount = 12;
    this.data.forEach((function(_this) {
      return function(d, i) {
        var cubeSize, faces, geometry, hex, material, segments;
        cubeSize = _this.chance.integer({
          min: 2,
          max: 5
        });
        segments = 0;
        geometry = new THREE.BoxGeometry(cubeSize, cubeSize, cubeSize);
        faces = 0;
        while (faces < geometry.faces.length) {
          hex = _this.chance.pickone(_this.colors);
          geometry.faces[faces].color = new THREE.Color(hex);
          geometry.faces[faces + 1].color = new THREE.Color(hex);
          faces += 2;
        }
        material = new THREE.MeshLambertMaterial({
          color: new THREE.Color(_this.chance.pickone(_this.colors)),
          wireframe: _this.chance.bool()
        });
        _this.cubes[i] = new THREE.Mesh(geometry, material);
        _this.cubes[i].position.y = d.y;
        _this.cubes[i].position.x = d.x;
        if (_this.chance.bool()) {
          _this.cubes[i].rotation.y = _this.chance.pickone([-90, -45, 0, 45, 90]);
          _this.cubes[i].rotation.x = _this.chance.pickone([-90, -45, 0, 45, 90]);
          _this.cubes[i].rotation.z = _this.chance.pickone([-90, -45, 0, 45, 90]);
        }
        _this.cubes[i].castShadow = true;
        return _this.scene.add(_this.cubes[i]);
      };
    })(this));
    return this.renderer.render(this.scene, this.camera);
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
