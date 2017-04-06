using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class BoxTest
	{
		[Test]
		public void Transform()
		{
			var minimumEdges = float3 (-3, -3, -3);
			var maximumEdges = float3 (3, 3, 3);
			var originalBox = new Box(minimumEdges, maximumEdges);

			var noneTransformMatrix = float4x4 (1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1);

			var moveTransformMatrix = float4x4 (1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			1, 2, 3, 1);

			var scaleTransformMatrix = float4x4 (4, 0, 0, 0,
			0, 3, 0, 0,
			0, 0, 2, 0,
			0, 0, 0, 1);

			var rotateTransformMatrix = float4x4 (1, 0, 0, 0,
			0, (float)Math.Cos(Math.PI / 6), (float)Math.Sin(Math.PI / 6), 0,
			0, (float)-Math.Sin(Math.PI / 6), (float)Math.Cos(Math.PI / 6), 0,
			0, 0, 0, 1);

			var transformedBox = Box.Transform(originalBox, noneTransformMatrix);
			Assert.AreEqual(float3 (-3,-3,-3), transformedBox.Minimum);
			Assert.AreEqual(float3 (3,3,3), transformedBox.Maximum);

			transformedBox = Box.Transform(originalBox, moveTransformMatrix);
			Assert.AreEqual(float3 (-2,-1,0), transformedBox.Minimum);
			Assert.AreEqual(float3 (4,5,6), transformedBox.Maximum);

			transformedBox = Box.Transform(originalBox, scaleTransformMatrix);
			Assert.AreEqual(float3 (-12,-9,-6), transformedBox.Minimum);
			Assert.AreEqual(float3 (12,9,6), transformedBox.Maximum);

			transformedBox = Box.Transform(originalBox, rotateTransformMatrix);
			Assert.AreEqual(float3 (-3,-4.098f,-4.098f), transformedBox.Minimum, 0.001f);
			Assert.AreEqual(float3 (3,4.098f,4.098f), transformedBox.Maximum, 0.001f);
		}
	}
}
