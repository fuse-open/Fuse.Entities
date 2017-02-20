using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content;
using Uno.Content.Models;
using Uno.Testing;

namespace Fuse.Entities.Test
{
	public class ContextTest
	{
		[Test]
		public void DefaultCamera_IsInCorrectPosition()
		{
			var cam = new Entity();
			cam.Children.Add(new Transform3D());
			cam.Children.Add(new Frustum());
			Assert.AreEqual(float3(0, 0, 0), cam.Transform.Position);
			Assert.AreEqual(float3(0, 0, 0), cam.Transform.RotationDegrees, .0001f);
		}
	}
}
