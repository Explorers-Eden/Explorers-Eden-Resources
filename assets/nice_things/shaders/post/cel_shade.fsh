#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D InSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform CelShadeConfig {
    float Levels;
    float EdgeThreshold;
    float EdgeThickness;
    float Saturation;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

void main(){
    vec2 oneTexel = (1.0 / InSize) * EdgeThickness;

    vec4 center = texture(InSampler, texCoord);

    // Sample all 8 neighbors so diagonal edges are caught too, not just axis-aligned ones.
    float lumLeft  = luminance(texture(InSampler, texCoord - vec2(oneTexel.x, 0.0)).rgb);
    float lumRight = luminance(texture(InSampler, texCoord + vec2(oneTexel.x, 0.0)).rgb);
    float lumUp    = luminance(texture(InSampler, texCoord - vec2(0.0, oneTexel.y)).rgb);
    float lumDown  = luminance(texture(InSampler, texCoord + vec2(0.0, oneTexel.y)).rgb);
    float lumNW = luminance(texture(InSampler, texCoord + vec2(-oneTexel.x, -oneTexel.y)).rgb);
    float lumNE = luminance(texture(InSampler, texCoord + vec2( oneTexel.x, -oneTexel.y)).rgb);
    float lumSW = luminance(texture(InSampler, texCoord + vec2(-oneTexel.x,  oneTexel.y)).rgb);
    float lumSE = luminance(texture(InSampler, texCoord + vec2( oneTexel.x,  oneTexel.y)).rgb);

    float edge = abs(lumLeft - lumRight) + abs(lumUp - lumDown)
               + abs(lumNW - lumSE) + abs(lumNE - lumSW);

    // Posterize per channel directly from the source color, keeping hues true instead of
    // deriving bands from a graded/desaturated intermediate.
    vec3 posterized = floor(center.rgb * Levels + 0.5) / Levels;
    float gray = luminance(posterized);
    vec3 gradedColor = mix(vec3(gray), posterized, Saturation);

    vec3 outColor = mix(gradedColor, vec3(0.0), step(EdgeThreshold, edge));

    fragColor = vec4(outColor, center.a);
}
