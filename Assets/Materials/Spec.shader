// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "unityCookie/tut/beginner/spec - 1" {
	Properties {
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
	}
	SubShader {
		Tags {"LightMode" = "ForwardBase"}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//user defined variables
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _Shininess;

			//unity defined variables;
			uniform float4 _LightColor0;

			//structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float4 normalDir : TEXCOORD1; 
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize ( mul( float4(v.normal, 0.0), float4(unity_WorldToObject, 0.0) ).xyz );
				//float3 normalDirection = normalize ( mul( float4(v.normal, 0.0 ), unity_WorldToObject ).xyz);//this is important but I can't really see why


				o.pos = UnityObjectToClipPos(v.vertex); //output pos
				return o;
			}

			//fragment function
			float4 frag(vertexOutput i) : COLOR
			{

				//vectors
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz, - i.posWorld.xyz );
				float3 lightDirection;
				float atten = 1.0;

				//lighting
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseRefliection = atten * LightColor.xyz * max( 0., dot( normalDirection, lightDirection ) );
				float3 specularReflection = atten * _LightColor0.xyz * _SpecColor.rgb * max( 0.0, dot( normalDirection, lightDirection ) ) * pow( max ( 0.0, dot( reflect( -lightDirection, normalDirection ), viewDirection ) ), _Shininess );
				float3 lightFinal = diffuseReglection + specularReflection + UNITY_LIGHTMODEL_AMBIENT;

				return float4(lightFinal * _Color.rgb, 1.0);

				return i.col;
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"




}