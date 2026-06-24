Shader "Custom/UI/Transition/PixelMosaic"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Progress("Progress", Range(0,1)) = 0
        _PixelSizeMin("Pixel Size Min", Range(1,64)) = 1
        _PixelSizeMax("Pixel Size Max", Range(2,128)) = 28
        _FadeSoftness("Fade Softness", Range(0.001,0.25)) = 0.06

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
            float _PixelSizeMin;
            float _PixelSizeMax;
            float _FadeSoftness;

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
                float pixelSize = lerp(_PixelSizeMin, _PixelSizeMax, _Progress);
                float2 blockCount = max(float2(1.0, 1.0), float2(pixelSize, pixelSize));
                float2 blockUv = floor(IN.uv * blockCount) / blockCount;

                fixed4 col = (tex2D(_MainTex, blockUv) + _TextureSampleAdd) * IN.color;
                float alphaMask = 1.0 - smoothstep(1.0 - _Progress - _FadeSoftness, 1.0 - _Progress + _FadeSoftness, IN.uv.y);
                col.a *= alphaMask * UnityGet2DClipping(IN.worldPos.xy, _ClipRect);
                return col;
            }
            ENDCG
        }
    }
}