﻿Shader "MatCap/MatCap_Albedo_Normal" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex("Albedo Tex", 2D) = "white" {}
		_BumpMap ("Normal Tex", 2D) = "bump" {}
		_BumpValue ("Normal Value", Range(0,10)) = 1
		_MatCapDiffuse ("MatCapDiffuse (RGB)", 2D) = "white" {}
	}
	
	Subshader {
		Tags { "RenderType"="Opaque" }
		
		Pass {
			Tags { "LightMode" = "Always" }
			
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				struct v2f { 
					float4 pos : SV_POSITION;
					float4	uv : TEXCOORD0;
					float3	TtoV0 : TEXCOORD1;
					float3	TtoV1 : TEXCOORD2;
				};

				uniform float4 _BumpMap_ST;
				uniform float4 _MainTex_ST;
				
				v2f vert (appdata_tan v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos (v.vertex);
					o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);
					
					
					TANGENT_SPACE_ROTATION;
					o.TtoV0 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[0].xyz));
					o.TtoV1 = normalize(mul(rotation, UNITY_MATRIX_IT_MV[1].xyz));
					return o;
				}
				
				uniform fixed4 _Color;
				uniform sampler2D _BumpMap;
				uniform sampler2D _MatCapDiffuse;
				uniform sampler2D _MainTex;
				uniform fixed _BumpValue;
				
				float4 frag (v2f i) : COLOR
				{
					fixed4 c = tex2D(_MainTex, i.uv.xy);
					float3 normal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
					normal.xy *= _BumpValue;
					normal.z = sqrt(1.0- saturate(dot(normal.xy ,normal.xy)));
					normal = normalize(normal);
					
					half2 vn;
					vn.x = dot(i.TtoV0, normal);
					vn.y = dot(i.TtoV1, normal);

					fixed4 matcapLookup = tex2D(_MatCapDiffuse, vn * 0.5 + 0.5);					
					fixed4 finalColor = matcapLookup * c;
					return finalColor;
				}

			ENDCG
		}
	}
}