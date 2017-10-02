var env = require('node-env-file');
var express = require('express');
var app = express();
var exec = require('child_process').exec;

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

app.get('/', function(request, response) {
  // response.render('pages/index');

  // art = require('./dist/index.js');

  response.set('Content-Type', 'text/html');
  response.send(new Buffer('<h1>Hi</h1>'));

  // var cmd = 'node ./dist/index.js';
  // exec(cmd, function(error, stdout, stderr) {
  //   // command output is in stdout
  //   console.log(stderr)
  // });


});

app.listen(app.get('port'), function() {
  console.log('Node app is running on port', app.get('port'));
});
