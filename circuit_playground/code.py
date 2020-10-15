from adafruit_circuitplayground import cp
import time
import supervisor
import sys

cp.pixels.brightness = 0.3
_tmp_message = ""


def listen_for_message():
    global _tmp_message
    while supervisor.runtime.serial_bytes_available:
        next_char = sys.stdin.read(1)
        if next_char == "\n":
            received_message = _tmp_message
            _tmp_message = ""
            return received_message
        else:
            _tmp_message += next_char
    return None


while True:
    # Listen for a message
    message = listen_for_message()
    # We're looking for a message that looks like this:
    # LEVELS 105,152,109,194,52,51,134,104,119,162
    if message is not None and message.startswith("LEVELS"):
        # Chop off the first part: split the message on the space and take just the second part.
        message = message.split(" ")[1]
        sound_levels = message.split(",")
        for i in range(10):
            level = int(sound_levels[i])
            cp.pixels[i] = (0, 0, level)

    cp.red_led = not cp.red_led
    time.sleep(0.5)
