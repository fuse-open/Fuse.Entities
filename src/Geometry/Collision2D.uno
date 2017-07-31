using Uno;

namespace Fuse.Entities.Geometry
{
	public static class Collision2D
	{
		const float _zeroTolerance = 1e-05f;

		//refer to barycentric technique: http://www.blackpawn.com/texts/pointinpoly/default.html
		public static bool TriangleContainsPoint(float2 A, float2 B, float2 C, float2 P)
		{
			var v0 = C - A;
			var v1 = B - A;
			var v2 = P - A;
			var dot00 = Vector.Dot(v0, v0);
			var dot01 = Vector.Dot(v0, v1);
			var dot02 = Vector.Dot(v0, v2);
			var dot11 = Vector.Dot(v1, v1);
			var dot12 = Vector.Dot(v1, v2);
			var denom = dot00 * dot11 - dot01 * dot01;
			if( denom < _zeroTolerance )
				return false;
			var invDenom = 1.0f / denom;
			var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
			var v = (dot00 * dot12 - dot01 * dot02) * invDenom;
			var r = (u >= 0) && (v >= 0) && (u + v < 1);
			return r;
		}

		// from http://www.wyrmtale.com/blog/2013/115/2d-line-intersection-in-c
		public static float2 LineIntersectionPoint(float2 ps1, float2 pe1, float2 ps2, float2 pe2)
		{
			return LineIntersectionPointVector( ps1, pe1 - ps1, ps2, pe2 - ps2 );
		}

		public static float2 LineIntersectionPointVector(float2 ps1, float2 v1, float2 ps2, float2 v2)
		{
			// Get A,B,C of first line - points : ps1 to pe1
			float A1 = v1.Y;
			float B1 = -v1.X;
			float C1 = A1*ps1.X + B1*ps1.Y;

			// Get A,B,C of second line - points : ps2 to pe2
			float A2 = v2.Y;
			float B2 = -v2.X;
			float C2 = A2*ps2.X + B2*ps2.Y;

			// Get delta and check if the lines are parallel
			float delta = A1*B2 - A2*B1;
			if( Math.Abs(delta) < _zeroTolerance )
				return ps1;

			// now return the Vector2 intersection point
			return float2(
				(B2*C1 - B1*C2)/delta,
				(A1*C2 - A2*C1)/delta
			);
		}

		public static bool AreParallel( float2 a, float2 b, float tolerance = _zeroTolerance * 10)
		{
			var l = a.X*b.Y - a.Y*b.X;
			return Math.Abs(l) < tolerance;
		}

		public static float AngleBetween( float2 a, float2 b )
		{
			var d = Vector.Dot( a, b );
			var l = Vector.Length( a ) * Vector.Length( b );
			if( l < _zeroTolerance )
				return 0;
			return Math.Acos( d / l );
		}
	}
}
