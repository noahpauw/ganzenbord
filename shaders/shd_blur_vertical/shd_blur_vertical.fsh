varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 resolution;

void main()
{
	// Weights
	float weight[17];
	weight[0] = 0.00012597362860840769;
	weight[1] = 0.0007446041079987486;
	weight[2] = 0.0034435216862976196;
	weight[3] = 0.012461222628734335;
	weight[4] = 0.03528933351975869;
	weight[5] = 0.07821619801579502;
	weight[6] = 0.13569593845347466;
	weight[7] = 0.18428309925579386;
	weight[8] = 0.19591523912005082;
	weight[9] = 0.1630494254618494;
	weight[10] = 0.10622507340321961;
	weight[11] = 0.05417149270828158;
	weight[12] = 0.021622637520068544;
	weight[13] = 0.006754510209874248;
	weight[14] = 0.0016511326425519093;
	weight[15] = 0.00031581076277779224;
	weight[16] = 0.00003478687486504272;
	
	vec4 main_color = vec4(0.0);
	int index = 0;
	for(float i = -8.0; i < 8.0; i++) {
		index += 1;
		main_color += texture2D( gm_BaseTexture, v_vTexcoord * vec2(1.0, -1.0) + vec2(0.0, i / resolution.y) ) * weight[index];
	}
    gl_FragColor = main_color;
}
