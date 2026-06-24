Shader "Custom/UI/Transition/GlitchSlices"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Progress("Progress", Range(0,1)) = 0
        _SliceCount("Slice Count", Range(8,120)) = 42
        _OffsetStrength("Offset Strength", Range(0,0.2)) = 0.05
        _Softness("Softness", Range(0.001,0.2)) = 0.05

        [HideInInspector] _StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float _Progress;
            float _SliceCount;
            float _OffsetStrength;
            float _Softness;

            float Hash11(float p)
            {
                p = frac(p * 0.1031);
                p *= p + 33.33;
                p *= p + p;
                return frac(p);
            }

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.worldPos = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.uv = IN.texcoord;
                OUT.color = IN.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float row = floor(IN.uv.y * _SliceCount);
                float rnd = Hash11(row + floor(_Progress * 73.0));
                float xOffset = (rnd - 0.5) * _OffsetStrength * (1.0 - _Progress);
                float2 warpedUv = IN.uv + float2(xOffset, 0);

                fixed4 col = (tex2D(_MainTex, warpedUv) + _TextureSampleAdd) * IN.color;

                float band = frac(IN.uv.y * (_SliceCount * 0.5) + rnd);
                float cutoff = _Progress * (1.0 + _Softness) - _Softness;
                float alphaMask = smoothstep(cutoff, cutoff + _Softness, band);
                col.a *= alphaMask * UnityGet2DClipping(IN.worldPos.xy, _ClipRect);
                return col;
            }
            ENDCG
        }
    }
}