import processing.serial.*;

// This will read sensor data from the arduino via COM port
Serial arduinoPort;

// The base UI is composed of a Palette and a PLocks object
Palette p;
PSidebar ps;

// Keeps record of most recent readings from two sensors
int potentiometerReading;
int ultrasonicReading;

// Number of colors in the initial palette present on startup
int numColors = 3;

// Keeps track of the number of palettes saved during one session. Used for naming output files.
int saveNum = 0;

//Keeps track of which color parameter the ultrasonic sensor is changing (either Saturation / Brightness)
boolean satCtrl;

// Setup PIOlette UI and open communication with the arduino
void setup() {
  // Initialize UI
  size(480, 900); 

  // Set maximum frame rate to 24
  frameRate(24);

  // Initialize communication with arduino using the same baud rate: 9600
  arduinoPort = new Serial(this, Serial.list()[2], 9600);
  arduinoPort.bufferUntil('\n');

  // Set color mode to Hue-Saturation-Brightness
  colorMode(HSB, 360, 100, 100);

  // Initialize palette and Locks
  p = new Palette(numColors, 0, 0);
  ps = new PSidebar(p);

  // Initialize ultrasonic sensor to control saturation
  satCtrl = true;

  // Set initial readings to 0
  potentiometerReading = 0;
  ultrasonicReading = 0;
}

// This is called a maximum of 24 times per second, updating the UI
void draw() {
  // Read serial input from the arduino
  if (arduinoPort.available() > 0) {
    // Read an entire line
    String tempVal = arduinoPort.readStringUntil('\n');
    if (tempVal != null) {     
      String[] arduinoInput = splitTokens(tempVal);
      // If all the expected values are present, parse the line
      if (arduinoInput.length >= 3) {
        parseSerialString(arduinoInput);
        p.updateActiveColor(satCtrl, ultrasonicReading, potentiometerReading);
      }
    }
  }
  
  background(p.colors[p.numColors - 1].getColor());  
  // Display palette
  p.display(false);
  // Display color value locks
  ps.display(mouseX, mouseY, p.activeColor);  
}

// Function to parse a line from the Serial port, called only if the 3 expected values are present
void parseSerialString(String[] arduinoInput) {
  // Update the switch state of button 
  updateSBCtrl(arduinoInput[0]);
  
  // Update sensor readings
  potentiometerReading = int(arduinoInput[1]);
  ultrasonicReading = int(arduinoInput[2]);
}

// Function to update the satCtrl field variable.
void updateSBCtrl(String val) {
  if (val.equals("S")) {
    satCtrl = true;
  } else if (val.equals("B")) {
    satCtrl = false;
  }
}

// Event handler called every time the mouse is released. 
void mouseReleased() {
  if (mouseX > p.lockBorder && mouseX < width) {
    // Update locks if the click registered within the width of the locks
    ps.updateLocks(mouseY);
  }
}

// Event listener that will update the active color when a user hits the UP/DOWN keys.
void keyPressed() {
  //Keypad keys
  if (key == CODED) {
    if (keyCode == UP) {           // Activate previous color
      p.prevColor();
    } else if (keyCode == DOWN) {  // Activate next color
      p.nextColor();
    } else if (keyCode == LEFT) {  // Remove color
      p.removeColor(); 
    } else if (keyCode == RIGHT) { // Add color
      p.addColor(); 
    }
  } else if (key == 's' || key == 'S') { //Save palette to .png
    p.display(true);
    saveFrame("p-" + padSaveNumber(4) + ".png");
    saveNum += 1; 
  } else if (key == 'n' || key == 'N') { //Generate new palette
    p = new Palette(p.numColors, 0, 0);
    ps = new PSidebar(p);
  }

}

// Add zeros to save number up to the number of digits provided
// ex: 2 -> 0002 when digits = 4
String padSaveNumber(int digits) {
  int zero = 0;
  String saveNum_ = str(saveNum);
  String num = saveNum_;
  for (int i = 0; i < (digits - saveNum_.length()); i++) {
    num = str(zero) + num;
  }
  
  return num;
}
