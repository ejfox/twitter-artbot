# Twitter Art Bot
# @417am1975

## What it does
A framework for [generative art](https://en.wikipedia.org/wiki/Generative_art) made with Coffeescript, D3, Canvas and random numbers.

A boilerplate art script file with useful libraries and scaffolding is provided to create new works quickly. (`src/artscripts/_boilerplate.coffee`)

This repo can also be deployed to Heroku to create a Twitter bot that tweets randomly-selected art scripts every hour.

## Development

`npm install` before your first use.

Run `npm dev` in another tab to automatically compile any .coffee file when it is saved

To run any individual art script, you can (assuming you are in the project root) do `node dist/artscripts/$FILENAME`

To run the boilerplate example you would do `node dist/artscripts/_boilerplate`

To get started on a new artscript, you can clone the boilerplate `cp src/artscripts/_boilerplate.coffee src/artscripts/MY-NEW-ARTSCRIPT.coffee` and then modifying that with your editor `atom src`

To force the bot to randomly pick an artscript to run and tweet, use `node dist/index -force`

To force the bot to randomly pick an artscript to export every frame, use `node dist/index -movie`

### Twitter Bot Setup
Create a [new Twitter app and get your consumer key and token](https://apps.twitter.com/).

Rename `.env-example` to `.env` and add your Twitter authentication details.

## Useful commands

`watch -n0 node dist/artscripts/10-14` repeatedly runs the `10-14` artscript

`ffmpeg -framerate 24 -pattern_type glob -i '*.png' -c:v libx264 -pix_fmt yuv420p $FILENAME.mp4` combines all exported .png files into a movie

## Common options
There are a few common options used for artscripts.

+ **seed** is the seed used for the random number generators. For the most part, an artscript run with the same seed will produce the same image every time. Your results may vary.
+ **count** is the number of particles to place on the page.
+ **numTicks** is the number of times to run the `tick()` function in the artscript. In `-movie` mode, each tick is exported as a frame.
+ **width** and **height** are the width and height of the canvas in pixels.
+ **text** is the text in the tweet that accompanies the image.

## Development web view
The development web view is located at `src/webserver.js`

To quickly see changes when iterating on a script, this creates a simple web server that shows the latest .png created in the `/dist/` folder. You can navigate to it at `localhost:3000`

Works well when paired with [atom-browser](https://atom.io/packages/atom-browser)
![dev browser set-up](http://ej-fox.s3.amazonaws.com/screenshots/Screenshot%202018-12-15%2013.33.23.png)

## Gallery web view
The art script gallery is located at `src/webserver_gallery.js`

The URL structure is: host/ARTSCRIPT/SEED

This will return a .png file for that artscript with the specified seed

## Examples
![9-10](https://i.imgur.com/96fLEBe.png)
![10-2](https://i.imgur.com/WNcRDgg.png)
![10-3-2](https://i.imgur.com/bxW0bex.png)
![10-4-3](https://i.imgur.com/BTgXBOQ.png)
![10-3](https://i.imgur.com/HGAz9QZ.png)
![10-7-2](https://i.imgur.com/Y77isUO.png)
![11-6-3](https://i.imgur.com/FOR6L5f.png)
