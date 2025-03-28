
  String hueToHex(double hue) {
    double s = 0.8;
    double l = 0.5;

    double c = (1 - (2 * l - 1).abs()) * s;
    double x = c * (1 - ((hue / 60) % 2 - 1).abs());
    double m = l - c / 2;

    double r = 0, g = 0, b = 0;

    if (hue < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (hue < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (hue < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (hue < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (hue < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    int ri = ((r + m) * 255).round();
    int gi = ((g + m) * 255).round();
    int bi = ((b + m) * 255).round();

    return '#${ri.toRadixString(16).padLeft(2, '0')}${gi.toRadixString(16).padLeft(2, '0')}${bi.toRadixString(16).padLeft(2, '0')}';
  }

