

void main()
{
float t;
t = u_time * speedFac;
    vec2 uv = (2. * gl_FragCoord.xy - resolution * 2.0) / resolution.y;
    uv /= 2.0;
vec2 r = resolution + vec2(100, 100),
o = uv * resolution.y;
o = vec2(length(o) / r.x - 0.1, atan(o.y,o.x));
vec4 s = .07*cos(1.5*vec4(0,1,2,1) + t + o.y + cos(o.y) * cos(t)),
e = s.yzwx,
f = max(o.x-s,e-o.x);
gl_FragColor = dot(clamp(f*r.y,0.,1.), 72.*(s-e)) * (s-.1) + f;
}
