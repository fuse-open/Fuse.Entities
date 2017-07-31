using Uno;

namespace Fuse.Entities.Geometry
{
	public struct Frustum
	{
		public Plane Near, Far;
		public Plane Top, Bottom;
		public Plane Left, Right;

		public void Normalize()
		{
			Near.Normalize();
			Far.Normalize();
			Top.Normalize();
			Bottom.Normalize();
			Left.Normalize();
			Right.Normalize();
		}

		public static Frustum Normalize(Frustum frustum)
		{
			var result = frustum;
			result.Normalize();
			return result;
		}

		public static Frustum Transform(Frustum frustum, float4x4 transformUniformScale)
		{
			Frustum result;
			result.Near = TransformPlane(frustum.Near, transformUniformScale);
			result.Far = TransformPlane(frustum.Far, transformUniformScale);
			result.Top = TransformPlane(frustum.Top, transformUniformScale);
			result.Bottom = TransformPlane(frustum.Bottom, transformUniformScale);
			result.Left = TransformPlane(frustum.Left, transformUniformScale);
			result.Right = TransformPlane(frustum.Right, transformUniformScale);
			return result;
		}

		static Plane TransformPlane(Plane plane, float4x4 transformUniformScale)
		{
			return new Plane(Vector.Transform(float4(-plane.Normal * plane.D, 1), transformUniformScale).XYZ, Vector.TransformNormal(plane.Normal, transformUniformScale));
		}
	}
}
