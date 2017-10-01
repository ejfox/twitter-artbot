# Twitter Art Bot

## What it does
Makes [generative art](https://en.wikipedia.org/wiki/Generative_art) and then automatically posts it to Twitter.

## Development
Create a [new Twitter app and get your consumer key and token](https://apps.twitter.com/).

Download this repo. Rename `.env-example` to `.env` and add your Twitter authentication details.

`npm install` before your first use.

Run `npm dev` in another tab to automatically compile any .coffee file when it is saved

To run any individual art script, you can (assuming you are in the project root) do `node dist/artscripts/$FILENAME` - to run the boilerplate example you would do `node dist/artscripts/$FILENAME`

I will generally make changes to my art script and then run the above command to check it out, then tweak a little, run it again, so on and so forth.

To force the bot to randomly pick an artscript to run and tweet, use `node dist/index -force`

To force the bot to randomly pick an artscript to export every frame of, use `node dist/index -movie`

To get started on a new artscript, you can clone the boilerplate `cp src/artscripts/_boilerplate.coffee src/artscripts/MY-NEW-ARTSCRIPT.coffee` and then modifying that `atom src`

## Options
There are a few options available for artscripts.

+ **seed** is the seed used for the random number generators. For the most part, an artscript run with the same seed will produce the same image every time. Your results may vary.
+ **count** is the number of things or particles to place on the page.
+ **numTicks** is the number of times to run the `tick()` function in the artscript. In `-movie` mode, each tick is exported as a frame.
+ **width** and **height** are the width and height of the canvas in pixels.
+ **text** is the text in the tweet that accompanies the image.

## Web view
Artscripts can be accessed from the web using the express server in `index.js`

The URL structure is: host/ARTSCRIPT/SEED

This will return a .png file for that artscript with the specified seed

TODO: We will also have an index page that allows the user to select different art scripts and generate new images by calling the URL
