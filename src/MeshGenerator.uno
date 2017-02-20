
using Uno;
using Uno.Graphics;
using Uno.Collections;
using Uno.Content.Models;

namespace Fuse.Drawing.Meshes
{
	public static class MeshGenerator
	{
		public static ModelMesh CreateCube(float3 pivot, float halfExtent)
		{
			int vertexCount = 4 * 6;
			int indexCount = 6 * 6;

			var vertices = new float3[vertexCount];
			var normals = new float3[vertexCount];
			var tangents = new float4[vertexCount];
			var texCoords = new float2[vertexCount];
			var indices = new ushort[indexCount];

			var pitches = new[] { 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(180.0f), Math.DegreesToRadians(270.0f), 0, 0 };
			var yaws = new[]    { 0, 0, 0, 0, Math.DegreesToRadians(90.0f), Math.DegreesToRadians(-90.0f) };

			for (int i = 0; i < 6; i++)
			{
				int vi = i * 4;
				float4 q = Uno.Quaternion.FromEulerAngle(pitches[i], yaws[i], 0);
				vertices[vi + 0] = pivot + Uno.Vector.Transform(float3(-1, -1, 1), q) * halfExtent;
				vertices[vi + 1] = pivot + Uno.Vector.Transform(float3( 1, -1, 1), q) * halfExtent;
				vertices[vi + 2] = pivot + Uno.Vector.Transform(float3( 1,  1, 1), q) * halfExtent;
				vertices[vi + 3] = pivot + Uno.Vector.Transform(float3(-1,  1, 1), q) * halfExtent;

				float3 n = Uno.Vector.Transform(float3(0, 0, 1), q);
				normals[vi + 0] = n;
				normals[vi + 1] = n;
				normals[vi + 2] = n;
				normals[vi + 3] = n;

				var t = float4(Uno.Vector.Transform(float3(1,0,0), q), 1);
				tangents[vi + 0] = t;
				tangents[vi + 1] = t;
				tangents[vi + 2] = t;
				tangents[vi + 3] = t;

				texCoords[vi + 0] = float2(0, 0);
				texCoords[vi + 1] = float2(1, 0);
				texCoords[vi + 2] = float2(1, 1);
				texCoords[vi + 3] = float2(0, 1);

				int ii = i * 6;
				indices[ii + 0] = (ushort)vi;
				indices[ii + 1] = (ushort)(vi + 1);
				indices[ii + 2] = (ushort)(vi + 2);
				indices[ii + 3] = (ushort)(vi + 2);
				indices[ii + 4] = (ushort)(vi + 3);
				indices[ii + 5] = (ushort)vi;
			}

			var dict = new Dictionary<string, VertexAttributeArray>();
			dict[VertexAttributeSemantic.Position] = new VertexAttributeArray(vertices);
			dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);
			dict[VertexAttributeSemantic.Tangent] = new VertexAttributeArray(tangents);
			dict[VertexAttributeSemantic.TexCoord] = new VertexAttributeArray(texCoords);
			return new ModelMesh("Cube", PrimitiveType.Triangles, dict, new IndexArray(indices));
		}

		public static ModelMesh CreateSphere(float3 pivot, float radius, int slices, int stacks)
		{
			int horizontalVertexCount = slices + 1;
			int verticalVertexCount = stacks + 1;

			int bodyVertexCount = horizontalVertexCount * verticalVertexCount;
			int bodyIndexCount = slices * stacks * 6;

			int vertexCount = bodyVertexCount;
			int indexCount = bodyIndexCount;

			var vertices = new float3[vertexCount];
			var normals = new float3[vertexCount];
			var texCoords = new float2[vertexCount];
			var indices = new ushort[indexCount];

			for (int j = 0; j < verticalVertexCount; j++)
			{
				for (int i = 0; i < horizontalVertexCount; ++i)
				{
					int k = i + j * horizontalVertexCount;

					float u = (float)i / (float)slices;
					float v = (float)j / (float)stacks;

					texCoords[k] = float2(u, 1.f - v);

					u *= 2.f * Math.PIf;
					v = v * Math.PIf - Math.PIf * .5f;

					vertices[k] = pivot + float3(Math.Cos(v) * Math.Cos(u) * radius, Math.Cos(v) * Math.Sin(u) * radius, Math.Sin(v) * radius);
					normals[k] = float3(Math.Cos(v) * Math.Cos(u), Math.Cos(v) * Math.Sin(u), Math.Sin(v));
				}
			}

			for (int i = 0; i < slices; ++i)
			{
				for (int j = 0; j < stacks; ++j)
				{
					int k = (i + j * slices) * 6;

					indices[k + 0] = (ushort)((i + j * horizontalVertexCount) + 0);
					indices[k + 1] = (ushort)((i + j * horizontalVertexCount) + 1);
					indices[k + 2] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);

					indices[k + 3] = (ushort)((i + j * horizontalVertexCount) + 1);
					indices[k + 4] = (ushort)((i + (j + 1) * horizontalVertexCount) + 1);
					indices[k + 5] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
				}
			}

			var dict = new Dictionary<string, VertexAttributeArray>();
			dict[VertexAttributeSemantic.Position] = new VertexAttributeArray(vertices);
			dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);
			dict[VertexAttributeSemantic.TexCoord] = new VertexAttributeArray(texCoords);

			var sphere = new ModelMesh("Sphere", PrimitiveType.Triangles, dict, new IndexArray(indices));

			return MeshTools.CalculateTangentsAndBinormals(sphere);
		}

		public static ModelMesh CreateCylinder(float height, float radius, int horizontalTessellation, int verticalTessellation)
		{
			int horizontalVertexCount = horizontalTessellation + 1;
			int verticalVertexCount = verticalTessellation + 1;

			int bodyVertexCount = horizontalVertexCount * verticalVertexCount;
			int bodyIndexCount = horizontalTessellation * verticalTessellation * 6;

			int capVertexCount = horizontalVertexCount + 1;
			int capIndexCount = horizontalVertexCount * 3;

			int vertexCount = bodyVertexCount + (capVertexCount << 1);
			int indexCount = bodyIndexCount + (capIndexCount << 1);

			float halfLength = height * .5f;

			var vertices = new float3[vertexCount];
			var normals = new float3[vertexCount];
			var texCoords = new float2[vertexCount];
			var indices = new ushort[indexCount];

			for (int j = 0; j < verticalVertexCount; j++)
			{
				float v = (float)j / (float)verticalTessellation;

				for (int i = 0; i < horizontalVertexCount; ++i)
				{
					int k = i + j * horizontalVertexCount;
					float u = (float)i / (float)horizontalTessellation;

					texCoords[k] = float2(u, v);

					u *= 2.f * Math.PIf;

					vertices[k] = float3(Math.Cos(u) * radius, -halfLength + v * height, Math.Sin(u) * radius);
					normals[k] = float3(Math.Cos(u), 0.f, Math.Sin(u));
				}
			}

			for (int i = 0; i < horizontalTessellation; ++i)
			{
				for (int j = 0; j < verticalTessellation; ++j)
				{
					int k = (i + j * horizontalTessellation) * 6;

					indices[k + 0] = (ushort)((i + j * horizontalVertexCount) + 0);
					indices[k + 1] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
					indices[k + 2] = (ushort)((i + j * horizontalVertexCount) + 1);

					indices[k + 3] = (ushort)((i + j * horizontalVertexCount) + 1);
					indices[k + 4] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
					indices[k + 5] = (ushort)((i + (j + 1) * horizontalVertexCount) + 1);
				}
			}

			vertices[bodyVertexCount] = float3(0.f, -halfLength, 0.f);
			normals[bodyVertexCount] = float3(0.f, -1.f, 0.f);
			texCoords[bodyVertexCount] = float2(.5f, .5f);

			vertices[bodyVertexCount + 1] = float3(0.f, halfLength, 0.f);
			normals[bodyVertexCount + 1] = float3(0.f, 1.f, 0.f);
			texCoords[bodyVertexCount + 1] = float2(.5f, .5f);

			for (int i = 0; i < horizontalVertexCount; i++)
			{
				float u = (float)i / (float)horizontalTessellation;
				u *= 2.f * Math.PIf;

				vertices[bodyVertexCount + 2 + i] = float3(Math.Cos(u) * radius, -halfLength, Math.Sin(u) * radius);
				normals[bodyVertexCount + 2 + i] = float3(0.f, -1.f, 0.f);
				texCoords[bodyVertexCount + 2 + i] = float2(.5f + .5f * Math.Cos(u), .5f + .5f * Math.Sin(u));

				vertices[bodyVertexCount + 2 + horizontalVertexCount + i] = float3(Math.Cos(u) * radius, halfLength, Math.Sin(u) * radius);
				normals[bodyVertexCount + 2 + horizontalVertexCount + i] = float3(0.f, 1.f, 0.f);
				texCoords[bodyVertexCount + 2 + horizontalVertexCount + i] = float2(.5f + .5f * Math.Cos(u), .5f + .5f * Math.Sin(u));
			}

			int n = 0;
			int topi = bodyIndexCount;
			int bottomi = bodyIndexCount + capIndexCount;
			int topv = bodyVertexCount + 2 + horizontalVertexCount;
			int bottomv = bodyVertexCount + 2;
			int topCenter = bodyVertexCount + 1;
			int bottomCenter = bodyVertexCount;

			for (int i = 0; i < capIndexCount; i += 3)
			{
				int left = n;
				int right = n + 1;

				if (right == horizontalVertexCount)
				right = 0;

				indices[topi++] = (ushort)topCenter;
				indices[topi++] = (ushort)(topv + right);
				indices[topi++] = (ushort)(topv + left);

				indices[bottomi++] = (ushort)bottomCenter;
				indices[bottomi++] = (ushort)(bottomv + left);
				indices[bottomi++] = (ushort)(bottomv + right);

				n++;
			}

			var dict = new Dictionary<string, VertexAttributeArray>();
			dict[VertexAttributeSemantic.Position] = new VertexAttributeArray(vertices);
			dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);
			dict[VertexAttributeSemantic.TexCoord] = new VertexAttributeArray(texCoords);
			var cylinder = new ModelMesh("Cylinder", PrimitiveType.Triangles, dict, new IndexArray(indices));
			return MeshTools.CalculateTangentsAndBinormals(cylinder);
		}

		public static ModelMesh CreateCone(float height, float radius, int horizontalTessellation, int verticalTessellation)
		{
			int horizontalVertexCount = horizontalTessellation + 1;
			int verticalVertexCount = verticalTessellation + 1;

			int bodyVertexCount = horizontalVertexCount * verticalVertexCount;
			int bodyIndexCount = horizontalTessellation * verticalTessellation * 6;

			int capVertexCount = horizontalVertexCount + 1;
			int capIndexCount = horizontalVertexCount * 3;

			int vertexCount = bodyVertexCount + (capVertexCount << 1);
			int indexCount = bodyIndexCount + (capIndexCount << 1);

			float halfLength = height * .5f;

			var vertices = new float3[vertexCount];
			var normals = new float3[vertexCount];
			var texCoords = new float2[vertexCount];
			var indices = new ushort[indexCount];

			for (int j = 0; j < verticalVertexCount; j++)
			{
				float v = (float)j / (float)verticalTessellation;

				for (int i = 0; i < horizontalVertexCount; ++i)
				{
					int k = i + j * horizontalVertexCount;
					float u = (float)i / (float)horizontalTessellation;

					texCoords[k] = float2(u, v);

					u *= 2.f * Math.PIf;

					vertices[k] = float3(Math.Cos(u) * radius * (1.f - v), -halfLength + v * height, Math.Sin(u) * radius * (1.f - v));
					normals[k] = float3(Math.Cos(u), 0.f, Math.Sin(u));
				}
			}

			for (int i = 0; i < horizontalTessellation; ++i)
			{
				for (int j = 0; j < verticalTessellation; ++j)
				{
					int k = (i + j * horizontalTessellation) * 6;

					indices[k + 0] = (ushort)((i + j * horizontalVertexCount) + 0);
					indices[k + 1] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
					indices[k + 2] = (ushort)((i + j * horizontalVertexCount) + 1);

					indices[k + 3] = (ushort)((i + j * horizontalVertexCount) + 1);
					indices[k + 4] = (ushort)((i + (j + 1) * horizontalVertexCount) + 0);
					indices[k + 5] = (ushort)((i + (j + 1) * horizontalVertexCount) + 1);
				}
			}

			vertices[bodyVertexCount] = float3(0.f, -halfLength, 0.f);
			normals[bodyVertexCount] = float3(0.f, -1.f, 0.f);
			texCoords[bodyVertexCount] = float2(.5f, .5f);

			for (int i = 0; i < horizontalVertexCount; i++)
			{
				float u = (float)i / (float)horizontalTessellation;
				u *= 2.f * Math.PIf;

				vertices[bodyVertexCount + 2 + i] = float3(Math.Cos(u) * radius, -halfLength, Math.Sin(u) * radius);
				normals[bodyVertexCount + 2 + i] = float3(0.f, -1.f, 0.f);
				texCoords[bodyVertexCount + 2 + i] = float2(.5f + .5f * Math.Cos(u), .5f + .5f * Math.Sin(u));
			}

			int n = 0;
			int bottomi = bodyIndexCount + capIndexCount;
			int bottomv = bodyVertexCount + 2;
			int bottomCenter = bodyVertexCount;

			for (int i = 0; i < capIndexCount; i += 3)
			{
				int left = n;
				int right = n + 1;

				if (right == horizontalVertexCount)
				right = 0;

				indices[bottomi++] = (ushort)bottomCenter;
				indices[bottomi++] = (ushort)(bottomv + left);
				indices[bottomi++] = (ushort)(bottomv + right);

				n++;
			}

			var dict = new Dictionary<string, VertexAttributeArray>();
			dict[VertexAttributeSemantic.Position] = new VertexAttributeArray(vertices);
			dict[VertexAttributeSemantic.Normal] = new VertexAttributeArray(normals);
			dict[VertexAttributeSemantic.TexCoord] = new VertexAttributeArray(texCoords);
			var cone = new ModelMesh("Cone", PrimitiveType.Triangles, dict, new IndexArray(indices));
			return MeshTools.CalculateTangentsAndBinormals(cone);
		}
	}
}
