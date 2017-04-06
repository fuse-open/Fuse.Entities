using Uno;

namespace Fuse.Entities.Geometry
{
	public struct Plane
	{
		public float3 Normal;
		public float D;

		public float A
		{
			get { return Normal.X; }
			set { Normal.X = value; }
		}

		public float B
		{
			get { return Normal.Y; }
			set { Normal.Y = value; }
		}

		public float C
		{
			get { return Normal.Z; }
			set { Normal.Z = value; }
		}

		public Plane(float a, float b, float c, float d)
		{
			Normal = float3(a, b, c);
			D = d;
		}

		public Plane(float3 normal, float d)
		{
			Normal = normal;
			D = d;
		}

		public Plane(float3 point, float3 normal)
		{
			Normal = normal;
			D = -Vector.Dot(normal, point);
		}

		public Plane(float3 point1, float3 point2, float3 point3)
		{
			float x1 = point2.X - point1.X;
			float y1 = point2.Y - point1.Y;
			float z1 = point2.Z - point1.Z;
			float x2 = point3.X - point1.X;
			float y2 = point3.Y - point1.Y;
			float z2 = point3.Z - point1.Z;
			float yz = (y1 * z2) - (z1 * y2);
			float xz = (z1 * x2) - (x1 * z2);
			float xy = (x1 * y2) - (y1 * x2);
			float invPyth = 1.0f / Math.Sqrt((yz * yz) + (xz * xz) + (xy * xy));

			Normal.X = yz * invPyth;
			Normal.Y = xz * invPyth;
			Normal.Z = xy * invPyth;
			D = -((Normal.X * point1.X) + (Normal.Y * point1.Y) + (Normal.Z * point1.Z));
		}

		public void Normalize()
		{
			float invMagnitude = 1.0f / Math.Sqrt((Normal.X * Normal.X) + (Normal.Y * Normal.Y) + (Normal.Z * Normal.Z));
			Normal.X *= invMagnitude;
			Normal.Y *= invMagnitude;
			Normal.Z *= invMagnitude;
			D *= invMagnitude;
		}

		public static Plane Normalize(Plane plane)
		{
			var result = plane;
			result.Normalize();
			return result;
		}

		public static Plane Transform(Plane plane, float4x4 transform)
		{
			return new Plane(Vector.Transform(float4(-plane.Normal * plane.D, 1.0f), transform).XYZ, Vector.TransformNormal(plane.Normal, Matrix.Transpose(Matrix.Invert(transform))));
		}
	}
}
