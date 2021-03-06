(function() {
  var Chance, SimplexNoise, T, Twit, argv, artScriptChoice, artScripts, canvasModule, chance, d3, d3Node, d3n, env, exportAllScripts, fs, makeMovie, rand, randGen, runMinute, schedule, seed, tweetArt, tweetCron, uploadTweet;

  env = require('node-env-file');

  env('./.env', {
    raise: false,
    overwrite: true
  });

  fs = require('fs');

  d3 = require('d3');

  d3Node = require('d3-node');

  canvasModule = require('canvas-prebuilt');

  randGen = require('random-seed');

  Twit = require('twit');

  Chance = require('chance');

  chance = new Chance();

  SimplexNoise = require('simplex-noise');

  rand = new randGen();

  seed = Date.now();

  schedule = require('node-schedule');

  rand.seed(seed);

  argv = require('yargs').alias('f', 'force').alias('m', 'movie').argv;

  artScripts = ['12-1-3'];

  if (argv.artscript) {
    artScriptChoice = argv.artscript;
  } else {
    artScriptChoice = artScripts[rand(artScripts.length)];
  }

  d3n = new d3Node({
    canvasModule: canvasModule
  });

  T = new Twit({
    consumer_key: process.env.BOT_CONSUMER_KEY,
    consumer_secret: process.env.BOT_CONSUMER_SECRET,
    access_token: process.env.BOT_ACCESS_TOKEN,
    access_token_secret: process.env.BOT_ACCESS_TOKEN_SECRET,
    timeout_ms: 60 * 1000
  });

  exportAllScripts = function() {
    var artScript, exportArt;
    console.log('Exporting all scripts');
    artScript = 0;
    exportArt = function() {
      var art;
      artScriptChoice = artScripts[artScript];
      console.log('Exporting ' + artScriptChoice);
      art = require('./artscripts/' + artScriptChoice);
      artScript++;
      return art.init({}, function() {
        return art.saveFile(artScriptChoice, function() {
          return exportArt();
        });
      });
    };
    return exportArt();
  };

  uploadTweet = function(status, b64Content) {
    return T.post('media/upload', {
      media_data: b64Content
    }, function(err, data, response) {
      var altText, mediaIdStr, meta_params;
      mediaIdStr = data.media_id_string;
      console.log('Uploading media...' + seed + ' Twitter ID: ' + mediaIdStr);
      if (!err) {
        console.log('Twitter id:', mediaIdStr);
        altText = 'Randomly generated art from seed: ' + seed;
        meta_params = {
          media_id: mediaIdStr,
          alt_text: {
            text: altText
          }
        };
        return T.post('media/metadata/create', meta_params, function(err, data, response) {
          var params;
          if (!err) {
            params = {
              status: status,
              media_ids: [mediaIdStr]
            };
            return T.post('statuses/update', params, function(err, data, response) {
              return console.log('Uploaded', data.id);
            });
          } else {
            return console.log('Error: ', err);
          }
        });
      } else {
        return console.log('Error uploading media: ', err);
      }
    });
  };

  tweetArt = function() {
    var art;
    console.log('tweetArt');
    console.log('Running ', artScriptChoice);
    art = require('./artscripts/' + artScriptChoice);
    return art.init({}, function() {
      var artBots, canvas, tweetText;
      canvas = art.canvas;
      if (art.text) {
        tweetText = art.text + ' ' + artScriptChoice + '-' + seed;
      } else {
        tweetText = artScriptChoice + '-' + seed;
      }
      artBots = ['pixelsorter', 'a_quilt_bot', 'Lowpolybot', 'clipartbot', 'artyedit', 'artyPolar', 'artyPetals', 'IMG2ASCII', 'kaleid_o_bot'];
      if (chance.bool({
        likelihood: 0.5
      })) {
        tweetText += ' #bot2bot @' + chance.pickone(artBots);
      }
      return uploadTweet(tweetText, canvas.toDataURL().split(',')[1]);
    });
  };

  makeMovie = function() {
    var art;
    console.log('makeMovie');
    console.log('Running ', artScriptChoice);
    art = require('./artscripts/' + artScriptChoice);
    art.init = function() {
      var loopTicks, t, tMax;
      this.chance = new Chance(this.seed);
      this.simplex = new SimplexNoise(Chance.random);
      console.log('Seed:', this.seed);
      console.log('width', this.width, 'height', this.height);
      this.makeCanvas();
      this.makeParticles();
      t = 0;
      tMax = this.numTicks;
      console.log('Exporting ' + tMax + ' frames');
      loopTicks = (function(_this) {
        return function() {
          _this.tick();
          return _this.saveFile(artScriptChoice + '-mov-' + t + '-' + _this.seed, function() {
            t++;
            if (t < tMax) {
              return loopTicks();
            } else {
              return console.log('Completed exporting ticks');
            }
          });
        };
      })(this);
      return loopTicks();
    };
    return art.init();
  };

  if (argv.force) {
    tweetArt();
  } else if (argv.movie) {
    makeMovie();
  } else if (argv.exportall) {
    exportAllScripts();
  } else {
    runMinute = 20;
    console.log('Running... waiting for **:' + runMinute);
    tweetCron = schedule.scheduleJob(runMinute + ' * * * *', function() {
      console.log('Gonna tweet some art now!');
      return tweetArt();
    });
  }

}).call(this);
