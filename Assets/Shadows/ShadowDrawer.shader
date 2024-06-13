Shader "Custom/ShadowDrawer"
{
    Properties
    {
        _Color("Shadow Color", Color) = (0, 0, 0, 0.0)
    }

    HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    struct Attributes
    {
        float4 vertex : POSITION;
    };

    struct Varyings
    {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
    };

    half4 _Color;

    Varyings Vert(Attributes input)
    {
        Varyings output;
        output.pos = TransformObjectToHClip(input.vertex);
        output.worldPos = TransformObjectToWorld(input.vertex);
        return output;
    }

    half4 Frag(Varyings input) : SV_Target
    {
        // Get the main light direction
        Light mainLight = GetMainLight();
        float atten = 1.0; // Default to no shadow attenuation

        // Sample shadow map if shadows are enabled
        #if defined(_MAIN_LIGHT_SHADOWS)
            atten = MainLightRealtimeShadow(input.pos);
        #endif

        return half4(_Color.rgb, lerp(_Color.a, 0, atten));
    }

    ENDHLSL

    SubShader
    {
        Tags { "Queue" = "AlphaTest+49" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            Name "ShadowDrawerPass"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"
}
