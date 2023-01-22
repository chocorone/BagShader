Shader "BagShader/BagImageShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
        Pass {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnityCG.cginc"

            #include "../Util.hlsl"
            
            struct appdata {
                float4 vertexOS : POSITION;
                float2 texcoord : TEXCOORD0;
            }; 

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                o.pos = UnityObjectToClipPos(v.vertexOS);
                o.uv = v.texcoord;

                return o;
            }

            sampler2D _MainTex;
            
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
                data.shift = _Shift;
                data.frec = _Frec;
                data.ratio = _Ratio;
                data.blur = _Blur;
                data.strength = _Strength;
                data.colorGap = _ColorGap;
                data.isImage = true;
                data.mainTex = _MainTex;

                half4 col = CalBagShaderColor(data);
                return col;
            }

            ENDHLSL
        }
    }
}
