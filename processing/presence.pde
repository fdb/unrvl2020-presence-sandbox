import processing.serial.*;

import websockets.*;
WebsocketClient client;

int lastTime;
String lastMessage = "0,0,0,0,0,0,0,0,0,0";
Serial circuitPlayground = detectSerial(57600);
static int SECONDS = 1000;

void setup() {
  size(550, 300);
  client = new WebsocketClient(this, "ws://unrvl2020-presence-sandbox.herokuapp.com/socket.io/?EIO=3&transport=websocket");
  //client = new WebsocketClient(this, "wss://room.arimitb.com/socket.io/?EIO=3&transport=websocket&sid=uTBfT4rog5uu9qmdAAAT");
  lastTime = millis();
}

void draw() {
  background(200);
  String[] soundLevels = lastMessage.split(",");
  int x = 50;
  for (String level : soundLevels) {
    int levelNumber = Integer.parseInt(level);
    fill(levelNumber, 0, levelNumber);
    noStroke();
    circle(x, 150, 40);
    x += 50;
  }
  if (millis() - lastTime > 15 * SECONDS) {
    println("Sending keepalive message");
    client.sendMessage("2");
    lastTime = millis();
  }
}

void webSocketEvent(String msg) {
  // The message we're looking for looks like this:
  // 42["soundLevels",[105,152,109,194,52,51,134,104,119,162]]
  // Not sure what the 42 is doing, but we're basically ignoring it and looking for the word "soundLevels".
  // So if we DON'T see soundLevels, we will ignore this message (by returning from the function).
  if (!msg.contains("soundLevels")) return;

  // Okay so now we know that we have the right message. What do we do with it?
  // We need to just get the part that says:
  // 105,152,109,194,52,51,134,104,119,162
  // So we'll chop of the part at the start, and the two brackets at the end.
  // So here's the plan:
  // 1. Remove the first part of the message, up till the second opening bracket.
  String partToRemove = "42[\"soundLevels\",[";
  msg = msg.substring(partToRemove.length());

  // 2. Remove the last two characters of the message (the extraneous closing brackets.)
  msg = msg.substring(0, msg.length() - 2);

  // 3. Send that message to our device.
  println(msg);
  if (circuitPlayground != null) {
    circuitPlayground.write("LEVELS " + msg + "\n");
  }

  // 4. Store the message in Processing so we can draw it.
  lastMessage = msg;
}

Serial detectSerial(int baudRate) {
  String[] ports = Serial.list();
  for (String port : ports) {
    if (port.contains("ACM") || port.contains("cu.usbmodem") || port.contains("tty.usbmodem")) {
      println("Connected to", port);
      return new Serial(this, port, baudRate);
    }
  }
  println("Failed to find an usb serial");
  return null;
}