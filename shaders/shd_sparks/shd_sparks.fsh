varying vec2 v_vTexcoord;
varying mat3 v_vNMatrix;
varying vec3 v_vNormal;
varying vec3 v_vVertexPosition;
varying vec3 v_vTangent;
varying vec4 v_vColour;

uniform float advancement;
uniform sampler2D normal_map;
uniform vec4 candles[64];
uniform vec4 candles_colors[64];
uniform int max_candles;
uniform vec3 camera_position;
uniform vec3 sky_color;
uniform vec3 sky_color_accent;

void main()
{	
	// Map
	vec4 sparks			= texture2D(gm_BaseTexture, v_vVertexPosition.xy / 48.0 * vec2(1.0, -1.0));
	vec3 lighting		= vec3(0.0);
	
	// Normal texture
	vec3 normal_tex			= normalize(texture2D(normal_map, v_vVertexPosition.xy / 96.0 * vec2(1.0, -1.0)).rgb * 2.0 - 1.0);
	vec3 normal_trs			= normalize(v_vNMatrix * normal_tex);
	
	// Lighting calculations
	for(int i = 0; i < max_candles; i += 1) {
		vec4 candle = candles[i];
		vec4 candles_color = candles_colors[i];
		
		float dis	= clamp(distance(v_vVertexPosition, candle.xyz) / (candle.w * 1.0), 0.0, 1.0);
		float dis_alt = clamp(distance(v_vVertexPosition, candle.xyz) / (candle.w * 0.15), 0.0, 1.0);
		float dis_far = clamp(distance(v_vVertexPosition, candle.xyz) / (candle.w * 3.5), 0.0, 1.0);
		
		vec3 to_l	= normalize(candle.xyz - v_vVertexPosition);
		float NdotL	= mix(0.2 + (dot(to_l, normal_trs) / 2.0 + 0.5) * 0.8, mix(0.75, 1.0, max(dot(to_l, normal_trs), 0.0)), 0.0);		
		
		lighting	+= mix(candles_color.rgb * 1.5, vec3(0.0), dis) * NdotL;
		lighting	+= mix(candles_color.rgb * 1.5, vec3(0.0), dis_alt);
	}
	
	float avg2		= (sparks.r + sparks.g + sparks.b) / 3.0;
	
	vec3 darkness	= lighting;
	vec3 dark_lighting = mix(sky_color, sky_color_accent, avg2);
	lighting		+= mix(dark_lighting, vec3(0.0), (darkness.r + darkness.g + darkness.b) / 3.0);
	
	sparks.rgb		*= lighting;
	
	gl_FragColor	= sparks;
	
	const float max_fog_distance = 90.0;
	float fog_distance	= clamp(distance(v_vVertexPosition, camera_position) / max_fog_distance, 0.0, 1.0);
	gl_FragColor.rgb	= mix(gl_FragColor.rgb, sky_color, pow(fog_distance, 1.7));
}
