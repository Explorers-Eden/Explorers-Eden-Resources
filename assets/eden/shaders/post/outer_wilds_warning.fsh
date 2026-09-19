#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D InSampler;
uniform sampler2D IconSampler;

#include <minecraft:globals.glsl>

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform WarningConfig {
    vec2 IconSize;
    vec2 Margin;
    float FadeSeconds;
    float HoldSeconds;
    float WaitSeconds;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

void main(){
    vec3 sceneColor = texture(InSampler, texCoord).rgb;

    vec2 pixelPos = texCoord * OutSize;
    vec2 iconMin = vec2(Margin.x, OutSize.y - Margin.y - IconSize.y);
    vec2 iconMax = iconMin + IconSize;

    vec3 result = sceneColor;

    if (pixelPos.x >= iconMin.x && pixelPos.x <= iconMax.x && pixelPos.y >= iconMin.y && pixelPos.y <= iconMax.y) {
        vec2 iconUV = (pixelPos - iconMin) / IconSize;
        iconUV.y = 1.0 - iconUV.y;
        vec4 iconColor = texture(IconSampler, iconUV);

        float t = GameTime * 1200.0;
        float cycleLength = FadeSeconds + HoldSeconds + FadeSeconds + WaitSeconds;
        float cycle = mod(t, cycleLength);

        float pulse;
        if (cycle < FadeSeconds) {
            pulse = smoothstep(0.0, FadeSeconds, cycle);
        } else if (cycle < FadeSeconds + HoldSeconds) {
            pulse = 1.0;
        } else if (cycle < FadeSeconds + HoldSeconds + FadeSeconds) {
            pulse = 1.0 - smoothstep(FadeSeconds + HoldSeconds, FadeSeconds + HoldSeconds + FadeSeconds, cycle);
        } else {
            pulse = 0.0;
        }

        result = mix(sceneColor, iconColor.rgb, iconColor.a * pulse);
    }

    fragColor = vec4(result, 1.0);
}
