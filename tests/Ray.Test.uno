using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class RayTest
	{
		[Test]
		public void Normalize()
		{
			var ray = new Ray(float3 (4,5,6), float3 (2,3,4));
			var normilizedRay = Ray.Normalize(ray);
			Assert.AreEqual(float3 (4,5,6), normilizedRay.Position);
			Assert.AreEqual(float3 (2/Math.Sqrt(29),3/Math.Sqrt(29),4/Math.Sqrt(29)), normilizedRay.Direction);

			ray = new Ray(float3 (4,5,6), float3 (1,0,0));
			normilizedRay = Ray.Normalize(ray);
			Assert.AreEqual(float3 (4,5,6), normilizedRay.Position);
			Assert.AreEqual(float3 (1,0,0), normilizedRay.Direction);
		}


		[Test]
		public void Transform()
		{
			var originalRay = new Ray(float3 (4,5,6), float3 (4/5.0f,3/5.0f,0));

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

			var transformedRay = Ray.Transform(originalRay, noneTransformMatrix);
			Assert.AreEqual(float3 (4,5,6), transformedRay.Position);
			Assert.AreEqual(float3 (4/5.0f,3/5.0f,0), transformedRay.Direction);

			transformedRay = Ray.Transform(originalRay, moveTransformMatrix);
			Assert.AreEqual(float3 (5,7,9), transformedRay.Position);
			Assert.AreEqual(float3 (4/5.0f,3/5.0f,0), transformedRay.Direction);

			transformedRay = Ray.Transform(originalRay, scaleTransformMatrix);
			Assert.AreEqual(float3 (16,15,12), transformedRay.Position);
			Assert.AreEqual(float3 (16/Math.Sqrt(337),9/Math.Sqrt(337),0), transformedRay.Direction);

			transformedRay = Ray.Transform(originalRay, rotateTransformMatrix);
			var newYPosition = (float)Math.Cos(Math.PI/6 + Math.Atan(6.0f/5))*Math.Sqrt(61);
			var newZPosition = (float)Math.Sin(Math.PI/6 + Math.Atan(6.0f/5))*Math.Sqrt(61);
			var newYDirection = (float)Math.Cos(Math.PI/6)*3/5;
			var newZDirection = (float)Math.Sin(Math.PI/6)*3/5;

			Assert.AreEqual(float3 (4,newYPosition,newZPosition), transformedRay.Position);
			Assert.AreEqual(float3 (4/5.0f,newYDirection,newZDirection), transformedRay.Direction);
		}
	}
}
