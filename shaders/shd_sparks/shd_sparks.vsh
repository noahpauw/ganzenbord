attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec3 in_Tangents;              // (u,v)

varying vec2 v_vTexcoord;
varying mat3 v_vNMatrix;
varying vec3 v_vNormal;
varying vec3 v_vVertexPosition;
varying vec3 v_vTangent;
varying vec4 v_vColour;

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
}
