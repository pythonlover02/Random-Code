// A custom PPSSPP shader created specifically for making Metal Gear: Peace Walker look like the PS3 port, it should work on the rest of the games withouth issues.
// Created by pythonlover02: https://github.com/pythonlover02 && https://gitlab.com/pythonlover02

// This shader its heavily based on the next PPSSPP shaders/files:
// FXAA: https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/fxaa.fsh && https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/fxaa.vsh
// Color Correction: https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/colorcorrection.fsh
// PSP Color Shader: https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/psp_color.fsh
// .ini file: https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/defaultshaders.ini
// All credits to their respective creators.

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D sampler0;
varying vec2 v_texcoord0;

// FXAA uniforms
uniform vec2 u_texelDelta;

// PSP color correction constants
const float target_gamma = 2.21;
const float display_gamma = 2.2;
const mat3 pspColorMat = mat3(
    0.98,  0.04,  0.01,
    0.20, 0.795, 0.01,
   -0.18, 0.165, 0.98
);

void main() {
    // FXAA
    const float FXAA_SPAN_MAX = 8.0;
    const float FXAA_REDUCE_MUL = 1.0/8.0;
    const float FXAA_REDUCE_MIN = 1.0/128.0;

    // Precompute offsets
    vec2 offsetNW = vec2(-1.0, -1.0) * u_texelDelta;
    vec2 offsetNE = vec2( 1.0, -1.0) * u_texelDelta;
    vec2 offsetSW = vec2(-1.0,  1.0) * u_texelDelta;
    vec2 offsetSE = vec2( 1.0,  1.0) * u_texelDelta;

    // Gather samples
    vec3 rgbNW = texture2D(sampler0, v_texcoord0 + offsetNW).xyz;
    vec3 rgbNE = texture2D(sampler0, v_texcoord0 + offsetNE).xyz;
    vec3 rgbSW = texture2D(sampler0, v_texcoord0 + offsetSW).xyz;
    vec3 rgbSE = texture2D(sampler0, v_texcoord0 + offsetSE).xyz;
    vec3 rgbM  = texture2D(sampler0, v_texcoord0).xyz;

    // Luminance
    const vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    // Edge direction
    vec2 dir = vec2(
        -((lumaNW + lumaNE) - (lumaSW + lumaSE)),
         ((lumaNW + lumaSW) - (lumaNE + lumaSE))
    );

    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);

    dir = clamp(dir * rcpDirMin, vec2(-FXAA_SPAN_MAX), vec2(FXAA_SPAN_MAX)) * u_texelDelta;

    // FXAA blend
    vec3 rgbA = 0.5 * (
        texture2D(sampler0, v_texcoord0 + dir * (-1.0/6.0)).xyz +
        texture2D(sampler0, v_texcoord0 + dir * ( 1.0/6.0)).xyz
    );
    vec3 rgbB = 0.5 * rgbA + 0.25 * (
        texture2D(sampler0, v_texcoord0 + dir * (-0.5)).xyz +
        texture2D(sampler0, v_texcoord0 + dir * ( 0.5)).xyz
    );

    float lumaB = dot(rgbB, luma);
    vec3 color = (lumaB < lumaMin || lumaB > lumaMax) ? rgbA : rgbB;

    // Color Correction
    // Constants
    const float brightnes  = 1.00;
    const float saturation = 2.00;
    const float contrast    = 1.00;
    const float gamma     = 1.50;

    // Improved saturation using Rec.709 luminance
    const vec3 lumWeights = vec3(0.2126, 0.7152, 0.0722);
    float gray = dot(color, lumWeights);
    color = mix(vec3(gray), color, saturation);

    // S-curve contrast
    color = (color - 0.5) * contrast + 0.5 + (brightnes - 1.0);
    color = color / (1.0 + abs(color - 0.5) * 0.3);

    // Gamma correction with toe/shoulder rolloff
    color = clamp(color, 0.0, 1.0);
    color = pow(color * 0.95 + 0.05, vec3(1.0/gamma));

    // PSP Color Transform
    vec3 screen = pow(color, vec3(target_gamma));
    screen = pspColorMat * screen;
    screen = clamp(screen, 0.0, 1.0);
    screen = pow(screen, vec3(1.0 / display_gamma));

    // LCD Backlight Bloom
    float bloom = dot(screen, vec3(0.3, 0.59, 0.11)) * 0.02;
    screen += bloom;

    gl_FragColor = vec4(clamp(screen, 0.0, 1.0), 1.0);
}
