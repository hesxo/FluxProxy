const express = require("express");
const path = require("path");
const app = express();

const PORT = 3000;

const APP = process.env.APP_NAME;

app.use("/images", express.static(path.join(__dirname, "images")));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
  console.log(`Response by ${APP}`);
});

app.listen(PORT, () => {
  console.log(`${APP}: Listening on port ${PORT}`);
});
