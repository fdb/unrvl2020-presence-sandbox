const express = require("express");
const app = express();
const listeners = [];
const connnections = [];

//middlewares
app.use(express.static("public"));

//routes
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/client/index.html");
});

//Listen on port 3000
server = app.listen(process.env.PORT || 3000);
const io = require("socket.io")(server);

// Socket connections
io.on("connection", (socket) => {
  console.log("New user connected");
  connnections.push(socket);
});

function produceSoundLevels() {
  // Invent 10 random sound levels between 0-255.
  const soundLevels = [];
  for (let i = 0; i < 10; i++) {
    soundLevels.push(Math.floor(Math.random() * 256));
  }
  io.sockets.emit("soundLevels", soundLevels);
}

setInterval(produceSoundLevels, 1000);
