using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content.Models;

using Fuse.Entities.Geometry;

namespace Fuse.Entities
{
	internal class ModelMeshCollision
	{
		public static bool RayIntersectsModelMesh(Ray objRay, ModelMesh modelMesh, out float outDistance)
		{
			if (modelMesh == null) throw new Exception("modelMesh can not be null");

			var useIndices = modelMesh.IndexCount > 0;

			return useIndices
				? new Indexed(modelMesh.Positions, modelMesh.Indices, modelMesh.IndexCount).IntersectsRay(objRay, out outDistance)
				: new Direct(modelMesh.Positions, modelMesh.VertexCount).IntersectsRay(objRay, out outDistance);
		}

		class Indexed : TriangleMeshIntersecter
		{
			readonly VertexAttributeArray _positions;
			readonly IndexArray _indices;

			public Indexed(VertexAttributeArray positions, IndexArray indices, int indexCount)
				: base(indexCount / 3)
			{
				if (positions == null) throw new Exception("positions can not be null");
				if (indices == null) throw new Exception("indices can not be null");

				_positions = positions;
				_indices = indices;
			}

			protected override Triangle GetTriangle(int t)
			{
				var i = t * 3;
				return new Triangle(
					_positions.GetFloat4(_indices.GetInt(i + 0)).XYZ,
					_positions.GetFloat4(_indices.GetInt(i + 1)).XYZ,
					_positions.GetFloat4(_indices.GetInt(i + 2)).XYZ);
			}
		}

		class Direct : TriangleMeshIntersecter
		{
			readonly VertexAttributeArray _positions;

			public Direct(VertexAttributeArray positions, int vertexCount)
				: base(vertexCount / 3)
			{
				if (positions == null) throw new Exception("positions can not be null");

				_positions = positions;
			}

			protected override Triangle GetTriangle(int t)
			{
				var i = t * 3;
				return new Triangle(
					_positions.GetFloat4(i + 0).XYZ,
					_positions.GetFloat4(i + 1).XYZ,
					_positions.GetFloat4(i + 2).XYZ);
			}
		}
	}
}
