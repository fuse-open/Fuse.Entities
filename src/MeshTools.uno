using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content.Models;

namespace Fuse.Drawing.Meshes
{
	public static class MeshTools
	{
		public static ModelMesh CalculateNormals(ModelMesh mesh)
		{
			var positions = mesh.Positions;
			var indices = mesh.Indices;

			var normals = new float3[positions.Count];

			for (int i = 0; i < indices.Count; i += 3)
			{
				var i0 = indices.GetInt(i + 0);
				var i1 = indices.GetInt(i + 1);
				var i2 = indices.GetInt(i + 2);

				var p0 = positions.GetFloat4(i0).XYZ;
				var p1 = positions.GetFloat4(i1).XYZ;
				var p2 = positions.GetFloat4(i2).XYZ;

				var v0 = p0 - p1;
				var v1 = p2 - p1;
				var v2 = Vector.Cross(v0, v1);

				normals[i0] += v2;
				normals[i1] += v2;
				normals[i2] += v2;
			}

			for (int i = 0; i < positions.Count; i++)
				normals[i] = Vector.Normalize(normals[i]);

			var dict = new Dictionary<string, VertexAttributeArray>();
			foreach (var v in mesh.VertexAttributes)
				dict[v.Key] = v.Value;

			dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);

			return new ModelMesh(mesh.Name, mesh.PrimitiveType, dict, mesh.Indices);
		}

		public static ModelMesh CalculateTangentsAndBinormals(ModelMesh m)
		{
			var positions = m.Positions;
			var normals = m.Normals;
			var texcoords = m.TexCoords;
			var indices = m.Indices;

			var indexCount = indices.Count;
			var vertexCount = positions.Count;

			var tan1 = new float3[vertexCount];
			var tan2 = new float3[vertexCount];

			var tangents = new float3[vertexCount];
			var binormals = new float3[vertexCount];

			for (int i = 0; i < indexCount; i += 3)
			{
				var i1 = indices.GetInt(i+0);
				var i2 = indices.GetInt(i+1);
				var i3 = indices.GetInt(i+2);

				var v1 = positions.GetFloat4(i1).XYZ;
				var v2 = positions.GetFloat4(i2).XYZ;
				var v3 = positions.GetFloat4(i3).XYZ;

				var w1 = texcoords.GetFloat4(i1).XY;
				var w2 = texcoords.GetFloat4(i2).XY;
				var w3 = texcoords.GetFloat4(i3).XY;

				var x1 = v2.X - v1.X;
				var x2 = v3.X - v1.Y;
				var y1 = v2.Y - v1.Y;
				var y2 = v3.Y - v1.Y;
				var z1 = v2.Z - v1.Z;
				var z2 = v3.Z - v1.Z;

				var s1 = w2.X - w1.X;
				var s2 = w3.X - w1.X;
				var t1 = w2.Y - w1.Y;
				var t2 = w3.Y - w1.Y;

				var r = 1.0f / (s1 * t2 - s2 * t1);

				var sdir = float3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r);
				var tdir = float3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r);

				tan1[i1] += sdir;
				tan1[i2] += sdir;
				tan1[i3] += sdir;

				tan2[i1] += tdir;
				tan2[i2] += tdir;
				tan2[i3] += tdir;
			}

			for (int a = 0; a < vertexCount; ++a)
			{
				var n = normals.GetFloat4(a).XYZ;
				var t = tan1[a];

				tangents[a] = Vector.Normalize(t - n * Vector.Dot(n, t));

				var handedndess = Vector.Dot(Vector.Cross(n, t), tan2[a]) < 0.0f ? -1.0f : 1.0f;

				binormals[a] = Vector.Cross(tangents[a], n) * handedndess;
			}

			var dict = new Dictionary<string, VertexAttributeArray>();
			foreach (var v in m.VertexAttributes)
			dict[v.Key] = v.Value;

			dict[VertexAttributeSemantic.Tangent] = new VertexAttributeArray(tangents);
			dict[VertexAttributeSemantic.Binormal] = new VertexAttributeArray(binormals);

			return new ModelMesh(m.Name, m.PrimitiveType, dict, m.Indices);
		}
	}
}
