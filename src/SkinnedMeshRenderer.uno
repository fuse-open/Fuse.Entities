using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse.Entities;
using Uno.UX;
using Uno.Content;
using Uno.Content.Models;
using Uno.Vector;

namespace Fuse.Entities
{
	class Skinner
	{
		public float4x4[] BoneListData = new float4x4[50];

		public fixed float4x4 model_BoneList[50] : fixed []
		{
			BoneListData[0],
			BoneListData[1],
			BoneListData[2],
			BoneListData[3],
			BoneListData[4],
			BoneListData[5],
			BoneListData[6],
			BoneListData[7],
			BoneListData[8],
			BoneListData[9],
			BoneListData[10],
			BoneListData[11],
			BoneListData[12],
			BoneListData[13],
			BoneListData[14],
			BoneListData[15],
			BoneListData[16],
			BoneListData[17],
			BoneListData[18],
			BoneListData[19],
			BoneListData[20],
			BoneListData[21],
			BoneListData[22],
			BoneListData[23],
			BoneListData[24],
			BoneListData[25],
			BoneListData[26],
			BoneListData[27],
			BoneListData[28],
			BoneListData[29],
			BoneListData[30],
			BoneListData[31],
			BoneListData[32],
			BoneListData[33],
			BoneListData[34],
			BoneListData[35],
			BoneListData[36],
			BoneListData[37],
			BoneListData[38],
			BoneListData[39],
			BoneListData[40],
			BoneListData[41],
			BoneListData[42],
			BoneListData[43],
			BoneListData[44],
			BoneListData[45],
			BoneListData[46],
			BoneListData[47],
			BoneListData[48],
			BoneListData[49],
		};

		public float4 model_VertexBoneWeights : req(BoneWeights as float4) BoneWeights;

		public float model_VertexBoneWeight0 : model_VertexBoneWeights.X;
		public float model_VertexBoneWeight1 : model_VertexBoneWeights.Y;
		public float model_VertexBoneWeight2 : model_VertexBoneWeights.Z;
		public float model_VertexBoneWeight3 : model_VertexBoneWeights.W;

		public float4 model_VertexBoneIndices : req(BoneIndices as float4) BoneIndices;
		public float4x4 model_VertexBone0 : model_BoneList[(int)model_VertexBoneIndices.X];
		public float4x4 model_VertexBone1 : model_BoneList[(int)model_VertexBoneIndices.Y];
		public float4x4 model_VertexBone2 : model_BoneList[(int)model_VertexBoneIndices.Z];
		public float4x4 model_VertexBone3 : model_BoneList[(int)model_VertexBoneIndices.W];

		public float3x3 model_VertexBone0_3x3 : float3x3(model_VertexBone0[0].XYZ, model_VertexBone0[1].XYZ, model_VertexBone0[2].XYZ);
		public float3x3 model_VertexBone1_3x3 : float3x3(model_VertexBone1[0].XYZ, model_VertexBone1[1].XYZ, model_VertexBone1[2].XYZ);
		public float3x3 model_VertexBone2_3x3 : float3x3(model_VertexBone2[0].XYZ, model_VertexBone2[1].XYZ, model_VertexBone2[2].XYZ);
		public float3x3 model_VertexBone3_3x3 : float3x3(model_VertexBone3[0].XYZ, model_VertexBone3[1].XYZ, model_VertexBone3[2].XYZ);

		public float3 SkinnedVertexPosition : req (VertexPosition as float3)
			Transform(VertexPosition, model_VertexBone0).XYZ * model_VertexBoneWeight0
			+ Transform(VertexPosition, model_VertexBone1).XYZ * model_VertexBoneWeight1
			+ Transform(VertexPosition, model_VertexBone2).XYZ * model_VertexBoneWeight2
			+ Transform(VertexPosition, model_VertexBone3).XYZ * model_VertexBoneWeight3;

		public float3 SkinnedVertexNormal : req (VertexNormal as float3)
			Transform(VertexNormal, model_VertexBone0_3x3).XYZ * model_VertexBoneWeight0
			+ Transform(VertexNormal, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1
			+ Transform(VertexNormal, model_VertexBone2_3x3).XYZ * model_VertexBoneWeight2
			+ Transform(VertexNormal, model_VertexBone3_3x3).XYZ * model_VertexBoneWeight3;

		public float3 SkinnedVertexTangent : req (VertexTangent as float3)
			Transform(VertexTangent, model_VertexBone0_3x3).XYZ * model_VertexBoneWeight0
			+ Transform(VertexTangent, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1
			+ Transform(VertexTangent, model_VertexBone2_3x3).XYZ * model_VertexBoneWeight2
			+ Transform(VertexTangent, model_VertexBone3_3x3).XYZ * model_VertexBoneWeight3;

		public float3 SkinnedVertexBinormal : req (VertexBinormal as float3)
			Transform(VertexBinormal, model_VertexBone0_3x3).XYZ * model_VertexBoneWeight0
			+ Transform(VertexBinormal, model_VertexBone1_3x3).XYZ * model_VertexBoneWeight1
			+ Transform(VertexBinormal, model_VertexBone2_3x3).XYZ * model_VertexBoneWeight2
			+ Transform(VertexBinormal, model_VertexBone3_3x3).XYZ * model_VertexBoneWeight3;
	}

	class SkinnedMeshRenderer : MeshRenderer
	{
		readonly List<Entity> _bones = new List<Entity>();
		public List<Entity> Bones { get { return _bones; } }

		Skinner _assDir = new Skinner();
		apply _assDir;

		Mesh _lastMesh = null;
		float4x4 world;

		/*
		protected override void OnDraw(DrawContext dc)
		{
			if (Mesh != _lastMesh)
			{
				ProcessSkin();
				_lastMesh = Mesh;
			}

			VertexAttributeArray originalPositions;
			UpdateTransformList();

			var material = this.Material;
			world = Transform.Absolute;

			foreach (var batch in Mesh.Batches)
			{
				draw this, virtual material, batch, dc,
				{
					float4x4 World : world;
					//PixelColor : req(SkinnedVertexPosition as float3) float4(SkinnedVertexPosition,1);
				},
				virtual dc.Pass;
			}
		}

		void ProcessSkin()
		{
			//Mesh.Drawable.ProcessSkin();
			//Mesh.Invalidate();
		}

		void UpdateTransformList()
		{
			for (int i = 0; i<_bones.Count && i < _assDir.BoneListData.Length; i++)
				_assDir.BoneListData[i] = _bones[i].Transform.Absolute;
		}*/

		public void UpdateMesh()
		{
			//if (Mesh )
			/*
			if (Mesh == null) return;
			var modelMesh = Mesh.ModelMesh;
			var modelMesh = Mesh.Drawable.Mesh;
			if (modelMesh == null) return;

			var skinDrawable = Mesh.Drawable as SkinDrawable;
			if (skinDrawable == null) return;

			var indices = modelMesh.Indices;

			if (originalPositions == null)
				originalPositions = modelMesh.Positions;

			var positions = modelMesh.Positions;
			if (positions == null) return;

			var boneWeightsArray = modelMesh.BoneWeights;
			if (boneWeightsArray == null)
				return;
				//throw new Exception("no bone weights in model");
			var boneIndicesArray = modelMesh.BoneIndices;

			var useIndices = modelMesh.IndexCount != -1;

			var count = useIndices
				? modelMesh.IndexCount
				: modelMesh.VertexCount;

			var newPositions = new float3[originalPositions.Length];
			var newPositions = new float3[modelMesh.VertexCount];

			for (int i = 0; i < count; i++)

			for (int index = 0; index < modelMesh.VertexCount; index++)
			{
				int index = useIndices ? indices.GetInt(i) : i;

				var boneWeights = boneWeightsArray.GetFloat4(index);
				var boneIndices = boneIndicesArray.GetByte4(index);
				var vi = skinDrawable.VertexInfluences[index];

				var position = originalPositions.GetFloat4(index).XYZ;

				var matX = GetBone(boneIndices.X);
				var matY = GetBone(boneIndices.Y);
				var matZ = GetBone(boneIndices.Z);
				var matW = GetBone(boneIndices.W);

				var pX = Vector.TransformCoordinate(position, matX);
				var pY = Vector.TransformCoordinate(position, matY);
				var pZ = Vector.TransformCoordinate(position, matZ);
				var pW = Vector.TransformCoordinate(position, matW);
				newPositions[index] =
					pX * boneWeights.X
					+ pY * boneWeights.Y
					+ pZ * boneWeights.Z
					+ pW * boneWeights.W;
				var newPosition = float3(0);
				// position * Math.Sin((float)Uno.Application.FrameTime);
				var weightSum = 0.0f;
				for (int b = 0; b<vi.BoneIndices.Length; b++)
				{
					var boneIndex = vi.BoneIndices[b];
					var weight = 1.0f / vi.BoneIndices.Length; // vi.BoneWeights[b];
					var mat = GetBone(boneIndex);
					newPosition += Vector.TransformCoordinate(position, mat) * weight;
					weightSum += weight;
				}
				newPosition /= weightSum;
				newPositions[index] = newPosition;
			}

			modelMesh.Positions = new Uno.Content.Models.VertexAttributeArray(newPositions);


			Mesh.Invalidate();
			*/
		}

		float4x4 GetBone(int index)
		{
			if (index < 0 || index >= _bones.Count)
				return float4x4.Identity;
			return _bones[index].WorldTransform;
		}

	}


/*
	public class SkinnedMeshRenderer : MeshRenderer
	{
		readonly List<Transform> _bones = new List<Transform>();
		public List<Transform> Bones { get { return _bones; } }


		VertexAttributeArray originalPositions;

		public void Update()
		{
			if (Mesh == null) return;
			var modelMesh = Mesh.ModelMesh;
			if (modelMesh == null) return;

			var indices = modelMesh.Indices;

			if (originalPositions == null)
				originalPositions = modelMesh.Positions;

			var positions = modelMesh.Positions;
			if (positions == null) return;

			var boneWeightsArray = modelMesh.BoneWeights;
			if (boneWeightsArray == null)
				return;
				//throw new Exception("no bone weights in model");
			var boneIndicesArray = modelMesh.BoneIndices;

			var useIndices = modelMesh.IndexCount != -1;

			var count = useIndices
				? modelMesh.IndexCount
				: modelMesh.VertexCount;

			var newPositions = new float3[originalPositions.Length];

			for (int i = 0; i < count; i++)
			{
				int index = useIndices ? indices.GetInt(i) : i;

				var boneWeights = boneWeightsArray.GetFloat4(index);
				var boneIndices = boneIndicesArray.GetByte4(index);
				var position = originalPositions.GetFloat4(index).XYZ;

				var matX = GetBone(boneIndices.X);
				var matY = GetBone(boneIndices.Y);
				var matZ = GetBone(boneIndices.Z);
				var matW = GetBone(boneIndices.W);

				var pX = Vector.TransformCoordinate(position, matX);
				var pY = Vector.TransformCoordinate(position, matY);
				var pZ = Vector.TransformCoordinate(position, matZ);
				var pW = Vector.TransformCoordinate(position, matW);
				newPositions[index] =
					pX * boneWeights.X
					+ pY * boneWeights.Y
					+ pZ * boneWeights.Z
					+ pW * boneWeights.W;
			}

			modelMesh.Positions = new Uno.Content.Models.VertexAttributeArray(newPositions);

			Mesh.Invalidate();
		}


		float4x4 world;
		protected override void OnDraw(DrawContext dc)
		{
			var material = this.Material;
			world = Transform != null ? Transform.Absolute : float4x4.Identity;
			foreach (var b in Mesh.Batches)
			{
				draw this, virtual material, b, dc, { float4x4 World: world; }, virtual dc.Pass;
			}
		}


		float4x4 GetBone(int index)
		{
			if (index < 0 || index >= _bones.Count)
				return float4x4.Identity;
			return _bones[index].Absolute;
		}

	}
*/
}
