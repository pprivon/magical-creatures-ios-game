// GradientBackground.fsh
//
// A shader that creates a smooth gradient background with animated waves.

// Imported from SKShader
void main() {
    // Get normalized texture coordinates (0.0 to 1.0)
    vec2 uv = v_tex_coord;
    
    // Get color uniform parameters (passed from Swift code)
    vec4 top_color = u_top_color;
    vec4 bottom_color = u_bottom_color;
    
    // Calculate base gradient
    vec4 gradient_color = mix(bottom_color, top_color, uv.y);
    
    // Add subtle animated waves
    float time = u_time * 0.3; // Slow down the time
    float wave1 = sin(uv.x * 10.0 + time) * 0.01;
    float wave2 = cos(uv.x * 5.0 - time * 0.7) * 0.015;
    
    // Combine waves and adjust the gradient mix
    float wave_offset = wave1 + wave2;
    vec4 final_color = mix(bottom_color, top_color, uv.y + wave_offset);
    
    // Add subtle noise pattern
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    final_color.rgb += noise * 0.03; // Very subtle noise
    
    // Set pixel color
    gl_FragColor = final_color;
}
