using Uno;
using Uno.Collections;
using Uno.Collections.EnumerableExtensions;
using Uno.Content.Models;

namespace Fuse.Drawing.Batching
{
	class Entry
	{
		public ModelMesh Mesh;
		public int InstanceIndex;
		public Entry(ModelMesh m, int instanceId) { Mesh = m; InstanceIndex = instanceId; }
	}

	public class MeshBatcher
	{
		List<Entry> entries = new List<Entry>();
		public IEnumerable<ModelMesh> Entries
		{
			get { return Select<Entry, ModelMesh>(entries, Mesh); }
		}
		static ModelMesh Mesh(Entry entry) { return entry.Mesh; }

		public int EntryCount { get { return entries.Count; } }


		Batch[] batches;
		public IEnumerable<Batch> Batches
		{
			get { Flush(); return batches; }
		}

		public int BatchCount { get { return batches.Length; } }


		public MeshBatcher() { }

		public int AddMesh(ModelMesh mesh)
		{
			return AddEntry(new Entry(mesh, entries.Count));
		}

		public void AddMesh(ModelMesh mesh, int instanceId)
		{
			AddEntry(new Entry(mesh, instanceId));
		}

		int AddEntry(Entry e)
		{
			entries.Add(e);
			return e.InstanceIndex;
		}


		public void Flush()
		{
			if (batches != null) return;

			VertexAttributeArray
				position,
				texcoord, texcoord1, texcoord2, texcoord3, texcoord4, texcoord5, texcoord6, texcoord7,
				normal,
				tangent,
				binormal,
				color,
				boneWeights,
				boneIndex;

			var batches = new List<Batch>();
			Batch b = null;

			int virtualIndexBase = 0;
			var virtualIndexToRealIndex = new Dictionary<int, int>();

			int batchVertexCount = 0;
			int batchIndexCount = 0;
			int batchVertexCutoff = 0;
			int batchIndexCutoff = 0;

			for (int e = 0; e < entries.Count; e++)
			{
				var m = entries[e].Mesh;

				position = texcoord = texcoord1 = texcoord2 = texcoord3 = texcoord4 = texcoord5 = texcoord6 = texcoord7 = normal = tangent = binormal = color = boneWeights = boneIndex = null;
				foreach (var v in m.VertexAttributes)
				{
					if (v.Key == VertexAttributeSemantic.Position) position = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord) texcoord = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord1) texcoord1 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord2) texcoord2 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord3) texcoord3 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord4) texcoord4 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord5) texcoord5 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord6) texcoord6 = v.Value;
					else if (v.Key == VertexAttributeSemantic.TexCoord7) texcoord7 = v.Value;
					else if (v.Key == VertexAttributeSemantic.Normal) normal = v.Value;
					else if (v.Key == VertexAttributeSemantic.Tangent) tangent = v.Value;
					else if (v.Key == VertexAttributeSemantic.Binormal) binormal = v.Value;
					else if (v.Key == VertexAttributeSemantic.Color) color = v.Value;
					else if (v.Key == VertexAttributeSemantic.BoneWeights) boneWeights = v.Value;
					else if (v.Key == VertexAttributeSemantic.BoneIndices) boneIndex = v.Value;
				}

				if (m.Indices == null)
				{
					m = CreateFakeIndexBuffer(m);
				}

				for (int i = 0; i < m.IndexCount; i++)
				{
					if (batchVertexCount >= batchVertexCutoff || batchIndexCount >= batchIndexCutoff)
					{
						// TODO: create some heurisitc to esitmate these figures instead of using constants
						batchVertexCutoff = 65535;
						batchIndexCutoff = 100000;

						b = new Batch(batchVertexCutoff, batchIndexCutoff, true);
						batches.Add(b);

						virtualIndexToRealIndex = new Dictionary<int, int>();

						batchVertexCount = 0;
						batchIndexCount = 0;
					}

					int originalIndex = m.Indices.GetInt(i);
					int virtualIndex = virtualIndexBase + originalIndex;

					int newIndex;
					if (!virtualIndexToRealIndex.TryGetValue(virtualIndex, out newIndex))
					{
						newIndex = batchVertexCount;
						virtualIndexToRealIndex.Add(virtualIndex, newIndex);

						// Emit vertex
						if (position != null)
							b.Positions.Write(position.GetFloat4(originalIndex).XYZ);

						if (texcoord != null)
							b.TexCoord0s.Write(texcoord.GetFloat4(originalIndex).XY);

						if (texcoord1 != null)
							b.TexCoord1s.Write(texcoord1.GetFloat4(originalIndex).XY);

						if (texcoord2 != null)
							b.TexCoord2s.Write(texcoord2.GetFloat4(originalIndex).XY);

						if (texcoord3 != null)
							b.TexCoord3s.Write(texcoord3.GetFloat4(originalIndex).XY);

						if (texcoord4 != null)
							b.TexCoord4s.Write(texcoord4.GetFloat4(originalIndex).XY);

						if (texcoord5 != null)
							b.TexCoord5s.Write(texcoord5.GetFloat4(originalIndex).XY);

						if (texcoord6 != null)
							b.TexCoord6s.Write(texcoord6.GetFloat4(originalIndex).XY);

						if (texcoord7 != null)
							b.TexCoord7s.Write(texcoord7.GetFloat4(originalIndex).XY);

						if (normal != null)
							b.Normals.Write(normal.GetFloat4(originalIndex).XYZ);

						if (tangent != null)
							b.Tangents.Write(tangent.GetFloat4(originalIndex));

						if (binormal != null)
							b.Binormals.Write(binormal.GetFloat4(originalIndex).XYZ);

						if (color != null)
							b.Colors.Write(color.GetFloat4(originalIndex));

						if (boneWeights != null)
							b.BoneWeightBuffer.Write(boneWeights.GetByte4Normalized(originalIndex));

						if (boneIndex != null)
							b.BoneIndexBuffer.Write(boneIndex.GetByte4(originalIndex));

						b.InstanceIndices.Write((ushort)entries[e].InstanceIndex);
						batchVertexCount++;
					}

					// Emit index
					b.Indices.Write((ushort)newIndex);
					batchIndexCount++;
				}

				virtualIndexBase += m.VertexCount;
			}

			this.batches = batches.ToArray();
		}


		static ModelMesh CreateFakeIndexBuffer(ModelMesh m)
		{
			var d = new uint[m.VertexCount];
			for (int i = 0; i < d.Length; i++) d[i] = (uint)i;

			var dict = new Dictionary<string, VertexAttributeArray>();
			foreach (var v in m.VertexAttributes)
				dict[v.Key] = v.Value;

			return new ModelMesh(m.Name, m.PrimitiveType, dict, new IndexArray(d));
		}
	}
}
