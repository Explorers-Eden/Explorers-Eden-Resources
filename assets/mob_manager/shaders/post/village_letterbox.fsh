#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D InSampler;

layout(std140) uniform LetterboxConfig {
    vec3 BarColor;
    float MaxHeight;
};

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

void main(){
    float edge = 0.004;

    float topBar = 1.0 - smoothstep(MaxHeight - edge, MaxHeight, texCoord.y);
    float bottomBar = smoothstep(1.0 - MaxHeight, 1.0 - MaxHeight + edge, texCoord.y);
    float inBar = clamp(topBar + bottomBar, 0.0, 1.0);

    vec3 color = texture(InSampler, texCoord).rgb;
    vec3 result = mix(color, BarColor, inBar * 0.8);

    fragColor = vec4(result, 1.0);
}
