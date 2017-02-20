using Uno;
using Uno.Graphics;
using Uno.Content.Models;

namespace Fuse.Drawing.Batching
{
	public static class BatchHelpers
	{
		public static Batch CreateSingleBatch(ModelMesh m)
		{
			Batch b;

			if (m.Indices != null)
			{
				b = new Batch(m.VertexCount, m.IndexCount, true);
				b.Indices = CreateBatchIndexBuffer(m.Indices);
			}
			else
			{
				b = new Batch(m.VertexCount, m.VertexCount, true);

				for (int i = 0; i < m.VertexCount; i++)
					b.Indices.Write((ushort)i);
			}

			foreach (var v in m.VertexAttributes)
			{
				if (v.Key == VertexAttributeSemantic.Position) b.Positions = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord) b.TexCoord0s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord1) b.TexCoord1s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord2) b.TexCoord2s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord3) b.TexCoord3s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord4) b.TexCoord4s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord5) b.TexCoord5s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord6) b.TexCoord6s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TexCoord7) b.TexCoord7s = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.Normal) b.Normals = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.Tangent) b.Tangents = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.Binormal) b.Binormals = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.Color) b.Colors = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.TransformIndex) b.InstanceIndices = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.BoneWeights) b.BoneWeightBuffer = CreateBatchVertexBuffer(v.Value);
				else if (v.Key == VertexAttributeSemantic.BoneIndices) b.BoneIndexBuffer = CreateBatchVertexBuffer(v.Value);
			}

			return b;
		}

		public static BatchVertexBuffer CreateBatchVertexBuffer(VertexAttributeArray array)
		{
			switch (array.Type)
			{
				case VertexAttributeType.Float:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				case VertexAttributeType.Float2:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				case VertexAttributeType.Float3:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				case VertexAttributeType.Float4:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				case VertexAttributeType.SByte4:
				case VertexAttributeType.SByte4Normalized:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				case VertexAttributeType.Byte4:
				case VertexAttributeType.Byte4Normalized:
					return new BatchVertexBuffer(array.Type, array.Buffer);

				default:
					throw new Exception("Unsupported vertex attribute type");
			}
		}

		public static BatchIndexBuffer CreateBatchIndexBuffer(IndexArray array)
		{
			switch (array.Type)
			{
				case IndexType.Byte:
					return new BatchIndexBuffer(array.Type, array.Buffer);

				case IndexType.UShort:
					return new BatchIndexBuffer(array.Type, array.Buffer);

				case IndexType.UInt:
					return new BatchIndexBuffer(array.Type, array.Buffer);

				default:
					throw new Exception("Unsupported index type");
			}
		}
	}
}
