#version 460 core

// Liquid glass: what lies under the shape is bent by a convex lens.
//
// The rim is a steep bezel that pulls the picture outward (content just
// beyond the edge wraps into the glass), the middle is a flat, slightly
// magnifying pane, and the three colour channels bend by slightly different
// amounts at the rim (dispersion), like real glass. The frosting blur and
// saturation are composed after this pass, so the refraction stays sharp
// enough to read before it is softened.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // size of the backdrop texture (set by the engine)
uniform vec4 uRect;      // shape: origin x, y and size w, h (physical px)
uniform vec4 uShape;     // corner radius, bezel width, bend (px), dispersion
uniform vec4 uLens;      // centre magnification, unused x3
uniform sampler2D uTexture;

out vec4 fragColor;

float sdRoundRect(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

vec4 sampleAt(vec2 px) {
  vec2 uv = clamp(px / uSize, vec2(0.0), vec2(1.0));
  return texture(uTexture, uv);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;

  // The engine hands either the whole backdrop or just the clipped area;
  // when the texture is the shape's own size its origin is the shape's.
  bool local = abs(uSize.x - uRect.z) < 3.0 && abs(uSize.y - uRect.w) < 3.0;
  vec2 origin = local ? vec2(0.0) : uRect.xy;
  vec2 halfSize = uRect.zw * 0.5;
  vec2 p = frag - origin - halfSize;
  float r = min(uShape.x, min(halfSize.x, halfSize.y));
  float sd = sdRoundRect(p, halfSize, r);
  if (sd > 0.5) {
    fragColor = sampleAt(frag);
    return;
  }

  // Outward normal of the edge (gradient of the distance field).
  const float e = 1.0;
  vec2 n = vec2(
    sdRoundRect(p + vec2(e, 0.0), halfSize, r) -
      sdRoundRect(p - vec2(e, 0.0), halfSize, r),
    sdRoundRect(p + vec2(0.0, e), halfSize, r) -
      sdRoundRect(p - vec2(0.0, e), halfSize, r)
  );
  n = n / max(length(n), 1e-4);

  // Lens profile: 0 in the flat middle, rising steeply towards the rim.
  float t = clamp(-sd / max(uShape.y, 1.0), 0.0, 1.0);
  float bend = pow(1.0 - t, 2.4);

  // Whole-backdrop textures can look beyond the edge; a clipped one can
  // only look inward, which still reads as a lens.
  float dir = local ? -1.0 : 1.0;
  vec2 shift = n * bend * uShape.z * dir - p * uLens.x;

  float spread = uShape.w * bend;
  vec4 g = sampleAt(frag + shift);
  float red = sampleAt(frag + shift * (1.0 + spread)).r;
  float blue = sampleAt(frag + shift * (1.0 - spread)).b;
  fragColor = vec4(red, g.g, blue, g.a);
}
