Shader "URPBagShader/NormalBagShader"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 0
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull [_Cull]
        Tags { "Queue" = "Transparent" }

        Pass {

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            #include "../Util.hlsl"
            
            struct appdata {
                float4 vertexOS : POSITION;
                float2 texcoord : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            }; 

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = TransformObjectToHClip(v.vertexOS);
                o.worldPos=  ComputeScreenPos(o.pos);
                o.uv =v.texcoord;

                return o;
            }

            
            half4 frag (v2f i) : SV_Target
            {
                half2 screenPos = i.worldPos.xy / i.worldPos.w;
                half4 col = half4(SampleSceneColor(screenPos),1);

                col.rgb = 1- col.rgb;
                return col;
            }

            ENDHLSL
        }
    }
}
