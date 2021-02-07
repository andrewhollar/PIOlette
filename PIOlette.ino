// NewPing abstracts away the signals required to initiate a distance reading from the ultrasonic sensor
#include <NewPing.h>

// Define ultrasonic sensor pins and the maximum distance to be "pinged"
#define TRIGGER_PIN 12
#define ECHO_PIN 11
#define MAX_DISTANCE 100

// Setup Ultrasonic sensor
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

// Define pins for the button and potentiometer components. Button acts as a switch.
const int buttonPin = 7;             // Button controls which color value (S or B) is effected by distance 
const int potentiometerPin = A0;     // Potentiometer provides input to H

// Adapted from: Examples > 02.Digital > Debounce.
boolean switchState = false;         // Keeps track of affected color value false = S, true = B
int buttonReading;                   // Current reading from button (HIGH or LOW)
int prevReading = LOW;               // Previous reading from button pin
unsigned long lastPressTime = 0;     // Last time the button was pressed
unsigned long debounce = 200;        // Debounce time (milliseconds)

// Setup serial communication and sensors.
void setup() {
  Serial.begin(9600);                // Set baud rate to 9600
  pinMode(buttonPin, INPUT_PULLUP);  // Initialize button pin
}


// Checks the state of the button at each iteration through the loop (~10 times per second)
void buttonListener() {
  // Read state of button pin. HIGH when pressed, LOW otherwise
  buttonReading = digitalRead(buttonPin);

  // Button pressed -> switch state. Uses "debounce" time to ignore noise in with the circuit.
  if (buttonReading == HIGH && prevReading == LOW && millis() - lastPressTime > debounce) {  
    switchState = !switchState;  

    // Record time of button press
    lastPressTime = millis();
  }

  // Update previous recording of the button state
  prevReading = buttonReading;
}

// Returns the serial output string. This is the input that will be read in the Processing sketch.
// Contains 3 components:
//   1. Switch state (Color value controlled by ultrasonic sensor: S/B)
//   2. Potentiometer reading
//   3. Ultrasonic distance reading 
String getSerialOutput() {
  String output;
  
  // 1. Add switch state to output string
  if (!switchState) {
    output = "S "; // Specifies that the ultrasonic sensor is currently controlling Saturation
  } else {
    output = "B "; // Specifies that the ultrasonic sensor is currently controlling Brightness
  }

  // Read input from the potentiometer, mapped between the values 0 - 360 to control Hue
  int potentiometerReading = map(analogRead(potentiometerPin), 0, 1023, 360, 0);

  // 2. Add potentiometer reading to output string  
  output = String(output + String(potentiometerReading) + " ");

  
  // Read input from ultrasonic sensor, mapped between values 0 - 100 to control Saturation or Brightness
  unsigned int distance = map(sonar.ping_cm(), 2, 35, 0, 100);

  // 3. Add ultrasonic reading to output string
  output = String(output + String(distance) + "\n");

  return output;
}

// Runs continuously (~10 times per second), sending data to the Processing sketch.
void loop() {
  delay(100);

  // Check the state of the button, adjusting switch state when button is pressed.
  buttonListener();

  // Get the serial output string containing all the data required by the Processing sketch.
  String serialOutput = getSerialOutput();
  
  // Print line to Serial, this is read by the Processing sketch.
  Serial.print(serialOutput);
}
