varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float alpha;
uniform float flame_intensity;

void main()
{
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor.rgb = mix(vec3(1.0), gl_FragColor.rgb * flame_intensity, alpha);
}
