// Generated by CoffeeScript 1.12.6
(function() {
  var T, Twit, artScriptChoice, artScripts, canvas, canvasModule, d3, d3Node, d3n, env, fs, rand, randGen, seed, uploadTweet;

  env = require('node-env-file');

  env('./.env', {
    raise: false
  });

  fs = require('fs');

  d3 = require('d3');

  d3Node = require('d3-node');

  canvasModule = require('canvas-prebuilt');

  randGen = require('random-seed');

  Twit = require('twit');

  rand = new randGen();

  seed = Date.now();

  rand.seed(seed);

  artScripts = ['102', 'wind2', 'wind3', 'wind5', 'strangecircles', 'strangecircles2', 'strangecircles3', 'confetti', 'confetti2', 'confetti3', 'boxes', 'boxes2', 'boxes3'];

  artScriptChoice = artScripts[rand(artScripts.length)];

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
              return console.log(data);
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

  console.log('Running ', artScriptChoice);

  canvas = require('./artscripts/' + artScriptChoice)(seed);

  uploadTweet(artScriptChoice + '-' + seed, canvas.toDataURL().split(',')[1]);

}).call(this);
