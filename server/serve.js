const express = require('express')
const fs = require("fs");
const path = require('path');
const bodyParser = require('body-parser');
var randomstring = require('randomstring');

var crypto = require('crypto')

const filePath = path.join(__dirname, 'sketches');
const port = 3002


const app = express()

app.use(bodyParser.text());
app.use('/static', express.static(filePath))

app.get('/', (req, res) => {
 fs.promises.readdir(filePath).then(files=>{
	res.send(JSON.stringify(files)) ;
})
});


app.post('/upload', (req, res) => {
	console.log(JSON.stringify(req.body));
	let id = crypto.createHash('md5').update(req.body.toString()).digest("hex").slice(0,5);
	//randomstring.generate({length: 5, readable:true, capitalization:'lowercase'});
	fs.promises.writeFile(path.join(filePath,id),req.body.toString());
	res.send(JSON.stringify({id})) ;

});


app.listen(port, () => console.log(`Example app listening on port ${port}!`))
