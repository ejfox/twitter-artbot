var env = require('node-env-file');
var express = require('express');
var cache = require('express-cache-headers')
var fs = require('fs')
var app = express();
var exec = require('child_process').exec;
var _ = require('lodash')

app.set('port', (process.env.PORT || 5000));

app.use(express.static(__dirname + '/public'));

app.use(cache(10))

// views is directory for all template files
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

// Artscript route without seed
app.get('/art/:artscript', cache({ttl: 604800}), function(req, res){
  var artscript = req.params.artscript

  // var seed = Date.now()
  var seed = 'example'
  console.log('Artscript ' + artscript + ' requested with seed: ' + seed)

  var filename = artscript + '-' + seed + '.png'
  path = 'dist/' + filename

  if (fs.existsSync(path)) {
    console.log('If file exists, load it and pass it, bada boom bada bing')
    var img = fs.readFileSync(path);
    res.writeHead(200, {'Content-Type': 'image/png' });
    res.end(img, 'binary');
  } else {
    console.log('File does not already exist')
    // We're going to return the result as a png
    res.setHeader('Content-Type', 'image/png');
    // Call the appropriate artscript
    var art = require('./dist/artscripts/2018/'+artscript)
    art.seed = seed
    // TODO: Some how save the generated result to a file
    // If it doesn't exist already

    // Pass a callback that when its done generating, we pull
    // the canvas and pipe it back as the response
    art.init({}, function(){
      canvas = art.canvas
      canvas.pngStream().pipe(res)

      var buf = canvas.toBuffer();
      fs.writeFileSync(path, buf)
    })
  }
})

// With seed
app.get('/art/:artscript/:seed', cache({ttl: 604800}), function(req, res){
  console.log('with seed')
  // Look for a seed in the URL
  if(req.params.seed !== undefined)  {
    var seed = req.params.seed
  }

  var artscript = req.params.artscript

  console.log('Artscript ' + artscript + ' requested with seed: ' + seed)

  var filename = artscript + '-' + seed + '.png'
  path = 'dist/' + filename

  if (fs.existsSync(path)) {
    console.log('If file exists, load it and pass it, bada boom bada bing')
    var img = fs.readFileSync(path);
    res.writeHead(200, {'Content-Type': 'image/png' });
    res.end(img, 'binary');
  } else {
    console.log('File does not already exist')
    // We're going to return the result as a png
    res.setHeader('Content-Type', 'image/png');
    // Call the appropriate artscript
    var art = require('./dist/artscripts/2018/'+artscript)
    art.seed = seed
    // TODO: Some how save the generated result to a file
    // If it doesn't exist already

    // Pass a callback that when its done generating, we pull
    // the canvas and pipe it back as the response
    art.init({}, function(){
      canvas = art.canvas
      canvas.pngStream().pipe(res)

      var buf = canvas.toBuffer();
      fs.writeFileSync(path, buf)
    })
  }
})

// availableArtScripts = function() {
//   var artScripts = []
//   fs.readdir('./src/artscripts/2018', function(err, scripts){
//     console.log('Scripts: ', scripts)
//
//     scripts.forEach(function(d,i){
//       // console.log('i', i)
//       // console.log('d', d)
//       scriptName = d.split('.')[0]
//       // console.log(scriptName)
//       artScripts.push(scriptName)
//     })
//   })
//   return artScripts
// }

app.get('/', cache({ttl: 300}), function(request, response) {
  // response.render('pages/index');

  // art = require('./dist/index.js');

  var artImg = _.template(`
    <h2 style="font-family:sans-serif;">
      <%= scriptName %>
    </h2>
    <img
      src="art/<%= scriptName %>"
      alt=""
      style="width: 100%; height: auto;"/>
  `)

  seed = Date.now()

  pageHtml = ""

  var artScripts = []
  fs.readdir('./src/artscripts/2018/', function(err, scripts){
    console.log('Scripts: ', scripts)

    // scripts.reverse() // So page displays top to bottom

    scripts.forEach(function(d,i){
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
