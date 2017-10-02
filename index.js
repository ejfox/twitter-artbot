var env = require('node-env-file');
var express = require('express');
var fs = require('fs')
var app = express();
var exec = require('child_process').exec;
var _ = require('lodash')

app.set('port', (process.env.PORT || 5000));

app.use(express.static(__dirname + '/public'));

// views is directory for all template files
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

// Artscript route without seed
app.get('/art/:artscript', function(req, res){
  var artscript = req.params.artscript

  var seed = Date.now()
  console.log('Artscript ' + artscript + ' requested with seed: ' + seed)

  // We're going to return the result as a png
  res.setHeader('Content-Type', 'image/png');

  // Call the appropriate artscript
  var art = require('./dist/artscripts/'+artscript)
  art.seed = seed

  // Pass a callback that when its done generating, we pull
  // the canvas and pipe it back as the response
  art.init({}, function(){
    canvas = art.canvas
    canvas.pngStream().pipe(res)
  })
})

// With seed
app.get('/art/:artscript/:seed', function(req, res){
  var artscript = req.params.artscript

  // Look for a seed in the URL
  // If it's not there, use unix epoch
  if(req.params.seed !== undefined)  {
    var seed = req.params.seed
  } else {
    var seed = Date.now()
  }
  console.log('Artscript ' + artscript + ' requested with seed: ' + seed)

  // We're going to return the result as a png
  res.setHeader('Content-Type', 'image/png');

  // Call the appropriate artscript
  var art = require('./dist/artscripts/'+artscript)
  art.seed = seed

  // Pass a callback that when its done generating, we pull
  // the canvas and pipe it back as the response
  art.init({}, function(){
    canvas = art.canvas
    canvas.pngStream().pipe(res)
  })
})

availableArtScripts = function() {
  var artScripts = []
  fs.readdir('./src/artscripts/', function(err, scripts){
    console.log('Scripts: ', scripts)

    scripts.forEach(function(d,i){
      // console.log('i', i)
      // console.log('d', d)
      scriptName = d.split('.')[0]
      // console.log(scriptName)
      artScripts.push(scriptName)
    })
  })
  return artScripts
}

app.get('/', function(request, response) {
  // response.render('pages/index');

  // art = require('./dist/index.js');

  var artImg = _.template('<h2> <%= scriptName %> </h2> <img src="art/<%= scriptName %>/<%= seed %>" alt=""></img>')

  artScripts = availableArtScripts()
  seed = Date.now()

  console.log('---->', artScripts)

  pageHtml = ""

  var artScripts = []
  fs.readdir('./src/artscripts/', function(err, scripts){
    console.log('Scripts: ', scripts)

    scripts.forEach(function(d,i){
      // console.log('i', i)
      // console.log('d', d)
      scriptName = d.split('.')[0]
      // console.log(scriptName)
      if(scriptName === 'GenArt') {
        // Skip this one
      } else {
        artScripts.push(scriptName)
      }
    })

    artScripts.forEach(function(d,i){
      var imgHtml = artImg({scriptName: d, seed: seed})
      pageHtml += imgHtml
    })

    response.set('Content-Type', 'text/html');
    // response.send(new Buffer('<h1>Hi</h1>'));
    response.send(new Buffer(pageHtml));

  })


});

app.listen(app.get('port'), function() {
  console.log('Node app is running on port', app.get('port'));
});
