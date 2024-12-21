varying vec2 v_vTexcoord;
varying vec2 v_vVertexPosition;
varying vec4 v_vColour;

uniform sampler2D clouds;
uniform vec2 advancement;
uniform vec2 resolution;
uniform float inversion;

void main()
{
	float cloud = texture2D(clouds, v_vVertexPosition / 650.0 + advancement).r;
	cloud *= texture2D(clouds, v_vVertexPosition / 700.0 + vec2(advancement.x * 0.93, advancement.y * 0.68)).r;
	
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-15.0, 0.0) / resolution + vec2(cloud * 0.022, cloud * 0.014));
}
