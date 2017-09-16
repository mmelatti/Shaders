// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "unityCookie/tut/introduction/1 - Flat Color"{
	Properties{
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0) //the underscore is notation that we can edit it in unity
	}
	SubShader { //can have different ones for different platforms
		Pass {
			CGPROGRAM

			//progmas
			#pragma vertex vert
			#pragma fragment frag //looks for vert and frag below

			//user defined variables
			uniform float4 _Color;

			//base input structs
			struct vertexInput{
				float4 vertex : POSITION;
			};
			struct vertexOutput{
				//SV_ used for DirectX shader
				float4 pos : SV_POSITION; //model is straight sent to GPU
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);


				return o;
			}
			//o will go to i in the next one

			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				return _Color;
			}

			ENDCG
		}
	}

	//Fallback "Diffuse"
}