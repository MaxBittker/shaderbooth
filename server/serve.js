const express = require("express");
const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");
const crypto = require("crypto");
const https = require("https");
const cors = require("cors");

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

https
  .createServer(
    {
      key: fs.readFileSync(
        "/etc/letsencrypt/live/api.shaderbooth.com/fullchain.pem",
        "utf8"
      ),
      cert: fs.readFileSync(
        "/etc/letsencrypt/live/api.shaderbooth.com/privkey.pem",
        "utf8"
      ),
      ca: fs.readFileSync(
        "/etc/letsencrypt/live/yourdomain.com/chain.pem",
        "utf8"
      )
    },
    app
  )
  .listen(port, () => console.log(`Example app listening on port ${port}!`));
