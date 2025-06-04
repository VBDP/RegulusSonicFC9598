Shader "Mochie/Fog" {
    Properties {
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_Radius("Radius", Float) = 2
		_Fade("Fade", Float) = 1
		_MinRange("Min Range", Float) = 7
		_MaxRange("Max Range", Float) = 10
		_PlayerToObject("Player to Object", Range(0,1)) = 0
    }
    SubShader {
        Tags {
			"RenderType"="Overlay" 
			"Queue"="Overlay"
		}
		ZWrite Off
		ZTest Always
		Cull Front
		Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			float4 _CameraDepthTexture_TexelSize;
			float4 _Color;
			float _Fade, _Radius;
			float _MinRange, _MaxRange;
			float _PlayerToObject;

            struct appdata{
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f{
				float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
				float3 raycast : TEXCOORD1;
				float3 cameraPos : TEXCOORD2;
				float3 objPos : TEXCOORD3;
				float falloff : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID 
                UNITY_VERTEX_OUTPUT_STEREO
				UNITY_FOG_COORDS(10)
            };

            v2f vert (appdata v){
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.cameraPos = _WorldSpaceCameraPos;
                #if UNITY_SINGLE_PASS_STEREO
					o.cameraPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
				#endif

				// Falloff
				o.objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
				o.falloff = smoothstep(_MaxRange, clamp(_MinRange, 0, _MaxRange-0.001),  distance(o.cameraPos, o.objPos));

				// Vertex and uv data
				v.vertex.x *= 1.4;
				float4 wPos = mul(unity_CameraToWorld, v.vertex);
				float4 oPos = mul(unity_WorldToObject, wPos);
				o.raycast = UnityObjectToViewPos(oPos).xyz * float3(-1,-1,1);
				o.pos = UnityObjectToClipPos(oPos);
				o.uv = ComputeGrabScreenPos(o.pos);
                return o;
            }

			float2 GetScreenUV(v2f i){
				float2 screenUV = i.uv.xy / i.uv.w; 
				#if UNITY_UV_STARTS_AT_TOP
					if (_CameraDepthTexture_TexelSize.y < 0) {
						screenUV.y = 1 - screenUV.y;
					}
				#endif
				screenUV.y = _ProjectionParams.x * .5 + .5 - screenUV.y * _ProjectionParams.x;
				return screenUV;
			}

			float GetRadius(v2f i){
				float2 depthUV = GetScreenUV(i);
				float depth = Linear01Depth(DecodeFloatRG(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, depthUV)));
				i.raycast *= (_ProjectionParams.z / i.raycast.z);
				float4 vPos = float4(i.raycast * depth, 1);
				float3 wPos = mul(unity_CameraToWorld, vPos).xyz;
				float dist = distance(wPos, lerp(i.cameraPos, i.objPos, _PlayerToObject));
				return smoothstep(_Radius, _Radius-_Fade, dist);
			}

			float4 GetFog(v2f i){
				float radius = GetRadius(i);
				float alpha = _Color.a * i.falloff * (1-radius);
				float4 col = float4(_Color.rgb, alpha);
				return col;
			}

			void EarlyDiscard(v2f i){
				if (i.falloff == 0)
					discard;
			}

            float4 frag (v2f i) : SV_Target {
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				EarlyDiscard(i);
                float4 col = GetFog(i);
                return col;
            }
            ENDCG
        }
    }
}