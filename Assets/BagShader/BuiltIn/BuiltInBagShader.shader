Shader "BagShader/BagShader"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 0
        _SplitX("SplitX",float) = 5
        _SplitY("SplitY",float) = 5
        _Shift("Shift",Range(0,1)) = 0.1
        _Frec("Frec",Range(1,20))=1
        _ColorGap("ColorGap",Range(-1,1)) = 1
        _Ratio("Ratio",Range(0,1))=0.1
        _Strength("Strength",Range(0,1))=0.5
        _Blur("Blur",Range(0,1))=0.5
    }

    SubShader
    {
        Cull [_Cull]
        Tags { "Queue" = "Transparent" }

        GrabPass { }

        Pass {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../Util.hlsl"

            struct appdata {
                float4 vertexOS : POSITION;
            }; 

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                o.pos = UnityObjectToClipPos(v.vertexOS);
                float4 worldPos = ComputeGrabScreenPos(o.pos);
                o.uv =worldPos.xy/worldPos.w;

                return o;
            }

            sampler2D _GrabTexture;
            float _SplitX;
			float _SplitY;
            half _Shift;
            half _Frec;
            float _ColorGap;
            float _Ratio;
            float _Strength;
            float _Blur;
            
            half4 frag (v2f i) : SV_Target
            {
                BagShaderData data;
                data.uv = i.uv;
                data.splitX = _SplitX;
                data.splitY = _SplitY;
                data.shift = -_Shift/_SplitY;
                data.frec = _Frec;
                data.ratio = _Ratio;
                data.blur = _Blur;
                data.strength = _Strength;
                data.colorGap = _ColorGap;
                data.mainTex = _GrabTexture;
                data.isImage = true;

                half4 col = CalBagShaderColor(data);
                return col;
            }

            ENDHLSL
        }
    }
}
