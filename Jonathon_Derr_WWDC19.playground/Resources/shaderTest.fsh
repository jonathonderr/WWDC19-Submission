
#define PI 3.14159265359

float random(vec2 x){
    return fract(cos(dot(x,vec2(0.0, 0.5))) * 555.545);
}

mat2 rotate(float r) {
    float c = cos(r);
    float s = sin(r);
    return mat2(c, s , -s, c);
}

float circle(vec2 p, float r) {
    return length(p) - r;
}

float rect(vec2 p, vec2 r) {
    p = abs(p) - r;
    return length(max(p, 0.0)) + min(max(p.x, p.y), 0.0);
}

void main()
{
    float time = u_time * speedFac;
     vec2 uv = vec2((gl_FragCoord.x / resolution.x / 1.0), -1.0 * (gl_FragCoord.y / resolution.y / 2.0) + 1.0) * (resolution.x/resolution.y);
    uv = vec2(uv.x - 1, uv.y - 1);

    uv = (2.0 * vec2(gl_FragCoord.x - (resolution.x / 1.0) , (-gl_FragCoord.y + resolution.y / 1.0))) / min(resolution.x, resolution.y);
    uv *= 1.0;

    if (circle(uv, 0.5) < 0.0) {
        uv *= rotate(PI * (sin(time) + 0.5)/4);
        uv *= 1.0;
    } else if (rect(uv + vec2(0.0, 0.35), vec2(5.0, 5.25)) < 0.0) {
        uv.x *= -1.0;
        uv += vec2(0.0, 0.35+sin(time/100000.0));
    } else if (rect(uv, vec2(1.0, 0.2)) < 0.0) {
        uv.x = -abs(uv.x * 0.2);
    } else if (rect(uv + vec2(0.0, -0.35), vec2(1.0, 0.25)) < 0.0) {
        uv += vec2(0.0, -0.5);
    } else {
        uv *= rotate(PI * 0.25);
    }
    
    vec3 c = mix(
                 vec3(0.0, 0.0, 0.0),
                 vec3(1.0, 1.0, 1.0),
                 step(smoothstep(-0.0, 0.1, uv.x), random(uv * 129.432))
                 );
    
    if (circle(uv, 0.5) < 0.0) {
        c = mix(
                vec3(0.0, 0.0, 0.0),
                vec3(1.0, 1.0, 1.0),
                step(smoothstep(-0.0, 0.0, uv.x), random(uv * 129.432))
                );
    }
    
    gl_FragColor = vec4(c, 1.0);
    
}

