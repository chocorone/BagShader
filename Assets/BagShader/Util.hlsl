#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

struct BagShaderData 
{
    half4 color;
    half2 uv;
    float splitX;
    float splitY;
    half shift;
    half frec;
    float ratio;
    float blur;
    float strength;
    float colorGap;
}; 

static const float division = 768;
static const float blackinterval = 6;

float rand(float2 co) 
{
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

half3 SceneColor(float2 uv){
    return SampleSceneColor(uv);
}

half4 CalBagShaderColor(BagShaderData data){

    data.blur*=0.01;
    data.strength *= 0.002;
    data.colorGap*=0.1;

    int divisionindex = data.uv.y * division;

    int noiseindex = divisionindex / blackinterval;

    float3 timenoise = float3(0, int(_Time.x*data.frec * 61), int(_Time.x*data.frec * 83));
    float noiserate = rand(timenoise) < 0.05 ? 10 : 1;

    float xnoise = rand(float3(noiseindex, 0, 0) + timenoise);
    xnoise = xnoise * xnoise - 0.5; 
    xnoise = xnoise * noiserate;
    xnoise = xnoise *data.strength* (_SinTime.w*data.frec / 2 + 1.1); 
    xnoise = xnoise + (abs((int(_Time.x * 2000) % int(division / blackinterval)) - noiseindex) < 5 ? 0.005 : 0); 

    data.uv += float2(xnoise, 0);

    //ちょっとぼかす
    half4 col1 = half4(SampleSceneColor(data.uv),1);
    half4 col2 = half4(SampleSceneColor(data.uv + float2(data.blur, 0)),1);
    half4 col3 = half4(SampleSceneColor(data.uv + float2(-data.blur, 0)),1);
    half4 col4 = half4(SampleSceneColor(data.uv + float2(0, data.blur)),1);
    half4 col5 = half4(SampleSceneColor(data.uv + float2(0,-data.blur)),1);
    half4 col = (col1 * 4 + col2 + col3 + col4 + col5) / 8;

    float4 shiftColor = float4(1,1,1,1);

    //分割
    float2 uv = float2(floor(data.uv.x/(1/data.splitX))+1,floor(data.uv.y/(1/data.splitY))+1);

    half time = _Time.x*0.00001*data.frec;

    // //ランダムでずらす
    if(rand(uv*sin(time))>(1-data.ratio)){
        data.uv.y-=data.shift;
        half3 uvVec = half3(data.uv.xy-0.5,1);
        half3x3 scaleMatrix = half3x3(0.95, 0, 0,
                                    0,0.95,0,
                                    0,0,1);
        uvVec = mul(scaleMatrix,uvVec);
        data.uv.x = uvVec.x+0.5;

        
        float r = SampleSceneColor(data.uv + data.colorGap).x;
        float b = SampleSceneColor(data.uv - data.colorGap).y;
        
        shiftColor = half4(r, col.g, b, col.a);
    
        col = col*shiftColor;
    }
                

    return col;
}