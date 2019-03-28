

void main()
{

    vec2 position = ( gl_FragCoord.xy / resolution.xy /1.0);

    position.y *= resolution.y/resolution.x;

    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
    gl_FragColor = color;
}

