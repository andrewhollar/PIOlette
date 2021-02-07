class PSidebar {
  Palette p;
  int left_buffer = 30;
  int x = 11 * width / 14;
  
  PFont font;
  int fontSize = 14;
  
  PSidebar(Palette p_) {
    p = p_; 
    font = createFont("Menlo-Regular", fontSize);
    textFont(font);
  }
  
  // Mouse click detected on locks, determine which one and switch it's state
  void updateLocks(int mY) {
    // Index of PColor where click occurred
    int c = mY / p.colorHeight; 
    if (mY % p.colorHeight < (p.colorHeight / 3)) { // hue lock was clicked, switch state
      p.colors[c].hueLock = !p.colors[c].hueLock;
    } else if ((mY % p.colorHeight >= (p.colorHeight / 3)) && (mY % p.colorHeight < (2 * p.colorHeight / 3))) { // saturation lock was clicked, switch state
      p.colors[c].saturationLock = !p.colors[c].saturationLock;
    } else { // brightness lock was clicked, switch state
      p.colors[c].brightnessLock = !p.colors[c].brightnessLock;
    }
  }
  
  void display(int mX, int mY, int active) {
    fill(0, 0, 100);
    noStroke();
    for (int i = 0; i < p.numColors; i++) {
      int yColor = i * p.colorHeight;
            
      for (int j = 0; j < 3; j++) {
        int alphaChange = 0;
        fill(0, 0, 100, (75 + alphaChange));
        if (i == active) {
          alphaChange += 100; 
        }
        
        //check mouse hover
        int yLock = yColor + (j * (p.colorHeight / 3));
        if (mX > x && mX < width && mY > yLock && mY < (yLock + (p.colorHeight / 3))) {
          alphaChange += 30;
        }
               
        int lockHeight = p.colorHeight / 3;
        
        if (j == 2) {
           lockHeight = (yColor + p.colorHeight) - yLock;
        }
        noStroke();
        fill(0, 0, 100, (75 + alphaChange));
        rect(x, yLock, (4 * width / 14), lockHeight);
        
        alphaChange += 30;
        fill(0, 0, 100, (75 + alphaChange));
        strokeWeight(1);
        if (j == 0) { 
          if (p.colors[i].hueLock) {
            fill(360, 100, 100, 180);
          } 
        }
        if (j == 1) {
          if (p.colors[i].saturationLock) {
            fill(360, 100, 100, 180);
          } 
        }
        if (j == 2) { 
          if (p.colors[i].brightnessLock) {
            fill(360, 100, 100, 180);
          } 
        }
        
        int ySmall = yLock + (lockHeight / 2) - (fontSize / 3);
        int dimension = left_buffer / 3;
        
        rect(x + (left_buffer / 3), ySmall, dimension, dimension);

      }
      
      
      fill(0);
      textAlign(LEFT);
      
      int yHue = (i * p.colorHeight) + ((p.colorHeight / 3) / 2) + (fontSize / 2);
      int ySaturation = (i * p.colorHeight) + (3 * (2 * (p.colorHeight / 3) / 4)) + (fontSize / 2);
      int yBrightness = (i * p.colorHeight) + (5 * (p.colorHeight  / 6)) + (fontSize / 2);
      
      // Draw the values to the UI, overlaid on top of the locks
      text("H: " + int(p.colors[i].h), x + left_buffer, yHue);
      text("S: " + int(p.colors[i].s), (x + left_buffer), ySaturation);
      text("B: " + int(p.colors[i].b), (x + left_buffer), yBrightness);
    }
  }
}
