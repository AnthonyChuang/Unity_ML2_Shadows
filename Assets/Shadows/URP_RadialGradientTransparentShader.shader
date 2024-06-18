Shader "Custom/URP_RadialGradientWithTransparency"
{
    Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (0, 0, 0, 1)
        _Slide("Slide", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
            };

            float4 _ColorA, _ColorB;
            float _Slide;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.texcoord = v.texcoord;
                o.worldPos = TransformObjectToWorld(v.positionOS).xyz;
                o.worldNormal = TransformObjectToWorldNormal(v.positionOS.xyz);
                o.shadowCoord = TransformWorldToShadowCoord(o.worldPos);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float t = length(i.texcoord - float2(0.5, 0.5)) * 1.41421356237; // 1.414... = sqrt(2)
                half4 color = lerp(_ColorA, _ColorB, t + (_Slide - 0.5) * 2);
                float shadow = SHADOW_ATTENUATION(i.shadowCoord);
                return color * shadow;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
