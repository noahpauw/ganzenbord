attribute vec3 in_Position;                 // (x,y,z)
attribute vec3 in_Normal;					// (x,y,z)
attribute vec4 in_Colour;                   // (r,g,b,a)
attribute vec2 in_TextureCoord;             // (u,v)
attribute vec3 in_Tangents;					// (x,y,z)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_vNMatrix;
varying vec3 v_vNormal;
varying vec3 v_vVertexPosition;
varying vec3 v_vTangent;

uniform float time;
uniform float wind_affection;
uniform vec2 tree_speed;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	v_vVertexPosition = (gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz;
	v_vNormal	= (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	v_vTangent	= (gm_Matrices[MATRIX_WORLD] * vec4(in_Tangents, 0.0)).xyz;
	
	// Normal matrices
	vec3 N		= normalize(v_vNormal);
	vec3 T		= normalize(v_vTangent);
	vec3 B		= cross(N, T);
	
	v_vNMatrix	= mat3(T, B, N);
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
	
	// Wind movement
	float z_index = clamp(in_Position.z / 15.0, 0.0, 1.0);
	z_index = pow(z_index, 2.5);
	
	float z_offest = cos(in_Position.z * 10.0);
	
	gl_Position.x += cos(time * tree_speed.x + v_vVertexPosition.x) * wind_affection * (tree_speed.x / 100.0) * z_index * z_offest;
	gl_Position.y += sin(time * tree_speed.y + v_vVertexPosition.y) * wind_affection * (tree_speed.y / 100.0) * z_index * z_offest;
}
