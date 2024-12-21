varying vec2 v_vTexcoord;
varying vec2 v_vVertexPosition;
varying vec4 v_vColour;

uniform sampler2D clouds;
uniform vec2 advancement;
uniform float inversion;

void main()
{
	float cloud = texture2D(clouds, v_vVertexPosition / 650.0 + advancement).r;
	cloud *= texture2D(clouds, v_vVertexPosition / 700.0 + vec2(advancement.x * 0.93, advancement.y * 0.68)).r;
	
	cloud -= 0.25;
	
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(cloud * 0.192, cloud * 0.174));
	gl_FragColor.rgb = mix(vec3(0.0), vec3(1.0), inversion);
}
