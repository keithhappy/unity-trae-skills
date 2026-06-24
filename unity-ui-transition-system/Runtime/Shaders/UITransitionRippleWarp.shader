Shader "Custom/UI/Transition/RippleWarp"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Progress("Progress", Range(0,1)) = 0
        _RippleAmplitude("Ripple Amplitude", Range(0,0.08)) = 0.02
        _RippleFrequency("Ripple Frequency", Range(4,50)) = 18
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
            float _RippleAmplitude;
            float _RippleFrequency;
            float _Softness;

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
                float2 centered = IN.uv - 0.5;
                float dist = length(centered);
                float2 dir = dist > 0.0001 ? centered / dist : float2(0, 0);
                float ripple = sin(dist * _RippleFrequency - _Progress * 16.0) * _RippleAmplitude * (1.0 - _Progress);
                float2 warpedUv = IN.uv + dir * ripple;

                fixed4 col = (tex2D(_MainTex, warpedUv) + _TextureSampleAdd) * IN.color;
                float cutoff = _Progress * 1.2;
                float alphaMask = 1.0 - smoothstep(cutoff - _Softness, cutoff + _Softness, dist);
                col.a *= alphaMask * UnityGet2DClipping(IN.worldPos.xy, _ClipRect);
                return col;
            }
            ENDCG
        }
    }
}