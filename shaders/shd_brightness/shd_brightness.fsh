varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float brightness;

void main()
{
    vec4 main_color = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	main_color.rgb += brightness;	
	
	gl_FragColor = main_color;
}
