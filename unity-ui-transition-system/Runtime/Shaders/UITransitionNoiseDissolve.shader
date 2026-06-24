Shader "Custom/UI/Transition/NoiseDissolve"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Progress("Progress", Range(0,1)) = 0
        _NoiseScale("Noise Scale", Range(2,40)) = 14
        _EdgeWidth("Edge Width", Range(0.001,0.2)) = 0.04
        _EdgeColor("Edge Color", Color) = (0.5, 0.9, 1.0, 1.0)
        _EdgeIntensity("Edge Intensity", Range(0,4)) = 1.6

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
            float _NoiseScale;
            float _EdgeWidth;
            fixed4 _EdgeColor;
            float _EdgeIntensity;

            float Hash21(float2 p)
            {
                p = frac(p * float2(234.34, 435.345));
                p += dot(p, p + 34.23);
                return frac(p.x * p.y);
            }

            float Noise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                float a = Hash21(i);
                float b = Hash21(i + float2(1, 0));
                float c = Hash21(i + float2(0, 1));
                float d = Hash21(i + float2(1, 1));
                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
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
                fixed4 col = (tex2D(_MainTex, IN.uv) + _TextureSampleAdd) * IN.color;
                float n = Noise(IN.uv * _NoiseScale);
                float edge0 = _Progress - _EdgeWidth;
                float edge1 = _Progress + _EdgeWidth;
                float dissolve = smoothstep(edge0, edge1, n);
                float edgeMask = saturate(1.0 - abs(n - _Progress) / max(_EdgeWidth, 0.0001));

                col.rgb += _EdgeColor.rgb * edgeMask * _EdgeIntensity * (1.0 - dissolve);
                col.a *= (1.0 - dissolve) * UnityGet2DClipping(IN.worldPos.xy, _ClipRect);
                return col;
            }
            ENDCG
        }
    }
}