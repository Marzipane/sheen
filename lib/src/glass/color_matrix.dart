/// The 4×5 colour matrix of CSS `saturate(s) brightness(b)` (Filter Effects Level 1), applied after the blur:
/// saturation first, then brightness, as in `backdrop-filter: blur() saturate() brightness()`.
List<double> sheenColorMatrix({required double saturation, required double brightness}) {
  final s = saturation, b = brightness;
  const r = .213, g = .715, bl = .072;
  return <double>[
    (r + (1 - r) * s) * b,
    (g - g * s) * b,
    (bl - bl * s) * b,
    0,
    0,
    (r - r * s) * b,
    (g + (1 - g) * s) * b,
    (bl - bl * s) * b,
    0,
    0,
    (r - r * s) * b,
    (g - g * s) * b,
    (bl + (1 - bl) * s) * b,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}
