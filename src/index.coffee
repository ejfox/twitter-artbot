env = require 'node-env-file'
env('./.env', {raise: false, overwrite: true})
fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
randGen = require 'random-seed'
Twit = require 'twit'
Chance = require 'chance'
chance = new Chance()
SimplexNoise = require 'simplex-noise'
rand = new randGen()
seed = Date.now()
schedule = require 'node-schedule'
rand.seed(seed)

# Arguments shortcuts that can be used from the CLI
argv = require 'yargs'
  .alias 'f', 'force'
  .alias 'm', 'movie'
  .argv

# The array of artscript names that are chosen from randomly
# artScripts = [
#   '9-10',
#   '10-1',
#   '10-2',
#   '10-3', '10-3-2',
#   '10-4', '10-4-2', '10-4-3'
#   '10-7', '10-7-2', '10-7-3', '10-7-4',
# ]
artScripts = [ '10-14' ]
# Force one script instead of the random behavior from the CLI
# by calling `node dist/index --artscript _boilerplate`
if argv.artscript
  artScriptChoice = argv.artscript
else
  artScriptChoice = artScripts[rand(artScripts.length)]

d3n = new d3Node { canvasModule }

# Set up Twitter with the keys/tokens we have in our .env file
T = new Twit(
  {
    consumer_key: process.env.BOT_CONSUMER_KEY,
    consumer_secret: process.env.BOT_CONSUMER_SECRET,
    access_token: process.env.BOT_ACCESS_TOKEN,
    access_token_secret: process.env.BOT_ACCESS_TOKEN_SECRET
    timeout_ms: 60*1000
  }
)

exportAllScripts = ->
  console.log 'Exporting all scripts'
  artScript = 0
  exportArt = ->
    artScriptChoice = artScripts[artScript]
    console.log 'Exporting '+artScriptChoice
    art = require('./artscripts/'+artScriptChoice)
    artScript++
    art.init({}, ->
      art.saveFile(artScriptChoice, ->
        exportArt()
      )
    )
  exportArt()


uploadTweet = (status, b64Content) ->
  # status: the string to be used as the tweet's text
  # b64Content: a base64 version of the image to be uploaded

  T.post('media/upload', { media_data: b64Content }, (err, data, response) ->
    # First, try to upload the image and wait for Twitter to respond
    mediaIdStr = data.media_id_string
    console.log 'Uploading media...' + seed + ' Twitter ID: '+mediaIdStr

    # If there's no error, our image uploaded
    # Now we need to add some metadata to the image
    if !err
      console.log 'Twitter id:', mediaIdStr
      # The text used for screen readers on Twitter
      altText = 'Randomly generated art from seed: '+seed
      meta_params = { media_id: mediaIdStr, alt_text: {text: altText} }

      T.post('media/metadata/create', meta_params, (err, data, response) ->
        # If setting our image metadata was successful
        # Let's reference it's ID and create our actual tweet
        if !err
          params = {
            status: status
            media_ids: [mediaIdStr]
          }

          T.post('statuses/update', params, (err, data, response) ->
            # Tweeted successfully!
            console.log('Uploaded',data.id)
          )
        else
          console.log 'Error: ', err
      )
    else
      console.log 'Error uploading media: ', err
  )

tweetArt = ->
  console.log 'tweetArt'
  console.log 'Running ', artScriptChoice
  art = require('./artscripts/'+artScriptChoice)

  art.init({}, ->
    # This is the callback for once the art is generated

    # Grab the canvas
    canvas = art.canvas

    # If there was status text defined within the artscript, use that
    # And append the artscript name and the seed
    if art.text
      tweetText = art.text + ' ' + artScriptChoice+'-'+seed
    else
      # Otherwise just use the artscript and seed
      tweetText = artScriptChoice+'-'+seed

    # There's a 14% chance that the bot will cc another artbot on the tweet
    # It selects randomly who to tweet at from this array
    # It appends "#bot2bot @handle" to the Tweet
    artBots = ['pixelsorter', 'a_quilt_bot', 'Lowpolybot', 'clipartbot',
      'artyedit', 'artyPolar', 'artyPetals', 'IMG2ASCII', 'kaleid_o_bot',
      'ImgShuffleBOT'
    ]
    if chance.bool {likelihood: 14}
      tweetText += ' #bot2bot @'+chance.pickone artBots

    # Upload the art to Twitter with the tweet text we've made
    uploadTweet(tweetText, canvas.toDataURL().split(',')[1])
  )

makeMovie = ->
  console.log 'makeMovie'
  # console.log 'Making movie...'
  console.log 'Running ', artScriptChoice

  art = require('./artscripts/'+artScriptChoice)
  # art = new genArt(seed)

  # We are going to rewrite the init function
  # So that instead of generating the art all at once
  # We can hook in and save a file on every tick
  art.init = ->
    @chance = new Chance(@seed) # init chance.js - chancejs.com
    @simplex = new SimplexNoise(Chance.random)

    console.log('Seed:', @seed)
    console.log 'width', @width, 'height', @height
    @makeCanvas()
    @makeParticles()

    t = 0 # The movie tick we're on
    tMax = @numTicks # The movie tick we end on
    console.log 'Exporting ' + tMax + ' frames'
    loopTicks = =>
      @tick()
      # console.log 'movie tick ' + t
      @saveFile(artScriptChoice + '-mov-' + t + '-' + @seed, ->
        # Save the file and when it's done, use this callback
        t++
        # If we haven't hit our last tick, advance another frame and save it
        if t < tMax
          loopTicks()
        else
          console.log 'Completed exporting ticks'
      )

    loopTicks()
    #
    # if callback
    #   callback()
  # console.log 'art.init', art.init
  art.init()

if argv.force
  # If we run this script --force we don't wait for the scheduler
  tweetArt()
else if argv.movie
  # If we run this script --movie we export every frame
  makeMovie()
else if argv.exportall
  # If we run this script --movie we export every frame
  exportAllScripts()
else
  # Run tweetArt() on the 20th minute of the hour
  runMinute = 20 # Minute of the hour to run, eg **:20
  console.log 'Running... waiting for **:'+runMinute
  # tweetCron = schedule.scheduleJob '20 * * * *', -> tweetArt()
  tweetCron = schedule.scheduleJob runMinute+' * * * *', ->
    console.log 'Gonna tweet some art now!'
    tweetArt()
