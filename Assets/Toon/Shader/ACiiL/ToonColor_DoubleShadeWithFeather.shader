Shader "UnityChanToonShader/ACiiL/NoOutline/ToonColor_DoubleShadeWithFeather" {
	Properties 
	{ 
		[HideInInspector] shader_master_label ("UTS2 - AC", Float) = 0
		[HideInInspector] shader_presets ("UTS2ACPresets", Float) = 0
		[HideInInspector] footer_github("linkButton(Github,https://github.com/ACIIL/UnityChanToonShaderVer2_Project)", Float) = 0
		// [HideInInspector] m_ ("blah", Float) = 0
		// [HideInInspector] m_start_ ("startblah", Float) = 0
		// [HideInInspector] m_end_ ("endblah", Float) = 0

		[Enum(OFF,0,FRONT,1,BACK,2)] _CullMode	("Cull Mode", int)	= 2  //OFF/FRONT/BACK

		[Space(25)]
		[Header(Alpha mask)]
		[HideInInspector] m_AlphaOps ("Alpha Mask Options", Float) = 0
		_ClippingMask	("Clipping mask", 2D)								= "white" {}
		_Clipping_Level	("Clipping level", Range(0, 1))						= 0 
		_Tweak_transparency	("Tweak transparency", Range(-1, 1))			= 0
		[Toggle(_)]_IsBaseMapAlphaAsClippingMask	("Use main texture Alpha", Float )	= 0
		[Toggle(_)]_Inverse_Clipping				("Inverse clipping", Float )		= 0
		[Toggle(_)]_DetachShadowClipping	("Separate Shadow Clipping", Float)	= 0
		_Clipping_Level_Shadow	("Shadow Clipping level", Range(0, 1))			= 1
		[Enum(Off,0,On,1)] _ZWrite	("Z Write. Depth write", Int)				= 1



		[Space(25)]
		[Header(Normal map)]
		[HideInInspector] m_NormalMap ("Normal map", Float) = 0
		_NormalMap							("NormalMap", 2D)			= "bump" {}
		[Toggle(_)]_Is_NormalMapToBase		("On Toon", Float )			= 0
		[Toggle(_)]_Is_NormalMapToHighColor	("On High Color", Float )	= 0
		[Toggle(_)]_Is_NormalMapToRimLight	("On Rims", Float )			= 0
		[Toggle(_)]_Is_NormaMapToEnv		("On Reflection", Float)	= 0



		[Space(25)]
		[Header(Toon ramp)]
		[HideInInspector] m_ToonRamp ("Toon ramp", Float) = 0
		_MainTex				("Main Tex", 2D)							= "white" {}
		_1st_ShadeMap			("1st shade Tex 1", 2D)						= "white" {}
		_2nd_ShadeMap			("2nd shade Tex 2", 2D)						= "white" {}
		[Enum(Self,0,BaseTex,1)]_Use_BaseAs1st	("1st shade source", float)	= 1
		[Enum(Self,0,Shade1,1)]_Use_1stAs2nd	("2st shade source", float)	= 1
		[HDR]_Color				("Base color", Color)						= (1,1,1,1)
		[HDR]_1st_ShadeColor	("1st shade color 1", Color)				= (1,1,1,1)
		[HDR]_2nd_ShadeColor	("2nd shade color 2", Color)				= (1,1,1,1)
		_BaseColor_Step			("Step: base|shades ", Range(0, 1))			= 0.6
		_ShadeColor_Step		("Step: shades 1|2", Range(0, 1))			= 0.4
		_BaseShade_Feather		("Feather: base|shades", Range(0.0001, 1))	= 0.0001
		_1st2nd_Shades_Feather	("Feather: shades 1|2", Range(0.0001, 1))	= 0.0001



		[Space(25)]
		[Header(Shadow and AO control)]
		[HideInInspector] m_Shadow ("Shadow Options", Float) = 0
		_Set_1st_ShadePosition 		("1st AO shade Position", 2D)					= "white" {}
		_Set_2nd_ShadePosition 		("2nd AO shade Position", 2D)					= "white" {}
		_shadowCastMin_black 		("Shadow minimal dark", Range(0.0,1.0))			= 0
		[Toggle(_)]_Set_SystemShadowsToBase	("Shadow affects shading", Float )		= 1
		_Tweak_SystemShadowsLevel	("Tweak shade from shadow", Range(-0.5, 0.5))	= 0
		_shaSatRatio				("Shadow saturate ratio", Range(0, 2))			= 0.125



		[Space(25)]
		[Header(High Color. Specular)]
		[HideInInspector] m_Specular ("Specular Options", Float) = 0
		_HighColor_Tex				("HighColor Tex albedo", 2D)				= "white" {}
		_Set_HighColorMask			("HighColor Tex Mask", 2D)					= "white" {}
		[Enum(Self,0,BaseTex,1)]_highColTexSource	("HighColor source", float)	= 0
		_Tweak_HighColorMaskLevel	("Tweak highColor Mask", Range(-1, 1))		= 0
		[HDR]_HighColor				("Color", Color)							= (0,0,0,1)
		_HighColor_Power			("Power", Range(0, 1))						= 0
		[Enum(Replace,0,Add,1)]_Is_BlendAddToHiColor	("Blend mode", Float )	= 1
		[Toggle(_)]_Is_SpecularToHighColor	("Is highColor soft", Float )						= 0
		[Toggle(_)]_Is_UseTweakHighColorOnShadow	("Mask highColor in shadow", Float )		= 0
		_TweakHighColorOnShadow						("Tweak highColor in shadow", Range(0, 1))	= 0



		[Space(25)]
		[Header(Rimlights)]
		[HideInInspector] m_RimLights ("Rim lights", Float) = 0
		_Set_RimLightMask			("RimLight Tex mask", 2D)			= "white" {}
		_Tweak_RimLightMaskLevel	("Tweak: mask", Range(-1, 1))		= 0
		[Enum(Off,0,Add,1,Replace,2)]_RimLight		("Mix: RimLight", Float )					= 0
		[Enum(Off,0,Add,1,Replace,2)]_Add_Antipodean_RimLight	("Mix: Ap RimLight", Float )	= 0
		[Enum(None,0,BaseTex,1,HighColor,2,Shade1,3,Shade2,4)]_RimLightSource	("Source albedo", Float)	= 0
		[HDR]_RimLightColor			("Color: RimLight", Color)						= (1,1,1,1)
		[HDR]_Ap_RimLightColor		("Color: Ap RimLight", Color)					= (1,1,1,1)
		[Toggle(_)]_LightDirection_MaskOn	("Use light direction", Float )			= 0
		[Toggle(_)]_RimLight_FeatherOff		("Off rimLight feather", Float )		= 0
		[Toggle(_)]_Ap_RimLight_FeatherOff	("Off Ap rimLight feather", Float )		= 0
		_RimLight_Power			("Power: RimLight", Range(0, 1))					= 0.1
		_Ap_RimLight_Power		("Power: Ap RimLight", Range(0, 1))					= 0.1
		_RimLightAreaOffset		("Offset: RimLight", Range(-1, 1))					= 0
		_RimLight_InsideMask	("Mask: Inside rimLight", Range(0.00001, 1))		= 0.0001
		_Tweak_LightDirection_MaskLevel	("Mask: Light direction", Range(0, 1))		= 0



		[Space(25)]
		[Header(World reflection)]
		[HideInInspector] m_Reflection ("World reflection Options", Float) = 0
		_envRoughness	("Reflection roughness", Range(0, 1))	= 0.34
		_envOnRim		("Reflection on rimLights", Range(0,1))	= 0.5



		[Space(25)]
		[Header(Matcap)]
		[HideInInspector] m_Matcap ("Matcap", Float) = 0
		_NormalMapForMatCap					("MatCap normalMap", 2D)					= "bump" {}
		[Toggle(_)]_Is_NormalMapForMatCap	("Use matcap normalMap ", Float )			= 0
		_MatCap_Sampler						("MatCap Tex albedo", 2D)					= "black" {}
		_Set_MatcapMask						("Matcap mask", 2D)							= "white" {}
		_Tweak_MatcapMaskLevel				("Tweak: Matcap mask", Range(-1, 1))		= 0
		[Toggle(_)]_MatCap					("Use MatCap", Float )						= 0
		[HDR]_MatCapColor					("MatCap Color", Color)						= (1,1,1,1)
		[Enum(Multiply,0,Add,1)]_Is_BlendAddToMatCap	("Matcap Blend Mode", Float)	= 1
		_Tweak_MatCapUV						("Zoom matCap", Range(-0.5, 0.5))			= 0
		_Rotate_MatCapUV					("Rotate matCap", Range(-1, 1))				= 0
		_Rotate_NormalMapForMatCapUV		("Rotate normalMap matCap", Range(-1, 1))	= 0
		[Toggle(_)]_Is_UseTweakMatCapOnShadow	("Mask matCap in shadow", Float )		= 0
		_TweakMatCapOnShadow				("Tweak matCap in shadow", Range(0, 1))		= 0



		[Space(25)]
		[Header(Emission)]
		[HideInInspector] m_Emission ("Emission", Float) = 0
		_Emissive_Tex			("Emissive mask tex", 2D) 	= "white" {}
		_EmissionColorTex		("Emissive color tex", 2D) 	= "white" {}
		[HDR]_Emissive_Color	("Emissive color", Color)	= (0,0,0,1)



		[Space(25)]
		[Header(World color settings)]
		[HideInInspector] m_ColorSettings ("World color settings", Float) = 0
		[Toggle(_)]_Is_LightColor_Base			("Use LightColor in Base", Float )			= 1
		[Toggle(_)]_Is_LightColor_1st_Shade		("Use LightColor in 1st_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_2nd_Shade		("Use LightColor in 2nd_Shade", Float )		= 1
		[Toggle(_)]_Is_LightColor_HighColor		("Use LightColor in HighColor", Float )		= 1
		[Toggle(_)]_Is_LightColor_RimLight		("Use LightColor in RimLight", Float )		= 1
		[Toggle(_)]_Is_LightColor_Ap_RimLight	("Use LightColor in Ap RimLight", Float )	= 1
		[Toggle(_)]_Is_LightColor_MatCap		("Use LightColor in MatCap", Float )		= 1



		[Space(25)]
		[Header(Stencil)]
		[HideInInspector] m_Stencil ("Stencil", Float) = 0
		_Offset					("Offset", float)						= 0
		[Toggle(_)] _Stencil	("Stencil ID [0;255]", Range(0,255))	= 0
		_ReadMask				("ReadMask [0;255]", Int)				= 255
		_WriteMask				("WriteMask [0;255]", Int)				= 255
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp	("Stencil Comparison", Int)	= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilOp			("Stencil Operation", Int)	= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFail		("Stencil Fail", Int)		= 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail		("Stencil ZFail", Int)		= 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest					("ZTest", Int)	= 4
		[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _colormask	("Color Mask", Int)	= 15
	}






	CustomEditor "ThryEditor"
	SubShader 
	{
		Tags {
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/FORWARD"
		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/FORWARD_DELTA"
		UsePass "UnityChanToonShader/ACiiL/Toon_DoubleShadeWithFeather/SHADOWCASTER"
	}
	FallBack "Legacy Shaders/VertexLit"
}
