using Uno;

namespace Fuse.Entities.Geometry
{
	public struct Triangle
	{
		public readonly float3 A;
		public readonly float3 B;
		public readonly float3 C;

		public Triangle(float3 a, float3 b, float3 c)
		{
			A = a;
			B = b;
			C = c;
		}

		public float3 NormalNonUnit
		{
			get { return Vector.Cross(B - A, C - A); }
		}

		public float3 Normal
		{
			get { return Vector.Normalize(Vector.Cross(B - A, C - A)); }
		}

		public static Triangle operator * (Triangle a, float3 b)
		{
			return new Triangle(a.A * b, a.B * b, a.C * b);
		}

		public static Triangle operator / (Triangle a, float3 b)
		{
			return new Triangle(a.A / b, a.B / b, a.C / b);
		}

		public static Triangle operator + (Triangle a, float3 b)
		{
			return new Triangle(a.A + b, a.B + b, a.C + b);
		}

		public static Triangle operator - (Triangle a, float3 b)
		{
			return new Triangle(a.A - b, a.B - b, a.C - b);
		}

		public float3 GetBarycentricCoordinatesAt(float3 p)
		{
			var normal = Normal;

			var areaABC = Vector.Dot( normal, Vector.Cross( (B - A), (C - A) )  ) ;
			var areaPBC = Vector.Dot( normal, Vector.Cross( (B - p), (C - p) )  ) ;
			var areaPCA = Vector.Dot( normal, Vector.Cross( (C - p), (A - p) )  ) ;

			var x = areaPBC / areaABC;
			var y = areaPCA / areaABC;

			return float3(x, y, 1.0f - x - y);
		}
	}
}
