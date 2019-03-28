float hash(float n)
{
    return fract(sin(n)*43758.5453123);
}

void main() {
    vec2 xy = ( 2.* gl_FragCoord.xy - resolution.xy / 0.5) / resolution.y ;
    float time = u_time / 4.0 * speedFac;
    vec3 center = vec3( (0.5 * 2.5) - 1.25, 1., (0.4 * 2) - 1);
    vec3 pp = vec3(0.);
    float length = 4.;
    const float count = 50;
    for( float i = 0.; i < count; i+=1. )
    {
        float an = sin( time * 3.14 * .00001 ) - hash( i ) * 3.14 * 2.;
        float ra = sqrt( hash( an ) ) * .2;
        vec2 p = vec2( center.x + cos( an ) * ra, center.z + sin( an ) * ra );
        float di = distance( xy, p );
        length = min( length, di );
        if( length == di )
        {
            pp.xy = p;
            pp.z = i / count * xy.x * xy.y;
        }
    }
    vec3 shade = vec3( 1. ) * ( 1. - max( 0.0, dot( pp, center ) ) );
    
    gl_FragColor = vec4( pp + shade, 1. );
    
}
