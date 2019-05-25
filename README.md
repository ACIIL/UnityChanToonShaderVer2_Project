README.md



# Intro:
UTS2-ac shader, a git fork of UnityChanToonShaderVer2_Project (UTS2) with lighting improvements and bug fixes based on the v2.0.4+ versions.
Tweaks by ACiiL.

https://github.com/ACIIL/UnityChanToonShaderVer2_Project

Credits to the original author(s) unity3d-jp for humbly providing UTS2 open source and those that helped me develop the improvements.

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project






# Install: 
In github download the zip in the releases tab or from the branch you selected. In the zip file you will find the asset/ folder and Manual/ documentation.
Copy the inner Toon/  folder into your unity assets\ project folder.  Your shader listing should now have UnityChainToonShader/ACiiL sub menu installed.


Watchout when applying UTS2 to news materials for when object sorting is see-threw, fix it by setting the zwrite on.






# What is this and history:
UTS2 is a extremely customizable toon shader. Its good for 2 to 5 "color tone" toony paint effects with many options which represent Unity standard shader appearance in a abstracted toony way.

Today mainline UTS2 has moved forward to v2.0.5+ and this little side branch of mine was for v2.0.4+. It should be possible to swap other versions of UTS2 with mine for a while. 

This has a been about a year long on-and-off study project since middle of January 2018. Back then no one knew UnityChanToonShaderVer2_Project and it didnt work in vrchat, I was interested in making it function in vrchat. Some on and off weeks studying unity's hlsl i learned unity's lighting and how to correctly manipulate them for shaders. This Study result is UTS2-AC.

After some lucky back and forth with the main author of UTS2 shader i shown them my code edits and then the main branch of UTS2 became functional in vrchat. Now we see UTS2 being used freely for commercial avatar sales on Booth.pm and the general players in vrchat who like the styles UTS2 provides. 

My UTS2 branch is its own separate fork. I have my own methods to approach unity engine's lighting system and my own goals to take it. I want to give artists the power to select UTS2 shader effects without disobeying unity's light system (to much) under the common bad map lighting seen in vrchat maps.

In regards to community improvements i will accept code contribution as pull requests! Pass me bug fixes for my fork, preferably within github.






# Manual: 
Read the documentation for UTS2.
See the latest mainline UTS2 release manual, it contain videos and examples of setup:

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project/blob/master/Manual/

Note my fork is somewhat different from the mainline readme version.






# Shader keywords limit notes and solutions for avatar creators and shader writers.
A common problem to all vrchat shaders is sharing the limited space of shader keywords. When the limit is hit durring a play session strange visual bug will happen to new shaders loading in. The keyword space can also be flooded in your unity project avoid that by only enabling shaders you use.

# How do clean up keywords before avatar upload manually:
There is a way to clean up unused keywords in materials between shader swaps and updates! 
Select your material -> set debug by using the drop down gear right of the inspector tab row -> read out the "keywords" text box and test deleting that list. If things look ok after you are lucky.



For shader writers, avoid methods that create keywords. See how i implemented [toggle(_)] for toggles and number enum's, and see how defines do not use 
\#pragma shader_feature or \#pragma multi_compile






# Forks differences and features.
Details what's different in UTS2-AC. See the official UTS2 readme for everything.



* Face _CullMode, if faces render both/back/forward.



* For alpha shaders, The alpha texture mask and settings
  * Alpha is alpha to converage, screen space alpha cutout. Use fade for best and most redundant alpha sorting and supports shadow receives and casting.
  * Checkmark "use main texture alpha" when it has the alpha channel, otherwise use a custom grayscale texture that represents the alpha.
  * Zwrite off may give strange invisible appearance. Default on unless you want  alphas textures that is see threw completely.



* The dynamic toon ramp system
  * Begin with basic texture assignment. UTS2 is intended to have 3d custom edited textures however you may set the main texture and reuse with dropdowns.
  * UTS2 has 3 concepts for light in subsets of different properties: 
     * "Direct to light"
	 * "Core ambient in shadow"
	 * "Facing away from light"
  * What makes UTS2 unique is the 3 layer toon ramp system built with: ramps, painted albedo textures, and ambient occlusion textures. Use these to strictly control how you character appears in light and shadows.
  * UTS2 mixes shading as two lerps as:  (LightSide | (Tone1 | Tone3)). 
     * LightSide disappears in shadow or facing away from light, depending how you setup.
	 * (Tone 1 and 2) becomes what's in the ambient and facing away from light depending how you setup.
  * The "ambient occlusion" slots as "Set_N_shadePosition" are used to down ramp the shading toward: 1st what is considered not direct to light, and 2nd forcing away from light shadows. You can also use the AOs to colorize areas as you wish depending how you setup.
  * For artistic and natural looking toon shading tones, saturation the shadow colors textures (with a point editor) and shift the hue towards blue. Avoid gray tones except for metallics. 
  * For skin ramps, down ramp the shade to the color of the skin, however saturate the color at most 15%. Remember to shift hud towards blue from red/yellow.
  * Shadows have a minimal shadow blackness setting. Use it to ignore the extremely black contribution of dynamic shadow casts (see black shadow and no ambient light in that space). Use this when you find yourself in harsh maps without ambient lights to soften black shadows; Its a realism compromise.

  
  
* Custom shadow cast and falloff system.
  * Bit of a pain and most of my work. The entire light mixing is most of my original code in this fork.
  * Direct and indirect light as well as vertex lights is what makes UTS2-ac a demo for how adaptable shaders can be to typical Vrchat maps that do lighting wrong and miss things.
  * Shadow attenuation and falloff is split. From my work there is far smarter control to how light attenuation is used and mixes with ambient light.
  * I treat dyanmic shadows as a "dynamic toon ramp" that influences the appearance over the static toon ramp.
    * A shadow cast dynamic saturation setting - albedo color saturation goes up the stronger shadow is in dark ambiance. It looks nice, like a fake bit of light bouncing in AO corners.
  * Light falloff dimming is minimized to the limit of the light radius, as to minimize toning toon colors. This is possible with my light attenuation refractor.
  * to help control "shadow cast stepping" artifacts on the toon ramp, Shadow attenuation is remapped, its not perfect because there is no way to control shadow casting flaws.
  * From my lighting refactor, point and spot light shadows weaken over distance.


  
* (Specular) highColor. The Toon shine effect.
  * This is specular. To enable set color tint other than black and raise the power.
  * Mixing has two modes: replace or add. You can then leave it without texture source or give a texture to control how the specular tints. There is surprisingly a lot of control.

  
  
* The RimLight. 
  * UTS rim setup choices is huge. Controls for harshness, power, falloff,etc.
  * I have extended the rim light mixing:
    * Mix mode is additive or replace. Use replace to setup darkern brightness.
	* Abedo can set as a texture instead of solid tone. For example, sample the main texture with a solid Red rim color in Replace mode for a neat effect.
	* Rim can be offset from the surface corners, combined with feature new hard rimlight edges are possible and better than the old hard edge mode.
  * UTS2 has a anti-rim light, this grows in intensity against light. Very powerful to fake ambience or fake subsurface scattering! Use it for skin effects or glossiness.
  * A bugfix for front and back rims stacking in two-face culling and in mirrors over the main UTS2.

* World reflection.
  * Sample the world reflect cube and set roughness.
  * Currently acts as a grayscale mask for Rim lights. Use it make rims more lively by view angle or set rimlights for glossy appearance.

  
  
* Matcap. Assign the matcap and enable. Settings allow extensive control of light mixing and texture scale. 
  * Use matcap to fake: glossiness, metallics, reflection, etc.
  * For matcap that look like specular or rim lights please use the above effects for a better dynamic result. Use matcap for reflection and iridescence maps.
  * My fork adopts v2.0.5+ matcap with the camera pan correction.



* Emission. A mask texture and color texture as well as a HDR color pick for intensity.


* "LightColor" switches, these make each effect follow the world lighting or stay static, use it for a unlit mode that reacts to light attenuation.



* Outlines. Are shader pass based and not geometry. In concept outlines change thickness by distance to camera. You adjust the near and far range in object space (it scales to the object size regardless of world space rescale)
  * Outlines match the alpha of the albedo texture when shader is alpha type.
  * There is a minimal shadow blackness setting to remove shadow casts on the outlines.



* Stencil settings are all combined into a list. 
  * NOTICE: Feature is incomplete from the GUI. I recommend using ThryEditor for setting a custom queue, as you will have to make sure the mask appears in queue before the pass threw shader.
  * To setup eyes passing over hair:
	Mark you eyes with and queue before hair:
			Stencil {
			Ref[_StencilNo]
			Comp Always
			Pass Replace
			Fail Replace
		}
	Mark your hair with and queue after eyes:
			Stencil {
			Ref[_StencilNo]
			Comp NotEqual
			Pass Keep
			Fail Keep
		}






# Shader file usage and render error avoidances.
Start by using the no-outlines version for best performance (outlines are extra passes. So i typically use it for non alpha or skin materials).
  * Your default shader is: ToonColor_DoubleShadeWithFeather.
  * Your clipping shader is: ToonColor_DoubleShadeWithFeather_ClippingCutout.
  * Your transparency is ToonColor_DoubleShadeWithFeather_TransClippingFade.shader
  
I use dither cutout alpha. It should be able to handle any alpha texture and mesh layering after a bit of calibration in the settings. You only pay the cost of a screenspace pattern and quality improves as you raise MSAA or screen resolution.



# Limitations of alpha. 
True transparency queue shaders will not have z sorting issues, however the unity engine cannot do shadow receiving and thus dynamic toon ramps will be full bright. I made my fork use dithered cutout with alpha as a solution.



# Color balancing and map bloom control.
Its really easy to get the stack of effects in UTS2 to overbright. Basically dont use full white color tints on effects.
I recommend installing unity post processing stack in your scene with bloom on and watch when bloom is too strong with a default directional light and ambience.
Bloom happens when HRD color values goes higher than 110% and you should know many maps like to push lights above this value in vrchat! 

So to limit blooming make your toon ramps darker than 95% luminance. Set your base color ramp to (0.95, 0.95, 0.95, 1) and go down brightness in the shadows. You will be fairly resistant to over brighting in maps and its a good average to how lambart darking in Standard shader averages.

To control specular effects you actually can go higher than 100%, just watch the bloom.

If you come across very badly lit shadows in vrchat maps there is a way to compensate. Increase the "minimal shadow caster blackness" from 0 (which is natural).



# Outlines setup.
Please default your outline color to 50% bright and balance from there. Please Use outlines with Opaque mode only.




# Bugs:
Please send issue reports to my github page.

Some vrchat maps are setup light incorrectly, in a perfect world they obey unity's light models, where direct lights (dynamics and shadows) are counter balanced by indirect lights (ambient) and reflection sources, and correct post processing for HDR practices.

If you come across a map too bright or shadows too black, please contact the author and promptly yell until they fix it on standard shader. For maps where standard shader avatars looks fine and UTS does not i will be interested in debugging. Provide me with the map name and author to visit.

Outlines have an outstanding shadow caster bug. Directional light shadows bleed threw the outlines. Fixing will need a geometry in shadow caster rewrite.

Stencil currently requires manual file editing.

Is your model pure black when you apply UTS2? Default your model import settings: You want unity to calculate tangent normals.






# Support credits to:
Noe, TCL, June, Cubed, Silent, RetroGeo, Xiexe, Mel0n, Cibbi, Hakanai, Neitri, 1001, Kaj, Error.mdl, d4rkpl4y3r, poiyomi, Thryrallo, many more.






# Hosting site:

https://github.com/ACIIL/UnityChanToonShaderVer2_Project

A fork of:

https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project






# License:
I inherent the Unity-Chan Toon Shader license (UCL2_0). In addition if you use my forks separate methods or tips please credit towards my github and name; I really appreciate citation and i will do the same. Contact me by discord or twitter if you want to sort out what of this code is fully my work or UTS2 original.

Unity-Chan Toon Shader 2.0 is provided under the Unity-Chan License 2.0 terms.  
Please refer to the following link for information regarding the Unity-Chan License.  
http://unity-chan.com/contents/guideline_en/


---------------------------------------------------------------
