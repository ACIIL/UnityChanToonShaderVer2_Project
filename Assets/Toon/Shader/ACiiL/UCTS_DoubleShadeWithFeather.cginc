// Forked from Unity-Chan Toon Shader Ver.2.0.4
// Modifications by ACiiL.
// https://github.com/ACIIL/UnityChanToonShaderVer2_Project
// Source:
// https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//
// Coding goal is both as a personal study to self improve shader writing and make UTS2 redundant and compatible 
// in all typical vrchat map scene light situations.
//
			// sample sets: normals, albedo(shades/masks), AOs, matcap, emissionColor
			UNITY_DECLARE_TEX2D_NOSAMPLER(_ClippingMask); uniform float4 _ClippingMask_ST;

			UNITY_DECLARE_TEX2D(_NormalMap); uniform float4 _NormalMap_ST;

			UNITY_DECLARE_TEX2D(_MainTex); uniform float4 _MainTex_ST;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_1st_ShadeMap); uniform float4 _1st_ShadeMap_ST;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_2nd_ShadeMap); uniform float4 _2nd_ShadeMap_ST;

			UNITY_DECLARE_TEX2D(_Set_1st_ShadePosition); uniform float4 _Set_1st_ShadePosition_ST;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Set_2nd_ShadePosition); uniform float4 _Set_2nd_ShadePosition_ST;

			UNITY_DECLARE_TEX2D_NOSAMPLER(_HighColor_Tex); uniform float4 _HighColor_Tex_ST;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Set_HighColorMask); uniform float4 _Set_HighColorMask_ST;
			
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Set_RimLightMask); uniform float4 _Set_RimLightMask_ST;
			
			UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMapForMatCap); uniform float4 _NormalMapForMatCap_ST;
			UNITY_DECLARE_TEX2D(_MatCap_Sampler); uniform float4 _MatCap_Sampler_ST;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Set_MatcapMask); uniform float4 _Set_MatcapMask_ST;
			
			UNITY_DECLARE_TEX2D_NOSAMPLER(_Emissive_Tex); uniform float4 _Emissive_Tex_ST;
			UNITY_DECLARE_TEX2D(_EmissionColorTex); uniform float4 _EmissionColorTex_ST;

			sampler3D _DitherMaskLOD;



			//
			// float arraySize	= 0;
			// float3 arrayTest[3];
			// uniform half _arrayAccess;

			uniform half _Clipping_Level;
			uniform half _Tweak_transparency;
			uniform half _Inverse_Clipping;
			uniform half _IsBaseMapAlphaAsClippingMask;
			
			uniform float4 _Color;
			uniform float4 _1st_ShadeColor;
			uniform float4 _2nd_ShadeColor;

			uniform float4 _HighColor;

			uniform float4 _RimLightColor;
			uniform float4 _Ap_RimLightColor;

			uniform float4 _MatCapColor;

			uniform float4 _Emissive_Color;



			uniform half _Is_NormalMapToBase;
			uniform half _Is_NormalMapToHighColor;
			uniform half _Is_NormalMapToRimLight;
			uniform half _Is_NormaMapToEnv;

			uniform half _Use_BaseAs1st;
			uniform half _Use_1stAs2nd;
			uniform half _BaseColor_Step;
			uniform half _ShadeColor_Step;
			uniform half _BaseShade_Feather;
			uniform half _1st2nd_Shades_Feather;
			
			uniform half _shadowCastMin_black;
			uniform half _Set_SystemShadowsToBase;
			uniform half _Is_UseTweakHighColorOnShadow;
			uniform half _Tweak_SystemShadowsLevel;
			uniform half _shaSatRatio;

			uniform half _highColTexSource;
			uniform half _Tweak_HighColorMaskLevel;
			uniform half _HighColor_Power;
			uniform half _Is_BlendAddToHiColor;
			uniform half _Is_SpecularToHighColor;
			uniform half _TweakHighColorOnShadow;

			uniform half _Tweak_RimLightMaskLevel;
			uniform half _RimLight;
			uniform half _Add_Antipodean_RimLight;
			uniform half _RimLightSource;
			uniform half _RimLightMixMode;
			uniform half _LightDirection_MaskOn;
			uniform half _RimLight_FeatherOff;
			uniform half _Ap_RimLight_FeatherOff;
			uniform half _RimLightAreaOffset;
			uniform half _RimLight_Power;
			uniform half _Ap_RimLight_Power;
			uniform half _RimLight_InsideMask;
			uniform half _Tweak_LightDirection_MaskLevel;

			uniform half _envRoughness;
			uniform half _envOnRim;

			uniform half _Is_NormalMapForMatCap;
			uniform half _MatCap;
			uniform half _Is_BlendAddToMatCap;
			uniform half _Tweak_MatCapUV;
			uniform half _Rotate_MatCapUV;
			uniform half _Rotate_NormalMapForMatCapUV;
			uniform half _Is_UseTweakMatCapOnShadow;
			uniform half _TweakMatCapOnShadow;
			uniform half _Tweak_MatcapMaskLevel;

			uniform half _Is_LightColor_Base;
			uniform half _Is_LightColor_1st_Shade;
			uniform half _Is_LightColor_2nd_Shade;
			uniform half _Is_LightColor_HighColor;
			uniform half _Is_LightColor_RimLight;
			uniform half _Is_LightColor_Ap_RimLight;
			uniform half _Is_LightColor_MatCap;

			uniform half _testMix;
			static const float3 defaultLightDirection = float3(0, -1, 0);
			static const half softGI = .98;






			struct VertexInput {
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
				float4 tangent	: TANGENT;
				float2 uv		: TEXCOORD0;
			};

			struct VertexOutput {
				float4 pos		: SV_POSITION;
				float4 center	: TEXCOORD0;
				float4 worldPos	: TEXCOORD1;
				float3 wNormal	: TEXCOORD2;
				float4 tangent	: TEXCOORD3;
				float3 biNormal	: TEXCOORD4;
				half3 vertexLighting	: TEXCOORD5;
				half attenVert			: TEXCOORD6;
				float3 GIdirection	: TEXCOORD7;
				float2 uv			: TEXCOORD8;
				float4 screenPos	: TEXCOORD9;
				float3 vertTo0		: TEXCOORD10;
				UNITY_SHADOW_COORDS(11)
				UNITY_FOG_COORDS(12)
			};



			// raw ambient color by direction
			fixed3 DecodeLightProbe( fixed3 N ){
				return ShadeSH9( float4(N,1));
			}
			
			// ambient color
			fixed3 DecodeLightProbe_average(){
				//return (1 - softGI) * ShadeSH9( float4(N, 1)) + (softGI) * ShadeSH9( float4(0,0,0,1));
				return ShadeSH9( float4(0,0,0,1));
			}

			// vrchat shader community. Not sure exactly whom poked the mirror code to solve this.
			bool IsInMirror()
			{
				return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
			}

			// Neitri's Help
			float3 GIsonarDirection(){
				// float3 GIsonar_dir_vec = (unity_SHAr.xyz * unity_SHAr.w + unity_SHAg.xyz * unity_SHAg.w + unity_SHAb.xyz * unity_SHAb.w);
				float3 GIsonar_dir_vec = (unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
				UNITY_FLATTEN
				if ( length( GIsonar_dir_vec) > 0){
					GIsonar_dir_vec = normalize(GIsonar_dir_vec);
				} else {
					GIsonar_dir_vec = float3(0,0,0);
				}
				return GIsonar_dir_vec;
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

			// Simplified box projection
			// https://catlikecoding.com/unity/tutorials/rendering/part-8/
			float3 BoxProjection (
				float3 direction, float3 position,
				float4 cubemapPosition, float3 boxMin, float3 boxMax) 
			{
				UNITY_BRANCH
				if (cubemapPosition.w > 0) {
					float3 factors =
						((direction > 0 ? boxMax : boxMin) - position) / direction;
					float scalar = min(min(factors.x, factors.y), factors.z);
					direction = direction * scalar + (position - cubemapPosition);
				}
				return direction;
			}

			//
			half SpecularStrength_ac(half3 specular) {
					return max(max(specular.r, specular.g), specular.b);
			}

			// Diffuse/Spec Energy conservation
			inline half3 EnergyConservationBetweenDiffuseAndSpecular_ac (
				half conserveMode, half3 albedo, half3 specColor, out half oneMinusReflectivity
			) {
				oneMinusReflectivity = max(0, 1 - SpecularStrength_ac(specColor));
				half3 albedoAdd		= albedo;
				half3 albedoConMono	= albedo * oneMinusReflectivity;
				//half3 albedoConRGB	= albedo * (half3(1, 1, 1) - specColor); // not HDR safe.
				return	lerp(albedoConMono, albedoAdd, conserveMode);
			}

			// https://www.shadertoy.com/view/4djSRW
			float hash13(float3 p3)
			{
				// p3 = frac(p3 * .1031);
				p3 = frac(p3 * 13);
				p3 += dot(p3, p3.yzx + 19.19);
				return frac((p3.x + p3.y) * p3.z);
			}

			float rand3(float3 co){
				return frac(sin(dot(co.xyz ,float3(12.9898,78.233,213.576))) * 43758.5453);
			}

			/*
			// discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3
			float3 random3(float3 c) {
				float j = 4096.0*sin(dot(c,float3(17.0, 59.4, 15.0)));
				float3 r;
				r.z = frac(512.0*j);
				j *= .125;
				r.x = frac(512.0*j);
				j *= .125;
				r.y = frac(512.0*j);
				return r-0.5;
			}
			*/

			//
			float3 StereoWorldViewPos( float3 worldPos) {
#if UNITY_SINGLE_PASS_STEREO
				float3 cameraPos	= 
					float3((unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5); 
#else
				float3 cameraPos	= _WorldSpaceCameraPos;
#endif
				return cameraPos;
			}

			//
			float3 StereoWorldViewDir( float3 worldPos) {
				float3 cameraPos	= StereoWorldViewPos(worldPos);
				float3 worldViewDir	= (cameraPos - worldPos);
				return worldViewDir;
			}

			//
			float3 HSVToRGB( float3 c )
			{
				float4 K	= float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p	= abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}

			//
			float3 RGBToHSV(float3 c)
			{
				float4 K	= float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p	= lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q	= lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d		= q.x - min( q.w, q.y );
				float e		= 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}












//// vert			
			VertexOutput vert (VertexInput v) 
			{
				VertexOutput o = (VertexOutput)0;
				o.pos			= UnityObjectToClipPos( v.vertex );
				o.worldPos		= mul( unity_ObjectToWorld, v.vertex);
				o.center		= mul( unity_ObjectToWorld, float4(0,0,0,1));
				o.wNormal		= UnityObjectToWorldNormal( v.normal);
				o.tangent		= ( float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w));
				o.biNormal 		= ( cross( o.wNormal, o.tangent ) * o.tangent.w);
				o.uv			= v.uv;
				o.screenPos		= ComputeScreenPos(o.pos);
				UNITY_TRANSFER_FOG(o, o.pos);
				UNITY_TRANSFER_SHADOW(o, o.uv);
				// TRANSFER_SHADOW_CASTER_NOPOS(o,opos)
				// TRANSFER_VERTEX_TO_FRAGMENT(o);

#ifdef VERTEXLIGHT_ON
				o.vertexLighting		= softShade4PointLights_Atten(
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0
					, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3]
					, unity_4LightAtten0, o.worldPos, o.wNormal, o.attenVert, o.vertTo0);
#endif					
#ifdef UNITY_PASS_FORWARDBASE
				o.GIdirection			= GIsonarDirection();
#endif
				return o;
			}












//// frag
			float4 frag(
				VertexOutput i
				, bool frontFace : SV_IsFrontFace ) : SV_TARGET 
			{
				// bool isInMirror				= IsInMirror();
				// float faceDetect			= !frontFace ^ isInMirror;   // unity v2017.4.15f1 VFACE is backwords in mirrors. Fixed later version.
				i.wNormal					= normalize( i.wNormal);
				// if(faceDetect) { // flip normal for back faces.
				// 	i.wNormal = -i.wNormal;
				// }
				i.biNormal					= ( i.biNormal);
				float3 worldviewPos			= StereoWorldViewPos(i.worldPos.xyz);
				float3 viewDirection		= normalize(worldviewPos - i.worldPos.xyz);

				// normal map
				float4 normalTex			= UNITY_SAMPLE_TEX2D(_NormalMap, TRANSFORM_TEX( i.uv, _NormalMap));
				float3 normalMap			= UnpackNormal( normalTex);
				float3 normalLocal			= normalMap.rgb;
				float3x3 tangentTransform	= float3x3( i.tangent.xyz , i.biNormal.xyz, i.wNormal);
				float3 normalDirection		= normalize( mul( normalLocal, tangentTransform ));
                //// screen pos
                float4 screenPos            = i.screenPos;
                float4 screenUV             = screenPos / (screenPos.w + 0.00001);
            #ifdef UNITY_SINGLE_PASS_STEREO
                screenUV.xy     *= float2(_ScreenParams.x * 2, _ScreenParams.y);
            #else
                screenUV.xy     *= _ScreenParams.xy;
            #endif



//// albedo texure
                float4 mainTex			= UNITY_SAMPLE_TEX2D( _MainTex, TRANSFORM_TEX( i.uv, _MainTex));
//// clip & alpha handling. Here now so clip() may interrupt flow.
#ifndef NotAlpha
                float4 clipMask			= UNITY_SAMPLE_TEX2D_SAMPLER( _ClippingMask, _MainTex, TRANSFORM_TEX(i.uv, _ClippingMask));
                float useMainTexAlpha   = (_IsBaseMapAlphaAsClippingMask) ? mainTex.a : clipMask.r;
                float alpha             = (_Inverse_Clipping) ? (1.0 - useMainTexAlpha) : useMainTexAlpha;

                float clipTest          = (( -_Clipping_Level + alpha - 0.001));
                clip(clipTest);

    #ifndef IsClip
                // dither pattern with some a2c blending.
                // citation to Silent and Xiexe for guidance and research documentation.
                clipTest        = saturate(( alpha + _Tweak_transparency));
                alpha           = clipTest;
        #ifdef UseAlphaDither
                //// dither hard ~16 states & matching shadow caster dither. Con. creates alpha banding
                float dither    = tex3D(_DitherMaskLOD, float3(screenUV.xy * .25, alpha * .99), 0,0).a;
                alpha           = dither;
                clip(alpha -1);
        #endif //// UseAlphaDither
                alpha           = saturate(alpha);

                ////////////////
                //////////////// Alternative dither methods
                // {
                //     // // dither noise based on pos. a2c best but always noisy.
                //     alpha            = saturate(( alpha + _Tweak_transparency));
                //     float dither     = hash13(i.worldPos * 50);
                //     // float dither  = rand3(i.worldPos * 50);
                //     float alpha2     = saturate(alpha * alpha);
                //     float amix       = lerp(dither*(1-alpha), dither*alpha, 1-alpha2);
                //     alpha            = (amix) + alpha;
                //     alpha            = saturate(alpha);
                // }
                ////////////////
                ////////////////
                // {
                    // // hard dither pattern. Bad A2C support.
                //     clipTest         = saturate(( alpha + _Tweak_transparency));
                //     float dither     = tex3D(_DitherMaskLOD,
                //                                 float3(screenUV.x * _ScreenParams.x*.25, screenUV.y * _ScreenParams.y*.25, clipTest * .99), 0,0).a;
                //     // float dither  = tex3D(_DitherMaskLOD, float3(screenUV.xy * .25, clipTest * 0.9375)).a;

                //     float alpha2     = saturate(alpha * alpha);
                //     // float amix    = lerp(dither*(1-alpha), dither*alpha, 1-alpha2);
                //     // alpha         =  amix + alpha;
                //     // alpha         =  0.5 * (dither + alpha);
                //     alpha = dither;
                //     alpha            = saturate(alpha);
                ////////////////
                ////////////////
    #else //// IsClip
                alpha           = 1;
    #endif //// IsClip
#else
                float alpha     = 1;
#endif //// NotAlpha


				float4 shadeMapTex_1	= UNITY_SAMPLE_TEX2D_SAMPLER( _1st_ShadeMap, _MainTex, TRANSFORM_TEX( i.uv, _1st_ShadeMap));
				float4 shadeMapTex_2	= UNITY_SAMPLE_TEX2D_SAMPLER( _2nd_ShadeMap, _MainTex, TRANSFORM_TEX( i.uv, _2nd_ShadeMap));
				if (_Use_BaseAs1st)	{ shadeMapTex_1	= mainTex;}
				if (_Use_1stAs2nd)	{ shadeMapTex_2	= shadeMapTex_1;}






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






//// Light attenuation
				UNITY_LIGHT_ATTENUATION_NOSHADOW(lightAtten, i, i.worldPos.xyz);
				float shadowAtten		= UNITY_SHADOW_ATTENUATION(i, i.worldPos.xyz);
				shadowAtten				= max(shadowAtten, i.attenVert);
				float nLightAtten		= 1 - lightAtten;
				float nShadowAtten		= 1 - shadowAtten;
				// float attenRampB		= ( (-(nLightAtten * nLightAtten) + 1));
				float shadowAttenB		= ( (-(nShadowAtten * nShadowAtten) + 1));
				float attenRamp			= lightAtten;
				// float shadowAttenB		= shadowAtten;






//// Light input colors
				//const half shadowRings			= .15;
#ifdef UNITY_PASS_FORWARDBASE
				//float shadRings		= (ceil( shadowAttenB / shadowRings) * (shadowRings));
				float shadRings			= shadowAttenB;
				float3 lightIndirect	= DecodeLightProbe_average();
				float3 lightDirect		= _LightColor0.rgb;
				float shadowBlackness	= saturate( (shadRings+_shadowCastMin_black)/(1-_shadowCastMin_black) );
				// float shadowBlackness	= saturate(_shadowCastMin_black + shadRings);
				// float shadowBlackness	= max(_shadowCastMin_black, shadRings);
				float shaBlackMix		= shadowBlackness * attenRamp;
				lightDirect				= lightDirect * shaBlackMix;

				// fuzzy logic for classifying direct light < indirect light
				float lightDirGray		=  dot(_LightColor0.rgb,	1);
				float lightInDirGray	=  dot(lightIndirect.rgb,	1);
				float colorIntSignal	= (smoothstep(0, lightDirGray, lightInDirGray));
				float3 vertexLit		= i.vertexLighting * i.attenVert;
				float3 lightColorFinal	= lightDirect + lightIndirect + vertexLit;

#elif UNITY_PASS_FORWARDADD
				//float shadRings		= ceil( shadowAttenB / shadowRings) * shadowRings;
				float shadRings			= shadowAttenB;
				float3 lightIndirect	= 1;
				float3 lightDirect		= _LightColor0.rgb;
				float shadowBlackness	= saturate( (shadRings+_shadowCastMin_black)/(1-_shadowCastMin_black) );
				// float shadowBlackness	= max(_shadowCastMin_black, shadRings);
				float shadBlackScale	= lerp(1, shadowBlackness, attenRamp);
				shadowBlackness			= shadBlackScale;
				float shaBlackMix		= shadowBlackness * attenRamp;
				lightDirect				= lightDirect * shaBlackMix;
				float3 lightColorFinal	= lightDirect;
				float colorIntSignal	= 0;
#endif

				float3 set_LightColor	= lightColorFinal;
				// fight how the raw light of direct + indirect overbrights
				// Ill change this counter many times more than now. Which is to many already!
				set_LightColor.x	= (set_LightColor.x > 1) ? sqrt(set_LightColor.x) : set_LightColor.x;
				set_LightColor.y	= (set_LightColor.y > 1) ? sqrt(set_LightColor.y) : set_LightColor.y;
				set_LightColor.z	= (set_LightColor.z > 1) ? sqrt(set_LightColor.z) : set_LightColor.z;






//// Light Direction vectors
#ifdef UNITY_PASS_FORWARDBASE
				float3 viewLightDirection	= normalize( UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
				float3 lightDir				= normalize( _WorldSpaceLightPos0.xyz * dot(1, lightDirect) + (i.GIdirection) * dot(1, lightIndirect) + dot(1, vertexLit) * (i.vertTo0) + viewLightDirection *.0001);
				// float3 lightDir				= normalize( _WorldSpaceLightPos0.xyz + (i.GIdirection) * .01 + viewLightDirection *.0001);
#elif UNITY_PASS_FORWARDADD
				float3 lightDir				= 
					normalize( 
						lerp( 
							_WorldSpaceLightPos0.xyz
							, _WorldSpaceLightPos0.xyz - i.worldPos.xyz
							, _WorldSpaceLightPos0.w)
					);
#endif
				// if (faceDetect)
				// {
				// 	lightDir	= -lightDir;
				// }



//// dot()
				float3 useShadeNormal		= lerp(i.wNormal, normalDirection, _Is_NormalMapToBase);
				float3 useEnvNormal			= lerp(i.wNormal, normalDirection, _Is_NormaMapToEnv);
				float3 useHCNormal			= lerp(i.wNormal, normalDirection, _Is_NormalMapToHighColor );
				float3 useRimLightNormal	= lerp(i.wNormal, normalDirection, _Is_NormalMapToRimLight);

				// ret refract(i, n, ?)
				float3 lightReflect		= reflect(-viewDirection, useEnvNormal);
				float3 halfDirection	= normalize(viewDirection + lightDir);
				float ndotl_pure		= 0.5 * dot(i.wNormal, lightDir) + 0.5;
				float bdotv_pure		= 0.5 * dot(i.biNormal, viewDirection) + 0.5;
				float ndotl_shade		= 0.5 * dot(useShadeNormal, lightDir) + 0.5;
				float hdotn_highColor	= 0.5 * dot(halfDirection, useHCNormal) + 0.5;
				float ndov_rim			= dot(useRimLightNormal, viewDirection); // 1=norm with cam, -1=not

				// ndotl_shade	= DisneyDiffuse(dot(i.wNormal, viewDirection), dot( i.wNormal, lightDir), dot(lightDir, halfDirection), _SinTime.w) * 0.5  + 0.5;
				// float3 tempR =ndotl_shade;





//// Reflection
				Unity_GlossyEnvironmentData envData;
				envData.roughness		= _envRoughness;
				envData.reflUVW			= BoxProjection(lightReflect, i.worldPos
											, unity_SpecCube0_ProbePosition
											, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
				float3 envMask			= Unity_GlossyEnvironment(
						UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
				); // unity_SpecCube0_HDR.a
				float envGray		= LinearRgbToLuminance(envMask);
				envMask				= lerp(1, envGray, smoothstep(0, .2, envGray));






//// Toon Lambert
				// Lambert & shadow attenuation mix
				float4 shadowTex_1	= UNITY_SAMPLE_TEX2D( _Set_1st_ShadePosition, TRANSFORM_TEX( i.uv, _Set_1st_ShadePosition));
				float4 shadowTex_2	= UNITY_SAMPLE_TEX2D_SAMPLER( _Set_2nd_ShadePosition, _Set_1st_ShadePosition, TRANSFORM_TEX( i.uv, _Set_2nd_ShadePosition));

				float shadeRamp_n1	= 
					saturate(
						1.0 
						+ 
							(
								(
									lerp(
										ndotl_shade
										//, ( ndotl_shade * saturate( ((shadowAtten * 0.5) + 0.5 + _Tweak_SystemShadowsLevel)))
										// , ( ndotl_shade * saturate(smoothstep(0, 1, shadowAtten + _Tweak_SystemShadowsLevel) ) )
										, ( ndotl_shade * smoothstep(_LightShadowData.x + 0.001, 1 + _Tweak_SystemShadowsLevel, shadowAtten))
										, _Set_SystemShadowsToBase 
									)
									- ( _BaseColor_Step - _BaseShade_Feather )
								)
								* ( (1.0 - shadowTex_1.rgb).r - 1.0 ) 
							) 
						/ (_BaseShade_Feather)						
					);

				// shadow1 to shadow2 mix
				float shadeRamp_n2			=
						saturate(
							1.0 
							+ ( ndotl_shade - (_ShadeColor_Step - _1st2nd_Shades_Feather) )
							* ( (1.0 - shadowTex_2.rgb).r - 1.0 ) 
							/ ( _1st2nd_Shades_Feather )
						);
				






//// Albedo textures
				// is using world color
				float3 baseColor_isLC	= lerp(attenRamp, set_LightColor, _Is_LightColor_Base);
				float3 shadeColor1_isLC	= lerp(attenRamp, set_LightColor, _Is_LightColor_1st_Shade);
				float3 shadeColor2_isLC	= lerp(attenRamp, set_LightColor, _Is_LightColor_2nd_Shade);

				// get albedo samples
				float3 albetoCol_1		= mainTex.rgb;
				float3 albetoCol_2		= shadeMapTex_1.rgb;
				float3 albetoCol_3		= shadeMapTex_2.rgb;

				// get ramp shade color mix
				float3 rampWorldCol_1	= baseColor_isLC;
				float3 rampWorldCol_2	= shadeColor1_isLC;
				float3 rampWorldCol_3	= shadeColor2_isLC;

				float3 shadeCol_1		= _Color.rgb;
				float3 shadeCol_2		= _1st_ShadeColor.rgb;
				float3 shadeCol_3		= _2nd_ShadeColor.rgb;



//// The 3 Shade mixer. Lerp: (base color, (shade 1, shade 2))
				// albedo & shades mix
				float3 satIn_1			= albetoCol_1 * shadeCol_1;
				float3 satIn_2			= albetoCol_2 * shadeCol_2;
				float3 satIn_3			= albetoCol_3 * shadeCol_3;
				float3 satNoIn_1		= rampWorldCol_1;
				float3 satNoIn_2		= rampWorldCol_2;
				float3 satNoIn_3		= rampWorldCol_3;

				// saturate mix
				float3 satMix_23		= lerp(satIn_2, satIn_3, shadeRamp_n2);
				float3 satMix_1_23		= lerp(satIn_1, satMix_23, shadeRamp_n1);
				// no saturation mix
				float3 satNoMix_23		= lerp(satNoIn_2, satNoIn_3, shadeRamp_n2);
				float3 satNoMix_1_23	= lerp(satNoIn_1, satNoMix_23, shadeRamp_n1);
				// logic
				float colTest			= 1 - ((saturate( ( (shadowBlackness) + (colorIntSignal)))));
				float colSateOffset		= 1 + _shaSatRatio * colTest;

				float3 albedoRGBIn		= satMix_1_23;
				float3 albedoHSV		= RGBToHSV( albedoRGBIn);
				satMix_1_23				= HSVToRGB( float3(albedoHSV.x, ( albedoHSV.y * colSateOffset ), albedoHSV.z));

				float3 shadeColor		= satMix_1_23 * satNoMix_1_23;





//// High Color. Specular.
				float4 highColorTex			= UNITY_SAMPLE_TEX2D_SAMPLER( _HighColor_Tex, _MainTex, TRANSFORM_TEX( i.uv, _HighColor_Tex));
				float4 highColorMask		= UNITY_SAMPLE_TEX2D_SAMPLER( _Set_HighColorMask, _MainTex, TRANSFORM_TEX( i.uv, _Set_HighColorMask));
				if (_highColTexSource)	{ highColorTex	= mainTex;}

				
				float highColorMaskSetup	= 
					saturate( highColorMask.g + _Tweak_HighColorMaskLevel)
					* lerp(
						( 1.0 - step(hdotn_highColor, ( 1.0 - _HighColor_Power)) )
						, pow( hdotn_highColor, exp2( lerp( 11, 1, _HighColor_Power)) )
						, _Is_SpecularToHighColor 
					);
				

				float3 highColor_isLC		= lerp( attenRamp, set_LightColor, _Is_LightColor_HighColor);
				float3 highColorMix			= highColorTex.rgb * _HighColor.rgb;
				float3 highColorTotalCol	= ( highColor_isLC * highColorMix * highColorMaskSetup);






//// Rim Color	
/*
	get ndotv:	1 when surface directs with cam, -1 when towards cam. 
	1 - value:	0 with, 2 against
*/
				float rimlightMaskEnv		= envMask;
				rimlightMaskEnv				= lerp(1, rimlightMaskEnv, _envOnRim);
				float rimArea				= (1.0 - ndov_rim);
				rimArea 					+= _RimLightAreaOffset;
				//// Temp mirror correction
				// rimArea						= (frontFace) ? rimArea : 0;
				rimArea						= lerp(0, rimArea, saturate(ndov_rim + 1.1));
				float rimLightPower			= pow(rimArea, exp2( lerp( 3, 0, _RimLight_Power )));
				float RimLightPowerAp		= pow(rimArea, exp2( lerp( 3, 0, _Ap_RimLight_Power )));



				// rim masks.
				float rimlightMaskSetup;
				// soft
				[branch]
				if ( _RimLight_FeatherOff == 0)
				{
					rimlightMaskSetup	= ((rimLightPower - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask));
				}
				// hard
				else
				{
					rimlightMaskSetup	= step( _RimLight_InsideMask, rimLightPower);
				}

				// anti rimlight mask
				float rimlightApMaskSetup;
				// soft
				[branch]
				if ( _Ap_RimLight_FeatherOff == 0)
				{
					rimlightApMaskSetup	= ((RimLightPowerAp - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask));
				}
				// hard
				else
				{
					rimlightApMaskSetup	= step( _RimLight_InsideMask, RimLightPowerAp);
				}

				rimlightMaskSetup		= saturate( rimlightMaskSetup);
				rimlightApMaskSetup		= saturate( rimlightApMaskSetup);
				float4 rimLightMaskTex		= UNITY_SAMPLE_TEX2D_SAMPLER( _Set_RimLightMask, _MainTex, TRANSFORM_TEX( i.uv, _Set_RimLightMask));
				float rimLightTexMask		= saturate( rimLightMaskTex.g + _Tweak_RimLightMaskLevel);
				float rimlightMaskToward	= saturate( rimlightMaskSetup + (ndotl_pure - 1.0 - _Tweak_LightDirection_MaskLevel));
				float rimLightMaskAway		= ndotl_pure + _Tweak_LightDirection_MaskLevel;
				float rimLightMask			= lerp( rimlightMaskSetup, rimlightMaskToward, _LightDirection_MaskOn);
				// float rimlightApMask		= saturate( rimlightApMaskSetup - rimLightMaskAway);
				// rimlightApMask				= lerp( rimlightApMask, saturate(rimlightApMask - rimlightMaskToward), smoothstep(0,1,rimlightMaskToward ));
				float rimlightApMask		= saturate( rimlightApMaskSetup - rimLightMaskAway - rimlightMaskToward);	// Todo: improve rim away
				rimLightMask				*= rimLightTexMask;
				rimlightApMask				*= rimLightTexMask;

				// colors inpput
				float3 rimTexAlbedo;
				[branch] switch( _RimLightSource)
				{
					case 0:
						rimTexAlbedo	= 1;
						break;
					case 1:
						rimTexAlbedo	= mainTex.rgb;
						break;
					case 2:
						rimTexAlbedo	= highColorTex.rgb;
						break;
					case 3:
						rimTexAlbedo	= shadeMapTex_1.rgb;
						break;
					case 4:
						rimTexAlbedo	= shadeMapTex_2.rgb;
						break;
					default:
						rimTexAlbedo	= 1;
						break;
				}

				// float3 dirRimL			= reflect(-viewDirection, i.wNormal);
				// float3 rimColSource			= (DecodeLightProbe(dirRimL)) + lightDirect;
				// float3 rimColSource			= (DecodeLightProbe(dirRimL) + DecodeLightProbe_average()) * .5 + lightDirect;
				// float3 rimColSource			= DecodeLightProbe(i.wNormal) * .5 + lightDirect + envMask;
				// float3 rimColSource			= DecodeLightProbe(i.wNormal) * .5 + lightDirect;

				float3 rimLight_isLC		= lerp( attenRamp, set_LightColor, _Is_LightColor_RimLight);
				float3 rimLightAp_isLC		= lerp( attenRamp, set_LightColor, _Is_LightColor_Ap_RimLight);
				float3 rimLightMix			= _RimLightColor.rgb * rimLight_isLC * rimTexAlbedo * rimlightMaskEnv;
				float3 rimLightApMix		= _Ap_RimLightColor.rgb * rimLight_isLC * rimTexAlbedo * rimlightMaskEnv;






//// Matcap				
				float rot_MatCapUV_ang			= ( _Rotate_MatCapUV * 3.141592654);
				float rot_MatCapUV_spd			= 1.0;
				float rot_MatCapUV_cos			= cos( rot_MatCapUV_spd * rot_MatCapUV_ang);
				float rot_MatCapUV_sin			= sin( rot_MatCapUV_spd * rot_MatCapUV_ang);
				float2 rot_MatCapUV_piv			= float2(0.5,0.5);
				float rot_MatCapNmUV_ang		= ( _Rotate_NormalMapForMatCapUV * 3.141592654);
				float rot_MatCapNmUV_spd		= 1.0;
				float rot_MatCapNmUV_cos		= cos( rot_MatCapNmUV_spd * rot_MatCapNmUV_ang);
				float rot_MatCapNmUV_sin		= sin( rot_MatCapNmUV_spd * rot_MatCapNmUV_ang);
				float2 rot_MatCapNmUV_piv		= float2(0.5,0.5);
				float2 rot_MatCapNmUV			= ( mul( i.uv - rot_MatCapNmUV_piv, float2x2( rot_MatCapNmUV_cos, -rot_MatCapNmUV_sin, rot_MatCapNmUV_sin, rot_MatCapNmUV_cos)) + rot_MatCapNmUV_piv);
				float4 normalMapForMatCap		= UNITY_SAMPLE_TEX2D_SAMPLER( _NormalMapForMatCap, _NormalMap, TRANSFORM_TEX( rot_MatCapNmUV, _NormalMapForMatCap));
				float3 matCapNormalMapTex		= UnpackNormal( normalMapForMatCap);



				//v.2.0.5: MatCap with camera skew correction.  @kanihira
				float3 viewNormal					= (mul(UNITY_MATRIX_V, float4(lerp( i.wNormal, mul( matCapNormalMapTex.rgb, tangentTransform ).rgb, _Is_NormalMapForMatCap ), 0))).xyz;
				float3 normalBlendMatcapUVDetail	= viewNormal.xyz * float3(-1,-1,1);
				float3 normalBlendMatcapUVBase		= (mul( UNITY_MATRIX_V, float4(viewDirection,0) ).rgb * float3(-1,-1,1)) + float3(0,0,1);
				float3 noSknewViewNormal			= normalBlendMatcapUVBase * dot(normalBlendMatcapUVBase, normalBlendMatcapUVDetail) / normalBlendMatcapUVBase.z - normalBlendMatcapUVDetail;
				float2 viewNormalAsMatCapUV			= ((noSknewViewNormal).xy * 0.5) + 0.5;
				float2 rot_MatCapUV					= 
					(
						mul(
							(
								((viewNormalAsMatCapUV - (_Tweak_MatCapUV)) ) / (-2 * _Tweak_MatCapUV + 1.0)
							) 
							- rot_MatCapUV_piv
							, float2x2( rot_MatCapUV_cos, -rot_MatCapUV_sin, rot_MatCapUV_sin, rot_MatCapUV_cos)
						) 
						+ rot_MatCapUV_piv
					);



				float4 matCapTex		= UNITY_SAMPLE_TEX2D( _MatCap_Sampler, TRANSFORM_TEX( rot_MatCapUV, _MatCap_Sampler));
				float3 matcap_isLC		= lerp( attenRamp, set_LightColor, _Is_LightColor_MatCap);
				float3 matCapMix		= matcap_isLC * matCapTex.rgb * _MatCapColor.rgb;
				float3 matCapTotalCol		= 
					lerp( 
						matCapMix
						// , (matCapMix * ( (1.0 - shadeRamp_n1) + (shadeRamp_n1 * _TweakMatCapOnShadow))) //slow
						, matCapMix * (1 + shadeRamp_n1 * (_TweakMatCapOnShadow - 1))
						, _Is_UseTweakMatCapOnShadow
					);
				float4 matcapMaskTex	= UNITY_SAMPLE_TEX2D_SAMPLER(_Set_MatcapMask, _MainTex, TRANSFORM_TEX(i.uv, _Set_MatcapMask));
				float matcapMaskTweak	= saturate(matcapMaskTex.g + _Tweak_MatcapMaskLevel);






//// Emission
				float4 emissiveMask		= UNITY_SAMPLE_TEX2D_SAMPLER( _Emissive_Tex, _MainTex, TRANSFORM_TEX( i.uv, _Emissive_Tex));
				float4 emissionColor	= UNITY_SAMPLE_TEX2D( _EmissionColorTex, TRANSFORM_TEX( i.uv, _Emissive_Tex));






//// Blend, Texture Color & High Color
				float3 highColorIn		= shadeColor;
				float highColorInShadow	= 
					lerp(
						1
						// , ((1.0 - shadeRamp_n1) + (shadeRamp_n1 * _TweakHighColorOnShadow)) // slow
						, shadeRamp_n1 * (_TweakHighColorOnShadow - 1) + 1
						, _Is_UseTweakHighColorOnShadow
					);
				float3 highColorFinal	= highColorTotalCol * highColorInShadow;

				float hC_oneMinusReflectivity;
				float3 hC_albedo	= EnergyConservationBetweenDiffuseAndSpecular_ac(
					(_Is_BlendAddToHiColor), highColorIn, highColorFinal, hC_oneMinusReflectivity
				);
				float3 HighColorOut	= hC_albedo + highColorFinal;






//// Blend, (Texture & High Color) & Rim Color
				float3 rimLightIn	= HighColorOut;
				float3 rimMixer1;
				// [branch] switch (_RimLight)
				switch (_RimLight)
				{
					case 0: // off
						rimMixer1	= rimLightIn;
						break;
					case 1:	// add
						rimMixer1	= rimLightMix * rimLightMask + rimLightIn;
						break;
					case 2: // replace
						rimMixer1	= lerp(rimLightIn, rimLightMix, rimLightMask);
						break;
					default:
						rimMixer1	= 0;
						break;
				}

				float3 rimMixer2;
				switch (_Add_Antipodean_RimLight)
				{
					case 0: // off
						rimMixer2	= rimMixer1;
						break;
					case 1:	// add
						rimMixer2	= rimLightApMix * rimlightApMask + rimMixer1;
						break;
					case 2: // replace
						rimMixer2	= lerp(rimMixer1, rimLightApMix, rimlightApMask);
						break;
					default:
						rimMixer2	= 0;
						break;
				}
				float3 rimLightOut	= rimMixer2;


//// Blend, (Texture & High & Rim) & Matcap & Emission
				float3 matCapIn				= rimLightOut;
				float3 matCap_isAdd			= matCapTotalCol * matcapMaskTweak + matCapIn;
				float3 matCap_isMulti		= lerp(matCapIn, matCapIn * matCapTotalCol, matcapMaskTweak);
				float3 matCap_type			= lerp(matCap_isMulti, matCap_isAdd, _Is_BlendAddToMatCap);
				float3 matCapOut			= lerp(matCapIn, matCap_type, _MatCap);



//// Blend, emission
				float3 emissionIn		= matCapOut;
				// float emissiveMask			= saturate(dot(emissiveMask.rgb, 1));
				float3 emissionMix		= (emissiveMask.rgb * emissionColor.rgb * _Emissive_Color.rgb);
#ifdef UNITY_PASS_FORWARDBASE
				float3 emissionOut		= emissionIn + emissionMix;
#else
				float3 emissionOut		= emissionIn;
#endif



				// resolve NaN value colors.
				float3 finalColorIn	= emissionOut;
				float3 finalColor	= max(0, finalColorIn);
				




// #ifdef UNITY_PASS_FORWARDBASE
// 				fixed4 finalRGBA	= fixed4(finalColor, alpha);
// #elif UNITY_PASS_FORWARDADD
// 				fixed4 finalRGBA	= fixed4(finalColor * alpha, 0);
// #endif
				fixed4 finalRGBA	= fixed4(finalColor, alpha);

				// debug
				// finalRGBA	= finalRGBA*.001+float4(testVar.xxx, 1);

				UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
				return finalRGBA;
			}