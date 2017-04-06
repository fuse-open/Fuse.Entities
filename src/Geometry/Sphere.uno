using Uno;

namespace Fuse.Entities.Geometry
{
	public struct Sphere
	{
		public /*readonly*/ float3 Center;
		public /*readonly*/ float Radius;

		public Sphere(float3 center, float radius)
		{
			Center = center;
			Radius = radius;
		}

		public Sphere(float3 a, float3 b)
		{
			float3 v = (b - a) / 2.0f;
			Center = a + v;
			Radius = Vector.Length(v);
		}

		public Sphere(Box box)
		{
			Center = box.Center;
			Radius = Distance.PointPoint(Center, box.Minimum);
		}

		public static Sphere Transform(Sphere sphere, float4x4 transform)
		{
			return new Sphere(Vector.Transform(float4(sphere.Center, 1), transform).XYZ, sphere.Radius * Math.ComponentMax(Math.Abs(Matrix.GetScaling(transform))));
		}

		public static Sphere CreateAverage(float3 a, float3 b, float3 c)
		{
			float3 center = (a + b + c) / 3.0f;
			float radius = Math.Sqrt(Math.Max(Math.Max(Distance.PointPointSquared(center, a), Distance.PointPointSquared(center, b)), Distance.PointPointSquared(center, c)));
			return new Sphere(center, radius);
		}

		public static Sphere CreateAverage(float3 a, float3 b, float3 c, float3 d)
		{
			float3 center = (a + b + c + d) / 4.0f;
			float radius = Math.Sqrt(Math.Max(Math.Max(Math.Max(Distance.PointPointSquared(center, a), Distance.PointPointSquared(center, b)), Distance.PointPointSquared(center, c)), Distance.PointPointSquared(center, d)));
			return new Sphere(center, radius);
		}

		public static Sphere CreateAverage(float3[] P)
		{
			float3 center = float3(0,0,0);
			float radius = 0.0f;

			if (P.Length > 0)
			{
				for (int i = 0; i < P.Length; i++)
				{
					center += P[i];
				}

				center /= (float)P.Length;

				for (int i = 0; i < P.Length; i++)
				{
					radius = Math.Max(radius, Distance.PointPointSquared(P[i], center));
				}

				radius = Math.Sqrt(radius);
			}

			return new Sphere(center, radius);
		}

		public static Sphere CreateAverage(Sphere[] spheres)
		{
			if (spheres.Length == 1) return spheres[0];

			float3 center = float3(0,0,0);
			float radius = 0.0f;

			if (spheres.Length > 0)
			{
				for (int i = 0; i < spheres.Length; i++)
				{
					center += spheres[i].Center;
				}

				center /= (float)spheres.Length;

				for (int i = 0; i < spheres.Length; i++)
				{
					radius = Math.Max(radius, Distance.PointPoint(spheres[i].Center, center) + spheres[i].Radius);
				}
			}

			return new Sphere(center, radius);
		}
	}
}
