// UCTS_Outline.cginc
// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// https://github.com/ACIIL/UnityChanToonShaderVer2_Project
// Source:
// https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//
			uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform sampler2D _Outline_Sampler; uniform float4 _Outline_Sampler_ST;
			uniform sampler2D _OutlineTex; uniform float4 _OutlineTex_ST;

			uniform float4 _Color;
			uniform float4 _Outline_Color;

			uniform half _Outline_Width;
			uniform half _Farthest_Distance;
			uniform half _Nearest_Distance;
			uniform half _Is_BlendBaseColor;
			uniform half _Is_LightColor_Base;
			uniform half _Offset_Z;
			uniform half _Is_OutlineTex;
			uniform half _OutlineshadowCastMin_black;

#ifdef _IS_OUTLINE_CLIPPING_YES
			uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
			uniform half _Clipping_Level;
			uniform half _Tweak_transparency;
			uniform half _Inverse_Clipping;
			uniform half _IsBaseMapAlphaAsClippingMask;
#endif
			uniform half _outline_mode;
			static const float softGI = .5;



			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv0 : TEXCOORD0;
				float3 normalDir : TEXCOORD2;
				UNITY_SHADOW_COORDS(3)
				// LIGHTING_COORDS(3,4)
				UNITY_FOG_COORDS(5)
				half3 vertexLighting : COLOR0;
				half attenVert : COLOR1;
			};



			// ambient color
			fixed3 DecodeLightProbe_average( fixed3 N ){
				//return (1 - softGI) * ShadeSH9( float4(N, 1)) + (softGI) * ShadeSH9( float4(0,0,0,1));
				return ShadeSH9( float4(0,0,0,1));
			}

			// unity's modified version without the lambert tint darkening and with attenuation pass out.
			float3 softShade4PointLights_Atten (
				float4 lightPosX, float4 lightPosY, float4 lightPosZ,
				float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
				float4 lightAttenSq,
				float3 pos,
				float3 normal,
				out float attenVert,
				out float3 vertTo0)
			{
				// to light vectors
				float4 toLightX = lightPosX - pos.x;
				float4 toLightY = lightPosY - pos.y;
				float4 toLightZ = lightPosZ - pos.z;
				vertTo0 = float3(toLightX[0], toLightY[0], toLightZ[0]);
				// squared lengths
				float4 lengthSq = 0;
				lengthSq += toLightX * toLightX;
				lengthSq += toLightY * toLightY;
				lengthSq += toLightZ * toLightZ;
				// don't produce NaNs if some vertex position overlaps with the light
				lengthSq = max(lengthSq, 0.000001);

				// attenuation
				float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq) -0.034;
				attenVert = atten;
				// float4 diff = atten;
				float4 diff = 1;

				// final color
				float3 col = 0;
				col += lightColor0 * diff.x;
				col += lightColor1 * diff.y;
				col += lightColor2 * diff.z;
				col += lightColor3 * diff.w;
				return col;
			}












//// vert			
			VertexOutput vert (VertexInput v) {
				VertexOutput o				= (VertexOutput)0;
				o.uv0						= v.texcoord0;
				o.normalDir					= UnityObjectToWorldNormal( v.normal);
				o.posWorld					= mul( unity_ObjectToWorld, v.vertex);

				float4 objPos				= mul ( unity_ObjectToWorld, float4(0,0,0,1) );

				float2 Set_UV0				= o.uv0;
				float4 _Outline_Sampler_var	= tex2Dlod( _Outline_Sampler, float4( TRANSFORM_TEX( Set_UV0, _Outline_Sampler), 0.0, 0));
				float Set_Outline_Width		= 
					(
						_Outline_Width * 0.001 
						* 
							smoothstep( 
								_Farthest_Distance, _Nearest_Distance, distance( o.posWorld.rgb, _WorldSpaceCameraPos) 
							) 
						* _Outline_Sampler_var.rgb
					).r;
				float3 viewDirection		= ( _WorldSpaceCameraPos.xyz - o.pos.xyz);
				float4 viewDirectionVP		= mul( UNITY_MATRIX_VP, float4( viewDirection.xyz, 1));
#if defined(UNITY_REVERSED_Z)
				_Offset_Z = _Offset_Z * -0.01;
#else
				_Offset_Z = _Offset_Z * 0.01;
#endif

				// NML
				if (_outline_mode == 0){
					o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + v.normal * Set_Outline_Width, 1) );
				}
				// POS
				else if (_outline_mode == 1){
					Set_Outline_Width		= Set_Outline_Width * 2;
					o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + normalize(v.vertex) * Set_Outline_Width, 1) );
				}

// #ifdef _OUTLINE_NML
// 				o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + v.normal * Set_Outline_Width, 1) );

// #elif _OUTLINE_POS
// 				Set_Outline_Width		= Set_Outline_Width * 2;
// 				o.pos					= UnityObjectToClipPos( float4( v.vertex.xyz + normalize(v.vertex) * Set_Outline_Width, 1) );
// #endif

				UNITY_TRANSFER_FOG( o, o.pos);
				UNITY_TRANSFER_SHADOW(o, o.uv0);
				// TRANSFER_VERTEX_TO_FRAGMENT(o);
				o.pos.z					= o.pos.z + _Offset_Z * viewDirectionVP.z;
#ifdef VERTEXLIGHT_ON
				float3 vertTo0; 
				o.vertexLighting		= softShade4PointLights_Atten(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0
					, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3]
					, unity_4LightAtten0, o.posWorld, 0, o.attenVert, vertTo0);
#endif					
				return o;
			}





//// Redefine UNITY_LIGHT_ATTENUATION without shadow multiply from AutoLight.cginc
#ifdef POINT
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif

#ifdef SPOT
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord4 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
	fixed destName = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
#endif

#ifdef DIRECTIONAL
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) fixed destName = 1;
// #define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) fixed destName = UNITY_SHADOW_ATTENUATION(input, worldPos);
#endif

#ifdef POINT_COOKIE
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
	fixed destName = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL * texCUBE(_LightTexture0, lightCoord).w;
#endif

#ifdef DIRECTIONAL_COOKIE
#define UNITY_LIGHT_ATTENUATION_NOSHADOW(destName, input, worldPos) \
	unityShadowCoord2 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xy; \
	fixed destName = tex2D(_LightTexture0, lightCoord).w;
#endif






//// frag			
			float4 frag(VertexOutput i) : SV_Target{
				UNITY_LIGHT_ATTENUATION_NOSHADOW(lightAtten, i, i.posWorld.xyz);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, i.posWorld.xyz);
				float nLightAtten		= 1 - lightAtten;
				float nShadowAtten		= 1 - shadowAtten;
				float attenRampB		= ( (-(nLightAtten * nLightAtten) + 1));
				float shadowAttenB		= ( (-(nShadowAtten * nShadowAtten) + 1));
				float attenRamp			= attenRampB;



#ifdef UNITY_PASS_FORWARDBASE
				float3 lightColor		= _LightColor0.rgb;
				float shadowBlackness	= max(_OutlineshadowCastMin_black, shadowAttenB);
				float3 ambientLight		= DecodeLightProbe_average( i.normalDir);
				lightColor				= lightColor * shadowBlackness * attenRamp;
				lightColor				= (lightColor + ambientLight) + (i.vertexLighting * i.attenVert);

#elif UNITY_PASS_FORWARDADD
				float shadRings			= shadowAttenB;
				float shadowBlackness	= max(_OutlineshadowCastMin_black, shadowAttenB);
				float3 lightColor		= _LightColor0.rgb;
				float shadBlackScale	= lerp(1, shadowBlackness, attenRamp);
				lightColor				= lightColor * shadBlackScale * attenRamp;
#endif

				// fight how the raw light of direct + indirect overbrights
				// Ill change this counter many time more than now. Which is to many already!
				float3 Set_LightColor	= lightColor;
				Set_LightColor.x		= (Set_LightColor.x > 1) ? sqrt(Set_LightColor.x) : Set_LightColor.x;
				Set_LightColor.y		= (Set_LightColor.y > 1) ? sqrt(Set_LightColor.y) : Set_LightColor.y;
				Set_LightColor.z		= (Set_LightColor.z > 1) ? sqrt(Set_LightColor.z) : Set_LightColor.z;



				float2 Set_UV0					= i.uv0;
				float4 _MainTex_var				= tex2D(_MainTex, TRANSFORM_TEX( Set_UV0, _MainTex));
				float3 _BaseColorMap_var		= ( _Color.rgb * _MainTex_var.rgb );
				float3 Set_BaseColor			= lerp( _BaseColorMap_var * Set_LightColor, (_BaseColorMap_var * Set_LightColor.rgb), _Is_LightColor_Base );
				float3 _Is_BlendBaseColor_var	= lerp( (_Outline_Color.rgb * Set_LightColor.rgb), (_Outline_Color.rgb * Set_BaseColor), _Is_BlendBaseColor );
				float3 _OutlineTex_var			= tex2D( _OutlineTex, TRANSFORM_TEX( Set_UV0, _OutlineTex));



#ifndef NotAlpha
				float4 clippingMaskTex	= tex2D( _ClippingMask, TRANSFORM_TEX( Set_UV0, _ClippingMask));
				float useMainTexAlpha	= lerp( clippingMaskTex.r,  _MainTex_var.a, _IsBaseMapAlphaAsClippingMask );
				float alpha				= lerp( useMainTexAlpha, (1.0 - useMainTexAlpha), _Inverse_Clipping );

				float clipTest			= (( alpha - _Clipping_Level - 0.01));
				clip(clipTest);
				alpha				= saturate(alpha + _Tweak_transparency);
	#ifdef IsClip
				alpha	= 1;
	#endif



				float4 Set_Outline_Color	=
					lerp( 
						float4( _Is_BlendBaseColor_var, alpha)
						, float4( (_OutlineTex_var.rgb * _Is_BlendBaseColor_var), alpha)
						, _Is_OutlineTex 
					);
				UNITY_APPLY_FOG( i.fogCoord, Set_Outline_Color);
				return Set_Outline_Color;
#else
				float3 Set_Outline_Color		= lerp( _Is_BlendBaseColor_var, _OutlineTex_var.rgb * _Is_BlendBaseColor_var, _Is_OutlineTex );
				UNITY_APPLY_FOG( i.fogCoord, Set_Outline_Color);
				return fixed4(Set_Outline_Color, 1);
#endif
			}