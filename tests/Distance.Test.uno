using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class DistanceTest
	{
		[Test]
		public void PointPointSquared()
		{
			Assert.AreEqual(11*11, Distance.PointPointSquared(float3 (0,0,11), float3 (0,0,0)));
			Assert.AreEqual(5*5, Distance.PointPointSquared(float3 (0,0,0), float3 (0,5,0)));
			Assert.AreEqual(3*3, Distance.PointPointSquared(float3 (0,0,0), float3 (3,0,0)));
			Assert.AreEqual(0, Distance.PointPointSquared(float3 (0,0,0), float3 (0,0,0)));
			Assert.AreEqual(6*6*3, Distance.PointPointSquared(float3 (-3,-3,-3), float3 (3,3,3)));
		}

		[Test]
		public void PointPoint()
		{
			Assert.AreEqual(11, Distance.PointPoint(float3 (0,0,11), float3 (0,0,0)));
			Assert.AreEqual(5, Distance.PointPoint(float3 (0,0,0), float3 (0,5,0)));
			Assert.AreEqual(3, Distance.PointPoint(float3 (0,0,0), float3 (3,0,0)));
			Assert.AreEqual(0, Distance.PointPoint(float3 (0,0,0), float3 (0,0,0)));
			Assert.AreEqual(6*Math.Sqrt(3), Distance.PointPoint(float3 (-3,-3,-3), float3 (3,3,3)), 0.0001f);
		}

		[Test]
		public void RayPoint()
		{
			Assert.AreEqual(Math.Sqrt(3), Distance.RayPoint(new Ray(float3 (1,1,1), float3 (0.7f,1,0.3f)), float3 (0,0,0)));
			Assert.AreEqual(5, Distance.RayPoint(new Ray(float3 (0,0,0), float3 (1,1,0)), float3 (5,0,0)));
			Assert.AreEqual(0.7f, Distance.RayPoint(new Ray(float3 (0,0,0), float3 (0,1,0)), float3 (0.7f,0.5f,0)));
			Assert.AreEqual(0, Distance.RayPoint(new Ray(float3 (0,0,0), float3 (0.5f,1,0)), float3 (0,0,0)));
		}

		[Test]
		public void PlanePoint()
		{
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));

			Assert.AreEqual(0, Distance.PlanePoint(plane, float3 (1,1,4)));
			Assert.AreEqual(-5.55f, Distance.PlanePoint(plane, float3 (7,5,-1.55f)));
			Assert.AreEqual(1, Distance.PlanePoint(plane, float3 (100,-100,5)));
		}

		[Test]
		public void BoxPoint()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));

			Assert.AreEqual(0, Distance.BoxPoint(box, float3 (0,0,0)));
			Assert.AreEqual(0, Distance.BoxPoint(box, float3 (1,1,1)));
			Assert.AreEqual(0, Distance.BoxPoint(box, float3 (-3,2,2)));
			Assert.AreEqual(Math.Sqrt(29), Distance.BoxPoint(box, float3 (-7,-5,6)));
		}

		[Test]
		public void BoxBox()
		{
			var box1 = new Box(float3 (-3,-3,-3), float3 (3,3,3));

			Assert.AreEqual(0, Distance.BoxBox(box1, new Box(float3 (-2,-2,-2), float3 (1,1,1))));
			Assert.AreEqual(0, Distance.BoxBox(box1, new Box(float3 (-3,-3,-3), float3 (3,3,3))));
			Assert.AreEqual(0, Distance.BoxBox(box1, new Box(float3 (-2,-2,-2), float3 (4,4,4))));
			Assert.AreEqual(0, Distance.BoxBox(box1, new Box(float3 (3,3,3), float3 (7,8,9))));
			Assert.AreEqual(Math.Sqrt(50), Distance.BoxBox(box1, new Box(float3 (6,7,8), float3 (12,12,12))));
		}

		[Test]
		public void SpherePointSquared()
		{
			var sphere = new Sphere(float3 (3,3,3), 7);

			Assert.AreEqual(0, Distance.SpherePointSquared(sphere, float3 (1,1,1)));
			Assert.AreEqual(0, Distance.SpherePointSquared(sphere, float3 (10,3,3)));
			Assert.AreEqual(49*3-49, Distance.SpherePointSquared(sphere, float3 (10,10,10)));
		}

		[Test]
		public void SpherePoint()
		{
			var sphere = new Sphere(float3 (3,3,3), 7);

			Assert.AreEqual(0, Distance.SpherePoint(sphere, float3 (1,1,1)));
			Assert.AreEqual(0, Distance.SpherePoint(sphere, float3 (10,3,3)));
			Assert.AreEqual(7*Math.Sqrt(3)-7, Distance.SpherePoint(sphere, float3 (10,10,10)));
		}

		[Test]
		public void SphereSphere()
		{
			var sphere1 = new Sphere(float3 (3,3,3), 7);

			Assert.AreEqual(0, Distance.SphereSphere(sphere1, new Sphere(float3 (5,5,5), 2)));
			Assert.AreEqual(0, Distance.SphereSphere(sphere1, new Sphere(float3 (9,9,9), 11)));
			Assert.AreEqual(Math.Sqrt(194) - 10, Distance.SphereSphere(sphere1, new Sphere(float3 (12,11,10), 3)));
		}
	}
}
