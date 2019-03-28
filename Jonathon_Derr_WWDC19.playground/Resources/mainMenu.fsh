
void main() {
    
    vec2 uv = ( gl_FragCoord.xy / resolution.xy / 2.0);
    uv.y = uv.y * 4.0;
    
    uv.y -= 1.5;
    vec4 color= vec4(0.0);
    
    color += step(uv.y, cos(25.0 * uv.x + u_time * 5.0) * 0.25 * cos(u_time) + 0.55) * vec4(0.0, 1.0, 1.0, 1.0);
    color -= step(uv.y + 0.01, cos(25.0 * uv.x + u_time * 5.0) * 0.25 * cos(u_time) + 0.5) * vec4(0.0, 1.0, 1.0, 1.0);
    
    color += step(uv.y, cos(10.0 * uv.x + u_time) * sin(2.0 * u_time + uv.x * 50.0) * 0.05 + 0.55) * vec4(0.5, 0.5, 0.5, 1.0);
    color -= step(uv.y, cos(10.0 * uv.x + u_time) * sin(2.0 * u_time + uv.x * 50.0 + 3.1415) * 0.05 + 0.45) * vec4(0.5, 0.5, 0.5, 1.0);
    
    color += step(uv.y, cos(9.0 * uv.x + u_time) * sin(2.0 * u_time + uv.x * 50.0) * 0.05 + 0.55) * vec4(0.1, 0.5, 0.0, 1.0);
    color -= step(uv.y, cos(.0 * uv.x + u_time) * sin(2.0 * u_time + uv.x * 50.0 + 3.1415) * 0.05 + 0.45) * vec4(0.5, 0.5, 0.0, 1.0);
    
    color += step(uv.y, cos(50.0 * uv.x + u_time / 5.0) * 0.15 * cos(u_time) + 0.55) * vec4(1.0, 0.0, 0.0, 1.0);
    color -= step(uv.y + 0.02, cos(50.0 * uv.x + u_time / 5.0) * 0.15 * cos(u_time) + 0.5) * vec4(1.0, 0.0, 0.0, 1.0);
    
    gl_FragColor = vec4(color.xyz, 1.0);
}
