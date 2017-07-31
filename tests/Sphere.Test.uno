using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class SphereTest
	{
		[Test]
		public void Transform()
		{
			var originalSphere = new Sphere(float3 (3,3,3), 15);

			var noneTransformMatrix = float4x4(
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1);

			var moveTransformMatrix = float4x4(
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				1, 2, 3, 1);

			var scaleTransformMatrix = float4x4(
				4, 0, 0, 0,
				0, 3, 0, 0,
				0, 0, 2, 0,
				0, 0, 0, 1);

			var rotateTransformMatrix = float4x4(
				1, 0, 0, 0,
				0, (float)Math.Cos(Math.PI / 6), (float)Math.Sin(Math.PI / 6), 0,
				0, (float)-Math.Sin(Math.PI / 6), (float)Math.Cos(Math.PI / 6), 0,
				0, 0, 0, 1);

			var transformedSphere = Sphere.Transform(originalSphere, noneTransformMatrix);
			Assert.AreEqual(float3 (3,3,3), transformedSphere.Center);
			Assert.AreEqual(15, transformedSphere.Radius);

			transformedSphere = Sphere.Transform(originalSphere, moveTransformMatrix);
			Assert.AreEqual(float3 (4,5,6), transformedSphere.Center);
			Assert.AreEqual(15, transformedSphere.Radius);

			transformedSphere = Sphere.Transform(originalSphere, scaleTransformMatrix);
			Assert.AreEqual(float3 (12,9,6), transformedSphere.Center);
			Assert.AreEqual(60, transformedSphere.Radius);

			transformedSphere = Sphere.Transform(originalSphere, rotateTransformMatrix);
			var newYPosition = (float)Math.Cos(Math.PI/6 + Math.PI/4)*Math.Sqrt(18);
			var newZPosition = (float)Math.Sin(Math.PI/6 + Math.PI/4)*Math.Sqrt(18);

			Assert.AreEqual(float3 (3,newYPosition,newZPosition), transformedSphere.Center);
			Assert.AreEqual(15, transformedSphere.Radius);
		}

		[Test]
		public void CreateAverageBy3Points()
		{
			var sphere = Sphere.CreateAverage(float3 (2,7,8), float3 (3,3,3), float3 (11,8,9));
			var center = float3 (16/3.0f,6,20/3.0f);

			Assert.AreEqual(center, sphere.Center);
			Assert.AreEqual(Distance.PointPoint(center, float3 (11,8,9)), sphere.Radius);
		}

		[Test]
		public void CreateAverageBy4Points()
		{
			var sphere = Sphere.CreateAverage(float3 (2,7,8), float3 (3,3,3), float3 (11,8,9), float3 (5,4,9));
			var center = float3 (21/4.0f,22/4.0f,29/4.0f);

			Assert.AreEqual(center, sphere.Center);
			Assert.AreEqual(Distance.PointPoint(center, float3 (11,8,9)), sphere.Radius);
		}

		[Test]
		public void CreateAverageByPoints()
		{
			var sphere = Sphere.CreateAverage(new float3[] { float3 (1,1,1), float3 (1,1,1)});
			Assert.AreEqual(float3 (1,1,1), sphere.Center);
			Assert.AreEqual(0, sphere.Radius);

			sphere = Sphere.CreateAverage(new float3[] { float3 (1,1,1), float3 (7,9,11)});
			Assert.AreEqual(float3 (4,5,6), sphere.Center);
			Assert.AreEqual(Math.Sqrt(50), sphere.Radius);
		}

		[Test]
		public void CreateAverageBySpheres()
		{
			var sphere1 = new Sphere(float3 (7,-5,4), 10);
			var sphere2 = new Sphere(float3 (11,15,3), 6);
			var sphere3 = new Sphere(float3 (3,-3,-3), 4);

			var averageSphere = Sphere.CreateAverage(new Sphere[] { sphere1, sphere2, sphere3 });
			var center = float3 (7,7/3.0f,4/3.0f);

			Assert.AreEqual(center, averageSphere.Center);
			Assert.AreEqual(Distance.PointPoint(center, float3 (11,15,3)) + 6, averageSphere.Radius);
		}

		[Test]
		public void CreateSphereByBox()
		{
			var sphere = new Sphere(float3 (-3,-3,-3), float3 (5,5,5));
			Assert.AreEqual(float3 (1,1,1), sphere.Center);
			Assert.AreEqual(Distance.PointPoint(float3 (1,1,1), float3 (-3,-3,-3)), sphere.Radius);
		}
	}
}
