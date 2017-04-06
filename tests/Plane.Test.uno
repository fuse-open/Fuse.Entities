using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class PlaneTest
	{
		[Test]
		public void Normalize()
		{
			var plane = new Plane(2,5,3,1);
			var newNormilizedPlane = Plane.Normalize(plane);
			Assert.AreEqual(2/Math.Sqrt(38), newNormilizedPlane.A);
			Assert.AreEqual(5/Math.Sqrt(38), newNormilizedPlane.B);
			Assert.AreEqual(3/Math.Sqrt(38), newNormilizedPlane.C);
			Assert.AreEqual(1/Math.Sqrt(38), newNormilizedPlane.D);

			plane.Normalize();
			Assert.AreEqual(2/Math.Sqrt(38), plane.A);
			Assert.AreEqual(5/Math.Sqrt(38), plane.B);
			Assert.AreEqual(3/Math.Sqrt(38), plane.C);
			Assert.AreEqual(1/Math.Sqrt(38), plane.D);
		}

		[Test]
		//could be applied only for normalized plane
		public void Transform()
		{
			var originalPlane = new Plane(2,5,3,1);
			originalPlane.Normalize();

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

			var rotateTransformMatrix = float4x4(
				1, 0, 0, 0,
				0, (float)Math.Cos(Math.PI / 6), (float)Math.Sin(Math.PI / 6), 0,
				0, (float)-Math.Sin(Math.PI / 6), (float)Math.Cos(Math.PI / 6), 0,
				0, 0, 0, 1);

			var transformedPlane = Plane.Transform(originalPlane, noneTransformMatrix);
			Assert.AreEqual(originalPlane.A, transformedPlane.A);
			Assert.AreEqual(originalPlane.B, transformedPlane.B);
			Assert.AreEqual(originalPlane.C, transformedPlane.C);
			Assert.AreEqual(originalPlane.D, transformedPlane.D);

			transformedPlane = Plane.Transform(originalPlane, moveTransformMatrix);
			Assert.AreEqual(originalPlane.A, transformedPlane.A);
			Assert.AreEqual(originalPlane.B, transformedPlane.B);
			Assert.AreEqual(originalPlane.C, transformedPlane.C);
			Assert.AreEqual(-20/Math.Sqrt(38), transformedPlane.D);

			transformedPlane = Plane.Transform(originalPlane, rotateTransformMatrix);
			Assert.AreEqual(originalPlane.A, transformedPlane.A);
			var newYDirection = (float)Math.Cos(Math.PI/6 + Math.Atan(3.0f/5))*Math.Sqrt(17/19.0f);
			var newZDirection = (float)Math.Sin(Math.PI/6 + Math.Atan(3.0f/5))*Math.Sqrt(17/19.0f);
			Assert.AreEqual(newYDirection, transformedPlane.B);
			Assert.AreEqual(newZDirection, transformedPlane.C);
			Assert.AreEqual(originalPlane.D, transformedPlane.D);
		}
	}
}
