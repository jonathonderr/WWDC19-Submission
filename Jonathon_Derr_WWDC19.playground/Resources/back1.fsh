
mat2 rotate(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, s, -s, c);
}

float hash(vec2 p) {
    return fract(44346.45 * sin(dot(p, vec2(45.45, 757.5))));
}

void main() {
    vec2 uv = (2. * gl_FragCoord.xy - resolution / 2.0) / resolution.y;
    vec3 col = vec3(0.);
    
    float time = u_time * speedFac;
    
    uv *= 4.;
    uv += time / 2.;
    
    vec2 i = floor(uv);
    vec2 f = fract(uv) - .5;
    
    
    f *= rotate(floor(hash(i) * 4.) * 3.14 / 2.0);
    
    f -= .5;
    float d = abs(length(f) - .5);
    col += smoothstep(.15, .11, d);
    
    f += 1.;
    d = abs(length(f) - .5);
    col += smoothstep(.045, .04, d);
    
    
    gl_FragColor = vec4(col, 1.);
}
