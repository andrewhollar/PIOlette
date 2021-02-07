class PColor {
  int h;
  int s;
  int b;
  boolean hueLock;
  boolean saturationLock;
  boolean brightnessLock;
  
  PColor(int h_, int s_, int b_) {
    h = h_;
    s = s_;
    b = b_;
    
    // Initialize locks to false
    hueLock = false;
    saturationLock = false;
    brightnessLock = false;
  }
  
  // Return a color object based on the PColor's hsb values
  color getColor() {
    return color(h, s, b);
  }
}
