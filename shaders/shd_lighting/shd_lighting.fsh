varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_vNMatrix;
varying vec3 v_vNormal;
varying vec3 v_vVertexPosition;

uniform sampler2D normal_map;
uniform sampler2D roughness_map;
uniform sampler2D world_map;
uniform sampler2D reflection_map;

uniform vec3 camera_position;
uniform vec4 candles[64];
uniform vec4 candles_colors[64];
uniform int max_candles;
uniform float volumetric;
uniform float no_map;
uniform float ignore_ndotl;
uniform float currently_selected;
uniform float reflection_strength;
uniform vec3 sky_color;
uniform vec3 sky_color_accent;

void main() {
	vec3 map				= texture2D(world_map, v_vVertexPosition.xy / 48.0 * vec2(1.0, -1.0)).rgb;
	vec3 N					= normalize(v_vNormal);
	
	float avg				= (map.r + map.g + map.b) / 3.0;
	
	vec3 map2				= texture2D(world_map, v_vVertexPosition.xy / 192.0 * vec2(1.0, -1.0)).rgb;
	float avg2				= (map.r + map.g + map.b) / 3.0;
	
	float roughness			= texture2D(roughness_map, v_vTexcoord * vec2(1.0, -1.0)).r * mix(avg, 1.0, no_map);
	
	// Normal texture
	vec3 normal_tex			= normalize(texture2D(normal_map, v_vTexcoord * vec2(1.0, -1.0)).rgb * 2.0 - 1.0);
	
	vec3 normal_trs			= normalize(v_vNMatrix * normal_tex);
	
	vec3 to_player			= normalize(camera_position - v_vVertexPosition);
	vec3 ref_vec			= normalize(reflect(to_player, normal_trs));
	
	float fresnel			= 1.0 - max(dot(to_player, normal_trs), 0.0);
	
	// Reflection map
	vec2 coords = vec2(0.5 - ((ref_vec.x / 2.0 + 0.5) + (tan(ref_vec.y) / 2.0 + 0.5)) * 0.5, 0.5 - ref_vec.z * 0.5);
	vec3 reflection_col		= texture2D(reflection_map, coords).xyz;
	
	vec3 lighting			= vec3(0.0);
	
	vec3 reflected_light	= vec3(0.0);
	
	for(int i = 0; i < max_candles; i += 1) {
		vec4 candle = candles[i];
		vec4 candles_color = candles_colors[i];
		
		float dis	= clamp(distance(v_vVertexPosition, candle.xyz) / mix(candle.w, candle.w * 0.5, volumetric), 0.0, 1.0);
		float dis_alt = clamp(distance(v_vVertexPosition, candle.xyz) / (candle.w * 0.15), 0.0, 1.0);
		float dis_far = clamp(distance(v_vVertexPosition, candle.xyz) / (candle.w * 3.0), 0.0, 1.0);
		
		vec3 to_l	= normalize(candle.xyz - v_vVertexPosition);
		float NdotL	= mix(mix(0.2 + (dot(to_l, normal_trs) / 2.0 + 0.5) * 0.8, mix(0.75, 1.0, max(dot(to_l, normal_trs), 0.0)), volumetric), 1.0, ignore_ndotl);
		
		lighting	+= mix(candles_color.rgb * 1.5, vec3(0.0), dis) * NdotL;
		lighting	+= mix(candles_color.rgb * 1.5, vec3(0.0), dis_alt);
		
		// Belichting die stuitert
		vec3 ref	= normalize(-to_l - to_player);
		float NdotP	= max(dot(normal_trs, -ref), 0.0);
		reflected_light += candles_color.rgb * pow(NdotP, mix(200.0, 1.0, roughness)) * mix(1.0, 0.0, roughness) * max(1.0 - dis_far, 0.0) * 0.78;
	}
	
	vec3 darkness = lighting;
	vec3 dark_lighting = mix(sky_color, sky_color_accent, avg2);
	lighting	+= mix(dark_lighting, vec3(0.0), (darkness.r + darkness.g + darkness.b) / 3.0);
	
	// lighting	= clamp(lighting, vec3(0.0), vec3(1.0, 0.81, 0.66) * 1.5);

    gl_FragColor		= mix(vec4(1.0), v_vColour, 0.5) * texture2D( gm_BaseTexture, v_vTexcoord * vec2(1.0, -1.0) );
	if(no_map == 0.0)
		gl_FragColor.rgb	= mix(map, gl_FragColor.rgb, clamp(1.0 - pow(N.z, 10.0) + avg, 0.0, 1.0));
	
	gl_FragColor.rgb	*= lighting;
	gl_FragColor.rgb	+= mix(vec3(0.0), vec3(currently_selected), clamp(1.0 - (pow(max(N.z, 0.0), 3.0) * 0.85), 0.0, 1.0));
	
	gl_FragColor.rgb	+= reflected_light;
	
	gl_FragColor.rgb	= mix(gl_FragColor.rgb, reflection_col, (0.1 + pow(fresnel, 1.8) * 0.9) * reflection_strength);
	
	const float max_fog_distance = 90.0;
	float fog_distance	= clamp(distance(v_vVertexPosition, camera_position) / max_fog_distance, 0.0, 1.0);
	gl_FragColor.rgb	= mix(gl_FragColor.rgb, sky_color, pow(fog_distance, 1.7));
	
	if(gl_FragColor.a < 0.5)
		discard;
}
