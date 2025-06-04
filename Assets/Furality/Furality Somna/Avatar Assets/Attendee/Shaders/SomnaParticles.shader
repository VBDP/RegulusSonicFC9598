// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SomnaParticles"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_FavoriteColor("Favorite Color", Color) = (0.5,0.5,0.5)
		[HideInInspector]_EmissionColor("EmissionColor", Color) = (1,1,1,1)
		[HideInInspector]_EmissionMap2("EmissionMap2", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HDR]_EmissionColor ("Emission Color", Color) = (0.5,0.5,0.5,0.5)
		_EmissionMap ("Particle Texture", 2D) = "white" {}
		//_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}


	Category
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "PreviewType"="Plane" }
			Blend Off
			ColorMask RGB
			Cull Off
			Lighting Off
			ZWrite On
			ZTest LEqual
			
			Pass {

				CGPROGRAM
				#define ASE_VERSION 19801

				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				

				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					//#ifdef SOFTPARTICLES_ON
					//float4 projPos : TEXCOORD2;
					//#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					
				};


				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _EmissionMap;
				uniform fixed4 _EmissionColor;
				uniform float4 _EmissionMap_ST;
				//uniform float _InvFade;
				uniform float3 _FavoriteColor;
				uniform float4 _Color;
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform sampler2D _EmissionMap2;
				uniform float4 _EmissionMap2_ST;


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					//#ifdef SOFTPARTICLES_ON
						//o.projPos = ComputeScreenPos (o.vertex);
						//COMPUTE_EYEDEPTH(o.projPos.z);
					//#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					//#ifdef SOFTPARTICLES_ON
						//float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						//float partZ = i.projPos.z;
						//float fade = saturate (_InvFade * (sceneZ-partZ));
						//i.color.a *= fade;
					//#endif

					float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float4 tex2DNode13 = tex2D( _MainTex, uv_MainTex );
					float2 uv_EmissionMap2 = i.texcoord.xy * _EmissionMap2_ST.xy + _EmissionMap2_ST.zw;
					float4 appendResult14 = (float4(( ( _Color.rgb * tex2DNode13.rgb ) + ( tex2D( _EmissionMap2, uv_EmissionMap2 ).rgb * _EmissionColor.rgb ) ) , tex2DNode13.a));
					
					float4 Emission = tex2D(_EmissionMap, i.texcoord.xy * _EmissionMap_ST.xy + _EmissionMap_ST.zw);

					fixed4 col = appendResult14;
					clip(col.a - 0.5);
					UNITY_APPLY_FOG(i.fogCoord, col);

					return col;
				}
				ENDCG
			}
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.SamplerNode;13;-855.3292,-411.7227;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;92859cce6ffbf924890208da558a8267;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;18;-791.0444,-626.2842;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.5,0.4522059,0.2573529,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;4;-1218.395,-92.68607;Inherit;False;Property;_EmissionColor;EmissionColor;3;1;[HideInInspector];Fetch;True;0;0;0;False;0;False;1,1,1,1;0.7129127,0.6097414,0.346368,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode;3;-1255.539,-318.7053;Inherit;True;Property;_EmissionMap2;EmissionMap2;4;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;3061b375ae6144345ab38e8b717236c0;3061b375ae6144345ab38e8b717236c0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-506.244,-469.4843;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-791.6874,-154.6369;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-287.2305,-222.7215;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-469.7292,135.4778;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;381.3,89.49999;Inherit;False;Property;_FavoriteColor;Favorite Color;2;0;Create;False;0;0;0;True;0;False;0.5,0.5,0.5,0;0.5,0.5,0.5,1;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.DynamicAppendNode;14;32.67076,-309.3223;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;267.1,-299.2001;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;11;SomnaParticles;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;True;0;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;False;True;True;1;False;;True;3;False;;False;True;4;Queue=AlphaTest=Queue=0;IgnoreProjector=True;RenderType=TransparentCutout=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;17;0;18;5
WireConnection;17;1;13;5
WireConnection;10;0;3;5
WireConnection;10;1;4;5
WireConnection;16;0;17;0
WireConnection;16;1;10;0
WireConnection;14;0;16;0
WireConnection;14;3;13;4
WireConnection;0;0;14;0
ASEEND*/
//CHKSM=517157981586ACCFC7BD0CF4C43C59FC93714B70