Shader "UI/CornerBevel"
{
    Properties
    {
        _MainTex       ("Texture",        2D)     = "white" {}
        _CornerRadius  ("Corner Radius",  Float)  = 20.0
        _Size          ("Rect Size",      Vector) = (100, 100, 0, 0)
        // Sprite atlas crop rect (x, y, w, h) in normalised texture coords.
        // (0, 0, 1, 1) for RawImage / full-texture; set from sprite bounds for Image.
        _CropRect      ("Crop Rect",      Vector) = (0, 0, 1, 1)
        _EdgeSoftness  ("Edge Softness",  Float)  = 1.5
        // Standard UI stencil/blend properties
        [HideInInspector] _StencilComp      ("Stencil Comparison",  Float) = 8
        [HideInInspector] _Stencil          ("Stencil ID",          Float) = 0
        [HideInInspector] _StencilOp        ("Stencil Operation",   Float) = 0
        [HideInInspector] _StencilWriteMask ("Stencil Write Mask",  Float) = 255
        [HideInInspector] _StencilReadMask  ("Stencil Read Mask",   Float) = 255
        [HideInInspector] _ColorMask        ("Color Mask",          Float) = 15
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

        Stencil
        {
            Ref       [_Stencil]
            Comp      [_StencilComp]
            Pass      [_StencilOp]
            ReadMask  [_StencilReadMask]
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
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float2 uv       : TEXCOORD0;
                fixed4 color    : COLOR;
                float4 worldPos : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4    _ClipRect;
            float     _CornerRadius;
            float4    _Size;
            float4    _CropRect;
            float     _EdgeSoftness;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPos = v.vertex;
                o.pos      = UnityObjectToClipPos(v.vertex);
                o.uv       = v.texcoord;
                o.color    = v.color;
                return o;
            }

            // SDF for a rounded rectangle centred at origin, half-extents b, corner radius r.
            float roundedRectSDF(float2 p, float2 b, float r)
            {
                float2 d = abs(p) - (b - r);
                return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;

                // Normalise UV to [0,1] across the visible quad, regardless of
                // whether it is a full texture (RawImage) or an atlas slice (Image).
                float2 normUV   = (i.uv - _CropRect.xy) / _CropRect.zw;
                float2 halfSize = _Size.xy * 0.5;
                float2 pixelPos = (normUV - 0.5) * _Size.xy;
                float  r        = clamp(_CornerRadius, 0.0, min(halfSize.x, halfSize.y));
                float  dist     = roundedRectSDF(pixelPos, halfSize, r);
                float  mask     = 1.0 - smoothstep(-_EdgeSoftness, _EdgeSoftness, dist);

                col.a *= mask;

                #ifdef UNITY_UI_CLIP_RECT
                col.a *= UnityGet2DClipping(i.worldPos.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip(col.a - 0.001);
                #endif

                return col;
            }
            ENDCG
        }
    }
}
