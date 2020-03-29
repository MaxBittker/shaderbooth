const express = require("express");
const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");
const crypto = require("crypto");
var cors = require("cors");

const filePath = path.join(__dirname, "sketches");
const port = 3002;

const app = express();

app.use(cors());
app.options("*", cors());
app.use(bodyParser.text());
app.use("/static", express.static(filePath));

let cacheFiles = [];
app.get("/", (req, res) => {
  fs.promises.readdir(filePath).then(files => {
    cacheFiles = files;
    res.send(JSON.stringify(files));
  });
});

app.post("/upload", (req, res) => {
  let id = crypto
    .createHash("md5")
    .update(req.body.toString())
    .digest("hex")
    .slice(0, 5);
  fs.promises
    .writeFile(path.join(filePath, id), req.body.toString(), { flag: "wx" })
    .catch(err => {
      console.log(err);
    });
  res.send(JSON.stringify({ id }));
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
