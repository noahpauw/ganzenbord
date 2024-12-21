varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float alpha;
uniform float invert_x;
uniform float brightness;

void main()
{
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord * vec2(-invert_x, -1.0) );
	gl_FragColor.rgb += brightness;
	
	gl_FragColor.a *= alpha;
	gl_FragColor.a = clamp(gl_FragColor.a, 0.0, 1.0);
}
