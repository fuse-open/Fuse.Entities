using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class FrustumTest
	{
		[Test]
		public void Normalize()
		{
			var frustum = CreateTestFrustum();
			frustum.Normalize();

			Assert.AreEqual(-1, frustum.Near.A);
			Assert.AreEqual(0, frustum.Near.B);
			Assert.AreEqual(0, frustum.Near.C);
			Assert.AreEqual(5, frustum.Near.D);

			Assert.AreEqual(-1/Math.Sqrt(5), frustum.Top.A);
			Assert.AreEqual(0, frustum.Top.B);
			Assert.AreEqual(2/Math.Sqrt(5), frustum.Top.C);
			Assert.AreEqual(0, frustum.Top.D);
		}

		[Test]
		public void Transform()
		{
			var originalFrustum = CreateTestFrustum();
			originalFrustum.Normalize();

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

			var transformedFrustum = Frustum.Transform(originalFrustum, noneTransformMatrix);
			Assert.AreEqual(originalFrustum.Near.A, transformedFrustum.Near.A);
			Assert.AreEqual(originalFrustum.Near.B, transformedFrustum.Near.B);
			Assert.AreEqual(originalFrustum.Near.C, transformedFrustum.Near.C);
			Assert.AreEqual(originalFrustum.Near.D, transformedFrustum.Near.D);

			Assert.AreEqual(originalFrustum.Top.A, transformedFrustum.Top.A);
			Assert.AreEqual(originalFrustum.Top.B, transformedFrustum.Top.B);
			Assert.AreEqual(originalFrustum.Top.C, transformedFrustum.Top.C);
			Assert.AreEqual(originalFrustum.Top.D, transformedFrustum.Top.D);

			transformedFrustum = Frustum.Transform(originalFrustum, moveTransformMatrix);
			Assert.AreEqual(originalFrustum.Near.A, transformedFrustum.Near.A);
			Assert.AreEqual(originalFrustum.Near.B, transformedFrustum.Near.B);
			Assert.AreEqual(originalFrustum.Near.C, transformedFrustum.Near.C);
			Assert.AreEqual(6, transformedFrustum.Near.D);

			Assert.AreEqual(originalFrustum.Top.A, transformedFrustum.Top.A);
			Assert.AreEqual(originalFrustum.Top.B, transformedFrustum.Top.B);
			Assert.AreEqual(originalFrustum.Top.C, transformedFrustum.Top.C);
			Assert.AreEqual(-5/Math.Sqrt(5), transformedFrustum.Top.D);

			transformedFrustum = Frustum.Transform(originalFrustum, rotateTransformMatrix);
			Assert.AreEqual(originalFrustum.Near.A, transformedFrustum.Near.A);
			Assert.AreEqual(0, transformedFrustum.Near.B);
			Assert.AreEqual(0, transformedFrustum.Near.C);
			Assert.AreEqual(originalFrustum.Near.D, transformedFrustum.Near.D);

			Assert.AreEqual(originalFrustum.Top.A, transformedFrustum.Top.A);
			var newYDirection = -(float)Math.Sin(Math.PI/6)*2/Math.Sqrt(5);
			var newZDirection = (float)Math.Cos(Math.PI/6)*2/Math.Sqrt(5);
			Assert.AreEqual(newYDirection, transformedFrustum.Top.B);
			Assert.AreEqual(newZDirection, transformedFrustum.Top.C);
			Assert.AreEqual(originalFrustum.Top.D, transformedFrustum.Top.D);
		}

		private Frustum CreateTestFrustum()
		{
			var frustum = new Frustum();
			frustum.Near = new Plane(-1,0,0,5);
			frustum.Far = new Plane(1,0,0,-20);
			frustum.Top = new Plane(-1,0,2,0);
			frustum.Bottom = new Plane(0,0,-1,0);
			frustum.Left = new Plane(0,-1,0,0);
			frustum.Right = new Plane(-1,2,0,0);

			return frustum;
		}
	}
}
