class Palette {
  int numColors;                      // Number of colors within the Palette
  PColor[] colors;                    // Array containing exactly numColors amount of PColor objects
  int activeColor;                    // Index of the active color. Active color means it's values are impacted by the sensor readings.
  int[] upperLeft;                    // Upper left corner of palette
  int lockBorder = 11 * width / 14;   // Border of locks
  int colorHeight;                    // Height (in pixels) of a single color
  int highlightWidth = 5;             // Width of the active color indicator drawn on the right hand side of UI
  
  Palette(int numC, int x, int y) {
    numColors = numC;
    colors = new PColor[numC];
    activeColor = 0;
    colorHeight = height / numColors;
    upperLeft = new int[]{x, y};
    for (int i = 0; i < numColors; i++) { // Initialize each PColo to have random hsb values
      int h = (int) random(0, 360);
      int s = (int) random(0, 100);
      int b = (int) random(0, 100);
      colors[i] = new PColor(h, s, b);
    }
  }
  
  // Switch active color to the previous color
  // If there is no previous color, set active color to the last color 
  void prevColor() {
    activeColor -= 1;
    if (activeColor == -1) {
      activeColor = numColors - 1;
    }
  }
  
  // Switch active color to the next color
  // If there is no next color, set active color to the first color
  void nextColor() {
    activeColor += 1;
    if (activeColor == numColors) {
      activeColor = 0;
    }
  }
  
  // Add a new color to the palette if there are 7 or fewer colors within the palette
  void addColor() {
    if (numColors < 8) {
      p.numColors += 1; 
      PColor[] new_colors = new PColor[numColors];
      
      for (int i = 0; i < numColors - 1; i++) {
        new_colors[i] = colors[i]; 
      }
      
      int h = (int) random(0, 360);
      int s = (int) random(0, 100);
      int b = (int) random(0, 100);
  
      new_colors[numColors - 1] = new PColor(h, s, b);
      colors = new_colors;
      colorHeight = height / numColors;
    }
  }
  
  // Remove the last color from the palette if there are 2 or more colors within the palette
  void removeColor() {
    if (numColors > 1) {
      if (activeColor == numColors - 1) {
       activeColor = numColors - 2; 
      }
      numColors -= 1;
      PColor[] new_colors = new PColor[numColors];
      
      for (int i = 0; i < numColors; i++) {
        new_colors[i] = colors[i]; 
      }
      
      colors = new_colors;
      colorHeight = height / numColors;
    }
  }
  
  // Updates the active color based on sensor readings.
  void updateActiveColor(boolean saturation, int ultrasonicReading, int potentiometerReading) {
    if (!colors[activeColor].hueLock) {
      colors[activeColor].h = potentiometerReading;
    }
  
    if (saturation) {
      if (!colors[activeColor].saturationLock) {
        colors[activeColor].s = ultrasonicReading;
      } 
    } else {
      if (!colors[activeColor].brightnessLock) {
        colors[activeColor].b = ultrasonicReading;
      } 
    }
  }
  
  // Draw the palette to the screen. If 'saving' is true, do not draw the active color highlight.
  void display(boolean saving) {
    for (int i = 0; i < numColors; i++) {
      noStroke();
      fill(colors[i].getColor());
      rect(upperLeft[0], (i * (height / numColors)), width, colorHeight);
      
      if (!saving) {
        if (i == activeColor) {
          fill(0, 0, 100);

          rect(width - highlightWidth, i * colorHeight , highlightWidth, colorHeight);
        }
      }
    }
  } 
}
