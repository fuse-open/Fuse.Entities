using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class TriangleTest
	{
		[Test]
		public void Normal()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.AreEqual(float3 (0,2/Math.Sqrt(29),5/Math.Sqrt(29)), triangle.Normal);
		}

		[Test]
		public void GetBarycentricCoordinatesAt()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,2));
			Assert.AreEqual(float3 (0.1517f, -0.04827f, 0.8965f), triangle.GetBarycentricCoordinatesAt(float3 (3,3,3)), 0.001f);
		}

		[Test]
		public void MultiplicationOperator()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,2));
			triangle *= float3 (10,11,12);
			Assert.AreEqual(float3 (70,77,0), triangle.A);
			Assert.AreEqual(float3 (-30,77,0), triangle.B);
			Assert.AreEqual(float3 (20,22,24), triangle.C);
		}

		[Test]
		public void DivisionOperator()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,2));
			triangle /= float3 (2,4,3);
			Assert.AreEqual(float3 (3.5f,1.75f,0), triangle.A);
			Assert.AreEqual(float3 (-1.5f,1.75f,0), triangle.B);
			Assert.AreEqual(float3 (1,0.5f,2/3.0f), triangle.C);
		}

		[Test]
		public void PlusOperator()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,2));
			triangle += float3 (2,4,-3);
			Assert.AreEqual(float3 (9,11,-3), triangle.A);
			Assert.AreEqual(float3 (-1,11,-3), triangle.B);
			Assert.AreEqual(float3 (4,6,-1), triangle.C);
		}

		[Test]
		public void MinusOperator()
		{
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,2));
			triangle -= float3 (2,4,-3);
			Assert.AreEqual(float3 (5,3,3), triangle.A);
			Assert.AreEqual(float3 (-5,3,3), triangle.B);
			Assert.AreEqual(float3 (0,-2,5), triangle.C);
		}
	}
}
