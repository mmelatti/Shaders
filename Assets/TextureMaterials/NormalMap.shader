﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "unityCookie/tut/beginner/7 NormalMap" {
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(-2.0, 2.0)) = 1.0
		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
	}
	SubShader {
		Pass {
		Tags{"LightMode" = "ForwardBase"}
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		//user defined variables
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _BumpDepth;
		uniform float4 _Color;
		uniform float4 _SpecColor;
		uniform float4 _RimColor;
		uniform float _Shininess;
		uniform float _RimPower;

		//unity defined variables
		uniform float4 _LightColor0;

		//base input structs
		struct vertexInput {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 tangent : TANGENT;
		};
		struct vertexOutput {
			float4 pos : SV_POSITION;
			float4 tex : TEXCOORD0;
			float4 posWorld : TEXCOORD1;
			float3 normalWorld : TEXCOORD2;
			float3 tangentWorld : TEXTCOORD3;
			float3 binormalWorld : TEXCOORD4;
		};

		//vertex function
		vertexOutput vert(vertexInput v) {
			vertexOutput o;

			o.normalWorld = normalize( mul( float4(v.normal, 0.0), unity_WorldToObject ).xyz ); //_World2Object is float4
			o.tangentWorld = normalize ( mul( unity_ObjectToWorld, v.tangent ).xyz );
			o.binormalWorld = normalize ( cross(o.normalWorld, o.tangentWorld) * v.tangent.w );

			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			//o.normalDir = normalize( mul( float4( v.normal, 0.0), _World2Object ).xyz );
			//o.normalDir = normalize( mul( float4(v.normal, 0.0), unity_WorldToObject ).xyz ); //_World2Object is float4
			o.pos = UnityObjectToClipPos(v.vertex);
			o.tex = v.texcoord;

			return o;

		} //end vertex function

		//fragment function
		float4 frag(vertexOutput i) : COLOR
		{
			float3 normalDirection = i.normalWorld; //was normalDir
			float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz );
			float3 lightDirection;
			float atten;

			 if(_WorldSpaceLightPos0.w == 0.0) {
			 	atten = 1.0;
			 	lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			  } 
			  else {
			  	float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
			  	float distance = length(fragmentToLightSource);
			  	atten = 1.0/distance;
			  	lightDirection = normalize(fragmentToLightSource);
			  }
			  //Texture Maps
			  float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);//multiply it by the scaleing??? 
			  float4 texN = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);//multiply it by the scaleing??? 

			  //unpackNormal function
			  float3 localCoords = float3(2.0 * texN.ag - float2(1.0, 1.0), 0.0); //this fixes some things with directx 11
			  //localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords); //very similar to 1... its in the documentation like this... (localCoords.z = 1.0)
			  localCoords.z = _BumpDepth; //another way to do this, set it in the parameters

			  //normal transpose matrix
			  float3x3 local2WorldTranspose = float3x3 (
			  	i.tangentWorld,
			  	i.binormalWorld,
			  	i.normalWorld
			  );

			  //calculate the normal direction
			  normalDirection = normalize ( mul( localCoords, local2WorldTranspose ));

			  //Lighting
			  float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
			  float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot(reflect(-lightDirection, normalDirection), viewDirection)) , _Shininess);

			  //Rim Lighting
			  float rim = saturate( dot( viewDirection, normalDirection));
			  float3 rimLighting = saturate(dot(normalDirection, lightDirection) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower));

			  float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection + specularReflection + rimLighting; //make sure to apply the ambient lighting before texture otherwise the texture will be covered up

			   

			  return float4(tex.xyz * lightFinal * _Color.xyz, 1.0);

		}//end fragment function
		ENDCG

		} //end pass

	} //end sub


}