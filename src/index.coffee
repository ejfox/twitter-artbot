env = require 'node-env-file'
env('./.env', {raise: false})
fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
randGen = require 'random-seed'
Twit = require 'twit'
rand = new randGen()
seed = Date.now()
rand.seed(seed)

artScripts = ['102', 'noise', 'wind2', 'wind3', 'wind5']
artScriptChoice = artScripts[rand(artScripts.length)]

d3n = new d3Node { canvasModule }

T = new Twit(
  {
    consumer_key: process.env.BOT_CONSUMER_KEY,
    consumer_secret: process.env.BOT_CONSUMER_SECRET,
    access_token: process.env.BOT_ACCESS_TOKEN,
    access_token_secret: process.env.BOT_ACCESS_TOKEN_SECRET
    timeout_ms: 60*1000
  }
)

uploadTweet = (status, b64Content) ->
  T.post('media/upload', { media_data: b64Content }, (err, data, response) ->
    mediaIdStr = data.media_id_string
    console.log 'Uploading media...' + seed + ' Twitter ID: '+mediaIdStr
    if !err
      console.log 'Twitter id:', mediaIdStr
      altText = 'Randomly generated art from seed: '+seed
      meta_params = { media_id: mediaIdStr, alt_text: {text: altText} }

      T.post('media/metadata/create', meta_params, (err, data, response) ->
        if !err
          params = {
            status: status
            media_ids: [mediaIdStr]
          }
          T.post('statuses/update', params, (err, data, response) -> console.log(data))
        else
          console.log 'Error: ', err
      )
    else
      console.log 'Error uploading media: ', err
  )
console.log 'Running ', artScriptChoice
canvas = require('./artscripts/'+artScriptChoice)(seed)

# Upload that image to Twitter
uploadTweet(artScriptChoice+'-'+seed, canvas.toDataURL().split(',')[1])
