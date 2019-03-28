
float rand(int seed, float ray)
{
    return mod(sin(float(seed)*363.5346+ray*674.2454)*6743.4365, 1.0);
}

void main()
{
    float time = u_time;
    float pi = 3.14159265359;
    vec2 position = ( gl_FragCoord.xy / resolution.xy / 2.0);
    position-=vec2(0.5, 0.5);
    position *= 0.7 + sin(time)* 0.2;
    
    
    position.y *= resolution.y/resolution.x;
    
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    float ang = atan(position.y, position.x);
    float dist = length(position);
    color.rgb = vec3(0.65, 0.258, 0.325) * (pow(dist, -1.0) * 0.05);
    for (float ray = 0.0; ray < 30.0; ray += 1.0)
    {
        float rayang = rand(5234, ray)*6.2+(time*0.04)*10.0*(rand(2546, ray)-rand(5785, ray))-(rand(3545, ray)-rand(5467, ray));
        rayang = mod(rayang+sin(dist*ray*0.6), pi*2.0);
        if (rayang < ang - pi) {rayang += pi*2.0;}
        if (rayang > ang + pi) {rayang -= pi*2.0;}
        float brite = .05 - abs(ang - rayang);
        brite -= dist * 0.05;
        if (brite > 0.0) {
            //color.rgb += vec3(0.2+0.4*rand(8644, ray), 0.4+0.4*rand(4567, ray), 0.5+0.4*rand(7354, ray)) * brite;
            color.rgb += vec3(0.5254, 0.08, 0.341) * brite;
        }
    }
    color.a = 1.0;
    gl_FragColor = color;
}
