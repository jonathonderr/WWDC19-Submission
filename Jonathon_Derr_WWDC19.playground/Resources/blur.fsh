
vec3 normpdf(float x, float sigma){
    float np = 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
    return vec3(np, 1.0, 1.0);
}

void main(){
    
     vec2 uv = vec2(gl_FragCoord.x / resolution.x / 2.0, -1.0 * (gl_FragCoord.y / resolution.y / 2.0) + 1.0);
    
    int mSize = 11;
    int kSize = (mSize-1)/2;
    float array[11];
    vec3 final_colour = vec3(0.0);
    float sigma = 7.0;
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j)
    {
        array[kSize+j] = array[kSize-j] = normpdf(float(j), sigma).r;
    }

    for (int j = 0; j < mSize; ++j)
    {
        Z += array[j];
    }

    for (int i=-kSize; i <= kSize; ++i)
    {
        for (int j=-kSize; j <= kSize; ++j)
        {
            final_colour += array[kSize+j]*array[kSize+i]*texture2D(texBuff, (vec2(gl_FragCoord.x / 2.0 + float(i), -gl_FragCoord.y / 2.0 + resolution.y + float(j))) / vec2(resolution.x, resolution.y)).rgb;

        }
    }

    vec4 color = vec4(final_colour/(Z*Z), 1.0);
    
    gl_FragColor = mix(texture2D(texBuff, uv), color, 1.0);
}
