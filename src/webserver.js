var app, port;

var express = require('express');
var fs = require('fs'),
    path = require('path'),
    _ = require('lodash');
app = express();

port = 3000;

function getLatestFile({directory, extension}, callback){
  fs.readdir(directory, (_ , dirlist)=>{
    const latest = dirlist.map(_path => ({stat:fs.lstatSync(path.join(directory, _path)), dir:_path}))
      .filter(_path => _path.stat.isFile())
      .filter(_path => extension ? _path.dir.endsWith(`.${extension}`) : 1)
      .sort((a, b) => b.stat.mtime - a.stat.mtime)
      .map(_path => _path.dir);
    callback(latest[0]);
  });
}

app.get('/', (function(_this) {
  return function(req, res) {
    res.sendFile(path.join(__dirname + '/webserver.html'));
  };
})(this));

app.get('/latest', (function(_this) {
  return function(req, res) {
    //return res.send('Hello World!');

    var latestImage = getLatestFile({directory:'dist', extension:'png'}, (filename=null)=>{
    var img = fs.readFileSync('dist/'+filename);
    res.writeHead(200, {'Content-Type': 'image/png' });
    res.end(img, 'binary');

});


  };
})(this));

app.use(express["static"]('dist'));

app.listen(port, (function(_this) {
  return function() {
    return console.log(`Webserver running on port ${port}!`);
  };
})(this));
