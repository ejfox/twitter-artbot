var env = require('node-env-file');
var express = require('express');
var app = express();
var exec = require('child_process').exec;

app.set('port', (process.env.PORT || 5000));

app.use(express.static(__dirname + '/public'));

// views is directory for all template files
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.get('/', function(request, response) {
  // response.render('pages/index');

  response.set('Content-Type', 'text/html');
  response.send(new Buffer('<h1>Tweeting</h1>'));

  var cmd = 'node dist/index.js';

  exec(cmd, function(error, stdout, stderr) {
    // command output is in stdout
    console.log(stderr)
  });
});

app.listen(app.get('port'), function() {
  console.log('Node app is running on port', app.get('port'));
});
