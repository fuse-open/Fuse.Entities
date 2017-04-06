using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content.Models;

using Fuse.Entities.Geometry;

namespace Fuse.Entities
{
	internal static class ModelMeshHelpers
	{
		public static Box CalculateAABB(ModelMesh modelMesh)
		{
			var positions = modelMesh.Positions;
			var min = float3(float.MaxValue, float.MaxValue, float.MaxValue);
			var max = float3(float.MinValue, float.MinValue, float.MinValue);
			for (int v = 0; v < modelMesh.VertexCount; v++)
			{
				var p = positions.GetFloat4(v).XYZ;
				min = float3(Math.Min(min.X, p.X), Math.Min(min.Y, p.Y), Math.Min(min.Z, p.Z));
				max = float3(Math.Max(max.X, p.X), Math.Max(max.Y, p.Y), Math.Max(max.Z, p.Z));
			}
			return new Box(min, max);
		}

		public static Sphere CalculateBoundingSphere(ModelMesh modelMesh)
		{
			// Naive implementation for now
			var positions = modelMesh.Positions;
			var center = float3(0,0,0);
			var radius = 0.0f;
			for (int v = 0; v < modelMesh.VertexCount; v++)
			{
				var p = positions.GetFloat4(v).XYZ;
				var dist = Vector.Distance(p, center);

				radius = Math.Max(dist, radius);
			}

			return new Sphere(center, radius);
		}
	}
}
