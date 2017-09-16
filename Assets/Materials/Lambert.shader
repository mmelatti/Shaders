// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "unityCookie/tut/beginner/2 - Lambert" {
	Properties {
		_Color ("_Color", Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader {
		Pass {
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//user defined variables
			uniform float4 _Color;

			//Unity defined variables
			uniform float4 _LightColor0;
			//3 definitions for Unity (they are predifined in unity 4 and up)
			//float4x4 _Object2World;
			//float4x4 _World2Object; (I think this was change to unity_WorldToObject in Unity 5)
			//float4x4 _WorldSpaceLightPos0;

			//base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			//vertex function
			vertexOutput vert(vertexInput v) {
				vertexOutput o;

				float3 normalDirection = normalize ( mul( float4(v.normal, 0.0 ), unity_WorldToObject ).xyz);//this is important but I can't really see why
									   //normalize will squeeze all numbers between 0 and 1
									   //saturate will just remove if not between not try and squeez
				//Calculate light on our normals
				float3 lightDirection;
				float atten = 1.0; //distance from light ot source

				lightDirection = normalize( _WorldSpaceLightPos0.xyz );

				float3 diffuseReflection = atten * _LightColor0.xyz * _Color.rgb * max( 0.0, dot(normalDirection, lightDirection) ); //new one allows multiple light sources.
				//also add in the color of the surface
				//atten * _LightColor0.xyz will allow the light color to show up on the object! (also the intensity of the light
				//float3 diffuseReflection = dot(normalDirection, lightDirection);

				o.col = float4(diffuseReflection, 1.0); //output color
				o.pos = UnityObjectToClipPos(v.vertex); //output pos
				return o;
			}

			//fragment function
			float4 frag(vertexOutput i) : COLOR {
				return i.col;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
}