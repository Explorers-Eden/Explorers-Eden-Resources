#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D InSampler;
uniform sampler2D ScopeSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform KaleidoscopeConfig {
    float Segments;
    float Zoom;
    float Rotation;
    float Speed;
    vec2 Center;
};

layout(std140) uniform ScopeConfig {
    float Scale;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

void main(){
    // Aspect-correct so the mirrored wedges stay true circular sectors on a
    // widescreen display instead of stretching into ellipses.
    vec2 aspect = vec2(OutSize.x / OutSize.y, 1.0);
    vec2 centered = (texCoord - Center) * aspect / Zoom;

    float radius = length(centered);
    float angle = atan(centered.y, centered.x) + Rotation + GameTime * Speed;

    // Fold the angle into one wedge and mirror it, so the wedge tiles seamlessly
    // all the way around instead of showing a hard seam between repeats.
    float segmentAngle = 6.283185307 / max(Segments, 1.0);
    angle = mod(angle, segmentAngle);
    angle = abs(angle - segmentAngle * 0.5);

    vec2 folded = radius * vec2(cos(angle), sin(angle));
    vec2 sampleUv = Center + folded * Zoom / aspect;

    vec3 sceneColor = texture(InSampler, sampleUv).rgb;

    // Same square-scope framing the vanilla spyglass draws: a centered square
    // sized off the shorter screen dimension, the scope texture blitted inside
    // it, and solid black filling everything outside that square.
    float squareSize = min(OutSize.x, OutSize.y) * Scale;
    vec2 squareMin = (OutSize - squareSize) * 0.5;
    vec2 pixelPos = texCoord * OutSize;

    vec3 result;
    if (pixelPos.x >= squareMin.x && pixelPos.x <= squareMin.x + squareSize &&
        pixelPos.y >= squareMin.y && pixelPos.y <= squareMin.y + squareSize) {
        vec2 scopeUv = (pixelPos - squareMin) / squareSize;
        scopeUv.y = 1.0 - scopeUv.y;
        vec4 scopeColor = texture(ScopeSampler, scopeUv);
        result = mix(sceneColor, scopeColor.rgb, scopeColor.a);
    } else {
        result = vec3(0.0);
    }

    fragColor = vec4(result, 1.0);
}
