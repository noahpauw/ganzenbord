varying vec2 v_vTexcoord;
varying vec2 v_vVertexPosition;
varying vec4 v_vColour;

uniform float time;
uniform float alpha;
uniform float intensity;
uniform float cloud_size;
uniform float threshold;
uniform sampler2D clouds;

void main()
{
	float cloud = texture2D(clouds, v_vVertexPosition / cloud_size + vec2(time * 0.03, time * 0.01)).r;
	cloud *= texture2D(clouds, v_vVertexPosition / (cloud_size * 1.19) + vec2(time * 0.034, time * 0.012)).r;
	
	cloud -= 0.5;
	
    vec4 main_color = texture2D( gm_BaseTexture, v_vTexcoord * vec2(1.0, -1.0) + vec2(cloud * 0.323 * intensity, cloud * 0.116 * intensity) * v_vColour.r );
	
	cloud += 0.5;
	cloud = smoothstep(0.0, threshold, cloud);
	
	main_color.a *= alpha * pow(cloud, 10.0);
	
	gl_FragColor = main_color;
}
