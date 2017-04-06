using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content.Models;

using Fuse.Entities.Geometry;

namespace Fuse.Entities
{
	abstract class TriangleMeshIntersecter
	{
		readonly int _count;

		protected TriangleMeshIntersecter(int count)
		{
			_count = count;
		}

		public bool IntersectsRay(Ray objRay, out float outDistance)
		{
			var minDistance = float.MaxValue;
			var hit = false;
			for (int t = 0; t < _count; t++)
			{
				float distance;
				if (Fuse.Entities.Geometry.Collision.RayIntersectsTriangle(objRay, GetTriangle(t), out distance))
				{
					hit = true;
					if (distance < minDistance)
						minDistance = distance;
				}
			}
			outDistance = minDistance;
			return hit;
		}

		protected abstract Triangle GetTriangle(int index);
	}

	class DirectArrayMeshIntersecter : TriangleMeshIntersecter
	{
		readonly float3[] _positions;

		public DirectArrayMeshIntersecter(float3[] positions)
			: base(positions.Length / 3)
		{
			if (positions == null) throw new Exception("positions can not be null");

			_positions = positions;
		}

		protected override Triangle GetTriangle(int t)
		{
			var i = t * 3;
			return new Triangle(
				_positions[i + 0],
				_positions[i + 1],
				_positions[i + 2]);
		}
	}

	class IndexedArrayMeshIntersecter : TriangleMeshIntersecter
	{
		readonly int[] _indices;
		readonly float3[] _positions;

		public IndexedArrayMeshIntersecter(float3[] positions, int[] indices)
			: base(indices.Length / 3)
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
				_positions[_indices[i + 0]],
				_positions[_indices[i + 1]],
				_positions[_indices[i + 2]]);
		}
	}
}
