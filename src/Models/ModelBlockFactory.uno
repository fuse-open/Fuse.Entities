using Uno.Compiler;
using Uno.Compiler.Ast;
using Uno.Compiler.ImportServices;
using Uno.Compiler.ExportTargetInterop;
using Uno.Math;
using Uno.Vector;

namespace Fuse.Content.Models
{
    [DontExport]
    public sealed class ModelBlockFactory : BlockFactory
    {
        // TODO: Reimplement way to batch draw calls ?
        public extern ModelBlockFactory([Filename] string filename);

        public override extern string GetCacheKey();
        public override extern Block CreateBlock(BlockFactoryContext ctx);
    }

    public block ModelBlockFactoryBaseBlock
    {
        public double Time: prev;

        public float3 BoundingSpherePosition:
            req(model_BS_Center as float3) model_BS_Center;

        public float BoundingSphereRadius:
            req(model_BS_Radius as float) model_BS_Radius;

        public float3 BoundingBoxMin:
            req(model_AABB_Min as float3) model_AABB_Min;

        public float3 BoundingBoxMax:
            req(model_AABB_Max as float3) model_AABB_Max;

        public double StartTime:
            req(model_StartTime as double) model_StartTime,
            req(model_StartTime as float) model_StartTime;

        public double EndTime:
            req(model_EndTime as double) model_EndTime,
            req(model_EndTime as float) model_EndTime;

        public float4x4 model_Transform:
            prev World,
            float4x4.Identity;

        public double model_Time:
            StartTime + Mod(Time, EndTime - StartTime),
            Time;

        public float4x4 World: model_Transform;

        VertexCount:
            req(model_VertexCount as int) model_VertexCount;

        public float3 VertexPosition:
            req(model_VertexPosition as float3) model_VertexPosition,
            req(model_VertexPosition as float4) model_VertexPosition.XYZ;

        public float3 VertexNormal:
            req(model_VertexNormal as float3) model_VertexNormal,
            req(model_VertexNormal as float4) model_VertexNormal.XYZ;

        public float3 VertexTangent:
            req(model_VertexTangent as float3) model_VertexTangent,
            req(model_VertexTangent as float4) model_VertexTangent.XYZ;

        public float4 VertexColor:
            req(model_VertexColor as float3) float4(model_VertexColor, 1),
            req(model_VertexColor as float4) model_VertexColor;

        public float3 VertexBinormal:
            req(model_VertexBinormal as float3) model_VertexBinormal,
            req(model_VertexBinormal as float4) model_VertexBinormal.XYZ,
            req(model_VertexTangent as float4) Cross(model_VertexTangent.XYZ, VertexNormal) * model_VertexTangent.W;

        public float2 TexCoord:
            req(model_VertexTexCoord as float2) model_VertexTexCoord,
            req(model_VertexTexCoord as float3) model_VertexTexCoord.XY,
            TexCoord0;

        public float2 TexCoord0:
            req(model_VertexTexCoord0 as float2) model_VertexTexCoord0,
            req(model_VertexTexCoord0 as float3) model_VertexTexCoord0.XY;

        public float2 TexCoord1:
            req(model_VertexTexCoord1 as float2) model_VertexTexCoord1,
            req(model_VertexTexCoord1 as float3) model_VertexTexCoord1.XY;

        public float2 TexCoord2:
            req(model_VertexTexCoord2 as float2) model_VertexTexCoord2,
            req(model_VertexTexCoord2 as float3) model_VertexTexCoord2.XY;

        public float2 TexCoord3:
            req(model_VertexTexCoord3 as float2) model_VertexTexCoord3,
            req(model_VertexTexCoord3 as float3) model_VertexTexCoord3.XY;

        public float3 AmbientColor:
            req(model_AmbientColor as float4) model_AmbientColor.XYZ,
            req(model_AmbientColor as float3) model_AmbientColor,
            prev;

        public float3 DiffuseColor:
            req(model_DiffuseColor as float4) model_DiffuseColor.XYZ,
            req(model_DiffuseColor as float3) model_DiffuseColor,
            prev;

        public float3 SpecularColor:
            req(model_SpecularColor as float4) model_SpecularColor.XYZ,
            req(model_SpecularColor as float3) model_SpecularColor,
            prev;

        public texture2D DiffuseMap:
            req(model_DiffuseMap as texture2D) model_DiffuseMap,
            prev;

        public texture2D NormalMap:
            req(model_NormalMap as texture2D) model_NormalMap,
            prev;

        public float Shininess:
            req(model_Shininess as float) model_Shininess,
            prev;


        // Batching

        World:
            req(model_TransformList as fixed float4x4[], model_TransformIndex as float) model_TransformList[(int)model_TransformIndex],
            prev;

        public float3x3 World3x3:
            req(model_TransformList as fixed float4x4[], model_TransformIndex as float) float3x3(World[0].XYZ, World[1].XYZ, World[2].XYZ),
            prev;


        // Skinning

        public float model_VertexBoneWeight0:
            req(model_VertexBoneWeights as float4) model_VertexBoneWeights.X,
            req(model_VertexBoneWeights as float3) model_VertexBoneWeights.X,
            req(model_VertexBoneWeights as float2) model_VertexBoneWeights.X,
            req(model_VertexBoneWeights as float) model_VertexBoneWeights,
            req(model_VertexBoneWeight as float) model_VertexBoneWeight;

        public float model_VertexBoneWeight1:
            req(model_VertexBoneWeights as float4) model_VertexBoneWeights.Y,
            req(model_VertexBoneWeights as float3) model_VertexBoneWeights.Y,
            req(model_VertexBoneWeights as float2) model_VertexBoneWeights.Y;

        public float model_VertexBoneWeight2:
            req(model_VertexBoneWeights as float4) model_VertexBoneWeights.Z,
            req(model_VertexBoneWeights as float3) model_VertexBoneWeights.Z;

        public float model_VertexBoneWeight3:
            req(model_VertexBoneWeights as float4) model_VertexBoneWeights.W;

        public float4x4 model_VertexBone0:
            req(model_VertexBoneIndices as float4, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.X],
            req(model_VertexBoneIndices as float3, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.X],
            req(model_VertexBoneIndices as float2, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.X],
            req(model_VertexBoneIndices as float, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices],
            req(model_VertexBoneIndex as float, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndex];

        public float4x4 model_VertexBone1:
            req(model_VertexBoneIndices as float4, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.Y],
            req(model_VertexBoneIndices as float3, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.Y],
            req(model_VertexBoneIndices as float2, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.Y];

        public float4x4 model_VertexBone2:
            req(model_VertexBoneIndices as float4, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.Z],
            req(model_VertexBoneIndices as float3, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.Z];

        public float4x4 model_VertexBone3:
            req(model_VertexBoneIndices as float4, model_BoneList as fixed float4x4[]) model_BoneList[(int)model_VertexBoneIndices.W];

        public float3x3 model_VertexBone0_3x3:
            float3x3(model_VertexBone0[0].XYZ, model_VertexBone0[1].XYZ, model_VertexBone0[2].XYZ);

        public float3x3 model_VertexBone1_3x3:
            float3x3(model_VertexBone1[0].XYZ, model_VertexBone1[1].XYZ, model_VertexBone1[2].XYZ);

        public float3x3 model_VertexBone2_3x3:
            float3x3(model_VertexBone2[0].XYZ, model_VertexBone2[1].XYZ, model_VertexBone2[2].XYZ);

        public float3x3 model_VertexBone3_3x3:
            float3x3(model_VertexBone3[0].XYZ, model_VertexBone3[1].XYZ, model_VertexBone3[2].XYZ);

        VertexPosition:
            TransformAffine(prev, model_VertexBone0) * model_VertexBoneWeight0 + TransformAffine(prev, model_VertexBone1) * model_VertexBoneWeight1 + TransformAffine(prev, model_VertexBone2) * model_VertexBoneWeight2 + TransformAffine(prev, model_VertexBone3) * model_VertexBoneWeight3,
            TransformAffine(prev, model_VertexBone0) * model_VertexBoneWeight0 + TransformAffine(prev, model_VertexBone1) * model_VertexBoneWeight1 + TransformAffine(prev, model_VertexBone2) * model_VertexBoneWeight2,
            TransformAffine(prev, model_VertexBone0) * model_VertexBoneWeight0 + TransformAffine(prev, model_VertexBone1) * model_VertexBoneWeight1,
            TransformAffine(prev, model_VertexBone0) * model_VertexBoneWeight0,
            prev;

        VertexNormal:
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2 + Transform(prev, model_VertexBone3_3x3) * model_VertexBoneWeight3,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0,
            prev;

        VertexTangent:
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2 + Transform(prev, model_VertexBone3_3x3) * model_VertexBoneWeight3,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0,
            prev;

        VertexBinormal:
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2 + Transform(prev, model_VertexBone3_3x3) * model_VertexBoneWeight3,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1 + Transform(prev, model_VertexBone2_3x3) * model_VertexBoneWeight2,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0 + Transform(prev, model_VertexBone1_3x3) * model_VertexBoneWeight1,
            Transform(prev, model_VertexBone0_3x3) * model_VertexBoneWeight0,
            prev;
    }
}
