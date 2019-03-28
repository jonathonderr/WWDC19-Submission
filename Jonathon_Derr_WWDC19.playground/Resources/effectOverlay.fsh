vec2 shockwave(vec3 shockParams, vec2 uv, vec2 center, float time, vec2 res) {
    vec2 texCoord = uv;
    
    float dist = distance(vec2(uv.x, uv.y / (res.x / res.y)), center);
    if ((dist >= (time - shockParams.z)) && (dist <= (shockParams.z + .1))) {
        float diff = (dist - time);
        float powDiff = 1.0 - pow(abs(diff*shockParams.x), shockParams.y);
        float diffTime = diff * powDiff;
        vec2 diffUV = normalize(uv - center);
        texCoord = uv + (diffUV * diffTime);
    }
    
    return texCoord;
}

vec3 tonemap(vec3 c){
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc = c / (c + 1.0);
    return mix((c / l + 1.0), tc, tc);
}



float normpdf(float x, float sigma)
{
    return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void main(){
    vec2 uv = vec2(gl_FragCoord.x / resolution.x / 2.0, -1.0 * (gl_FragCoord.y / resolution.y / 2.0) + 1.0);
    vec2 coord = shockwave(vec3(10.0, 0.8, shockSize * 0.1), uv, vec2(mousepos.x, mousepos.y / (resolution.x / resolution.y)), shockSize * 0.3, resolution);
    vec4 color = texture2D(texBuff, coord);
    color = mix(vec4(coord.x, 0.0, coord.y, 1.0), color, 1.0);
    
    gl_FragColor = color;
}
