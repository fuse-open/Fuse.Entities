using Uno;

namespace Fuse.Entities.Geometry
{
	public static class Distance
	{
		public static float PointPointSquared(float3 point1, float3 point2)
		{
			return Vector.LengthSquared(point2 - point1);
		}

		public static float PointPoint(float3 point1, float3 point2)
		{
			return Vector.Length(point2 - point1);
		}

		public static float RayPoint(Ray ray, float3 point)
		{
			float3 diff = point - ray.Position;
			float mul = Vector.Dot(ray.Direction, diff);
			float3 cp = mul > 0 ? ray.Position + ray.Direction * mul : ray.Position;
			return Vector.Length(cp - point);
		}

		public static float LineSegmentPoint(float3 a, float3 b, float3 p)
		{
			var l2 = Vector.LengthSquared(a-b);
			if (l2 == 0.0) return Vector.Distance(p, a);

			var t = Vector.Dot(p - a, b - a) / l2;
			if (t < 0.0) return Vector.Distance(p, a);
			else if (t > 1.0) return Vector.Distance(p, b);

			var projection = a + t * (b - a);
			return Vector.Distance(p, projection);
		}

		public static float PlanePoint(Plane plane, float3 point)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 127

			float dot = Vector.Dot(plane.Normal, point);
			return dot + plane.D;
		}

		public static float BoxPoint(Box box, float3 point)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 131

			float distance = 0.f;

			if (point.X < box.Minimum.X)
				distance += (box.Minimum.X - point.X) * (box.Minimum.X - point.X);
			if (point.X > box.Maximum.X)
				distance += (point.X - box.Maximum.X) * (point.X - box.Maximum.X);

			if (point.Y < box.Minimum.Y)
				distance += (box.Minimum.Y - point.Y) * (box.Minimum.Y - point.Y);
			if (point.Y > box.Maximum.Y)
				distance += (point.Y - box.Maximum.Y) * (point.Y - box.Maximum.Y);

			if (point.Z < box.Minimum.Z)
				distance += (box.Minimum.Z - point.Z) * (box.Minimum.Z - point.Z);
			if (point.Z > box.Maximum.Z)
				distance += (point.Z - box.Maximum.Z) * (point.Z - box.Maximum.Z);

			return Math.Sqrt(distance);
		}

		public static float BoxBox(Box box1, Box box2)
		{
			float distance = 0.f;

			//Distance for X.
			if (box1.Minimum.X > box2.Maximum.X)
			{
				float delta = box2.Maximum.X - box1.Minimum.X;
				distance += delta * delta;
			}
			else if (box2.Minimum.X > box1.Maximum.X)
			{
				float delta = box1.Maximum.X - box2.Minimum.X;
				distance += delta * delta;
			}

			//Distance for Y.
			if (box1.Minimum.Y > box2.Maximum.Y)
			{
				float delta = box2.Maximum.Y - box1.Minimum.Y;
				distance += delta * delta;
			}
			else if (box2.Minimum.Y > box1.Maximum.Y)
			{
				float delta = box1.Maximum.Y - box2.Minimum.Y;
				distance += delta * delta;
			}

			//Distance for Z.
			if (box1.Minimum.Z > box2.Maximum.Z)
			{
				float delta = box2.Maximum.Z - box1.Minimum.Z;
				distance += delta * delta;
			}
			else if (box2.Minimum.Z > box1.Maximum.Z)
			{
				float delta = box1.Maximum.Z - box2.Minimum.Z;
				distance += delta * delta;
			}

			return Math.Sqrt(distance);
		}

		public static float SpherePointSquared(Sphere sphere, float3 point)
		{
			return Math.Max(0.f, Distance.PointPointSquared(sphere.Center, point) - sphere.Radius * sphere.Radius);
		}

		public static float SpherePoint(Sphere sphere, float3 point)
		{
			return Math.Max(0.f, Distance.PointPoint(sphere.Center, point) - sphere.Radius);
		}

		public static float SphereSphere(Sphere sphere1, Sphere sphere2)
		{
			return Math.Max(0.f, Distance.PointPoint(sphere1.Center, sphere2.Center) - (sphere1.Radius + sphere2.Radius));
		}
	}
}
