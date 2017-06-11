# Create an artbot with Node, D3, and Coffeescript
##  Getting started
### Coffeescript
We’re using coffeescript because it makes writing code fun. Making art should always be fun.

`npm install —save-dev coffee-script`

Create our coffee script file in `src/index.coffee`

To watch & compile that file, we add `"dev": "(coffee --compile --output dist --watch src &);node ./dist/index.js"` to the scripts in `package.json` and to run our index.js file we add `"start": "node ./dist/index.js"`

### Screen
Now, open the terminal and type `screen`  and navigate to my folder `cd twitter-artbot`, then I type `npm dev` to start watching the coffee script file and automatically compiling it.  We’re just gonna let that run the whole time. The rest of the tutorial assumes you’ve left it running. To do that using screen I hit `ctrl-a c` to create a new screen, navigate to the same directory, and type `npm start` every time I want to run my script.

With screen, you can always go back and forth between by typing `ctrl-a p` to go to your previous screen, or `ctrl-a n` to go to the next screen.  But I digress.

### D3-Node
To start making pictures of things we need to install D3-Node with `npm install —save d3-node` and add it to our cofeescript file by requiring it on the first line in `src/index.coffee`

Now we’ll run a test to make sure d3-node is working properly.

```coffee
d3Node = require 'd3-node'
d3n = new d3Node()
d3n.createSVG(10,20).append('rect')
svgString = d3n.svgString();

console.log svgString
```

In my terminal  I type `npm start` and hit enter and get back:


> npm start
>
> twitter-artbot@1.0.0 start /Users/ejf/git/twitter-artbot
> node ./dist/index.js
>
> <svg xmlns="http://www.w3.org/2000/svg" width="10" height="20"><rect></rect></svg>

Great! D3-node is creating SVGs as expected.  Now let’s get it working with canvas and have it output image files.

### Canvas
`npm install —save canvas-prebuilt svg2png`  and download [lib/output.js from d3-node](https://github.com/d3-node/d3-node/blob/master/examples/lib/output.js) into `/lib/`.

Now, I’ll rewrite `index.coffee` to create a test .png from canvas.

```coffee
fs = require 'fs'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'

d3n = new d3Node { canvasModule }

canvas = d3n.createCanvas 500,500
ctx = canvas.getContext '2d'

width = canvas.width
height = canvas.height

data = [0,1,2,3,4,5]

data.forEach((d,i) ->
  ctx.beginPath()
  ctx.rect i*25, 150, 10, 10
  ctx.fillStyle = 'red'
  ctx.fill()
  ctx.closePath()
)

require('../lib/output.js')('index', d3n)
```

Now I run `npm start` again, and a file appears at `dist/index.png`  - it has 6 red squares in it. Perfect!

## Creating generative art
Now that we’ve created our ‘hello world’ of saving out images created in D3, let’s start setting up everything we’ll need to make generative art to fill those images. We’re going to need a few things. The first is a pseudo random number generator (PRNG). I use math.Random() quite frequently to create unanticipated and unexpected works. With a PRNG, I can use seed math.Random() with a number or a string- and all of the random numbers I create can be reproduced later if I start with the same seed. This lets me recreate a particular image later if I really like it or want to improve it or modify it.

### Seeded random number generator
To install our PRNG, we will run `npm install —save random-seed` and  in our index.coffee file, add a bit of logic to start using it.

> rand = new randGen()
> seed = Date.now()
> rand.seed(seed)

We’ll also modify the function that saves our image so that the image name is our seed.

> require('../lib/output.js')(seed, d3n)


Now when I run `npm start` I get a new file at `dist/1497201418233.png` which is the UTC timestamp when that file was run. Now our images will always have unique names that also reflect the seed.

### Randomized art
Let’s modify `src/index.coffee` to create randomized art. We’ll start by simply placing rectangles randomly on the screen. We’ll also add d3 by doing `npm install —save d3` and requiring it.

We’ll use D3 to create an array of objects that will have randomized X and Y positions using the seeded PRNG we added earlier. When we call `rand(width)` we tell it to return us a random number between 0 and the width.

```
fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
canvasModule = require 'canvas-prebuilt'
randGen = require 'random-seed'
rand = new randGen()
seed = Date.now()
rand.seed(seed)

d3n = new d3Node { canvasModule }

canvas = d3n.createCanvas 500,500
ctx = canvas.getContext '2d'

width = canvas.width
height = canvas.height

data = d3.range(20).map ->
  {
    x: rand(width)
    y: rand(height)
  }

data.forEach((d,i) ->
  ctx.beginPath()
  ctx.rect d.x, d.y, 10, 10
  ctx.fillStyle = 'red'
  ctx.fill()
  ctx.closePath()
)

require('../lib/output.js')(seed, d3n)
```

Now when I run `npm start` I get a new file `./dist/1497202235818.png` that has a bunch of randomized red squares in it.  Awesome.

## Tweeting out our images
We are going to use the npm library Twit to interface with Twitter. You will also need to create a new application at <apps.twitter.com> where you will get your API key and token.

Putting them in this file and then uploading to GitHub is *bad*. We should be storing them in our environment variables. Live fast and die young, I say.

We’re going to initialize Twit with the info we got from apps.twitter.com  and create a new function that will post a tweet with the image we generated, and the seed as the text.

```coffee
T = new Twit(
  {
    consumer_key: '...'
    consumer_secret: '...'
    access_token: '...'
    access_token_secret: '...'
    timeout_ms: 60*1000
  }
)

uploadTweet = (status, b64Content) ->
  #console.log 'b64Content', b64Content
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
```

Now, after we create our canvas, we can upload it like this:

> uploadTweet(seed, canvas.toDataURL().split(',')[1])
> # The split seperates out the metadata and just leaves the base64 info for Twitter


I run `npm start` and see

> npm start
>
> twitter-artbot@1.0.0 start /Users/ejf/git/twitter-artbot
> node ./dist/index.js
>
> canvas output --> ./dist/1497209235161.png
> Uploading media...1497209235161 Twitter ID: 873984921454489602
> Twitter id: 873984921454489602
> { created_at: 'Sun Jun 11 19:26:59 +0000 2017',  id: 873984929725644800,  id_str: '873984929725644800',  text: '1497209235161 https://t.co/aAb1GsVGld', etc.. }

which means my tweet has been uploaded! Success! Now our script creates a random image and uploads it whenever the script is run.

## Separate generative art scripts
However, we don’t necessarily want to upload the tweet everytime the script is run. Also I’ve been thinking that I probably want to create multiple generative art scripts that are chosen at random and then uploaded.

So let’s separate out the logic for creating our art from uploading the tweet.

I’m going to pull out all of the logic to create my canvas and put it in a separate file. I’m calling mine `101.coffee` and putting it in `/src/artscripts/101.coffee`. It looks like this:

```coffee
fs = require 'fs'
d3 = require 'd3'
d3Node = require 'd3-node'
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

  data = d3.range(420).map ->
    {
      x: rand(width)
      y: rand(height)
    }

  data.forEach((d,i) ->
    ctx.beginPath()
    ctx.rect d.x, d.y, 2, 120
    ctx.fillStyle = 'black'
    ctx.fill()
    ctx.closePath()
  )

  fileOutput = './dist/' + seed + '.png'
  console.log('canvas output --> ' + fileOutput);

  # Save image locally to /dist/
  canvas.pngStream().pipe(fs.createWriteStream(fileOutput))

  return canvas

module.exports = makeArt
if(require.main == module)
  run()
```

Now, `index.coffee` is only concerned with choosing a script to run, receiving the canvas back, and tweeting it out.
```coffee
artScripts = ['101']

# Randomly choose from the artScripts array
artScriptChoice = artScripts[rand(artScripts.length)]
console.log 'Running ', artScriptChoice
canvas = require('./artscripts/'+artScriptChoice)(seed, rand)

# Upload that image to Twitter
uploadTweet(seed, canvas.toDataURL().split(',')[1])
```

Now I can add as many generative art scripts to `src/artscripts/` as I want, and I can choose which get run by adding or removing them from the artScripts variable. For example, I’m going to make a modification to my first script and call it `another.coffee` - then I’m going to update my artScripts array so it looks for it like `artScripts = [‘101, ‘another’]`.

I’ve also made it so I can run my scripts from the command line by themselves without uploading to Twitter. This will be handy for development. Now I can run each script individually, with a custom seed if I want.

> node dist/artscripts/101.js -s hello
> 	seed hello
> 	canvas output --> ./dist/hello.png


Or just use a random seed if I don’t specify one
```bash
> node dist/artscripts/101.js
seed 1497212380512
canvas output --> ./dist/1497212380512.png
```

Handy.

## Running on Heroku
If you’re not on Heroku yet, sign up and install their CLI. Then create a new heroku instance for this app.

Then login on the cli `heroku login` and put in your Heroku account details. Then add your Heroku remote `heroku git:remote -a your-heroku-appname`

To deploy to Heroku:
`bash`
`git add .`
`git commit -am ‘hello new twitterbot!’`
`git push heroku master`

To add the scheduler, in our repo run `heroku addons:create scheduler:standard` and then in your app dashboard you’ll see a new scheduler screen. We’re going to set it to run `npm start` every hour. This will run our main script `dist/index.js` which will pick a random generative art script from `dist/artscripts/` run it and then tweet the result.

Now when we want to change our scripts or add more, we can just copy `src/artscripts/101.coffee` into a new file and push to Heroku when we’re finished.

You can view my bot at [@417am1975](https://twitter.com/417am1975)
