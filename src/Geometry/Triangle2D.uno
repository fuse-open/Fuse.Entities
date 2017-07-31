namespace Fuse.Entities.Geometry
{
	public class Triangle2D
	{
		public readonly float2 A;
		public readonly float2 B;
		public readonly float2 C;

		public Triangle2D(float2 a, float2 b, float2 c)
		{
			A = a;
			B = b;
			C = c;
		}
	}
}
