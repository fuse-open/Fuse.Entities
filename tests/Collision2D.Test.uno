using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class Collision2DTest
	{
		[Test]
		public void TriangleContainsPoint()
		{
			//just some basic sanity tests
			Assert.IsTrue( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(3,1) ) );
			Assert.IsTrue( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(4,-0.5f) ) );
			Assert.IsTrue( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(4,1) ) );
			Assert.IsTrue( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(4,1.99f) ) );

			Assert.IsFalse( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(4,2.01f) ) );
			Assert.IsFalse( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(5,0) ) );
			Assert.IsFalse( Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(0,0) ) );

			//the result of the next calculation is undefined. So just check that it doesn't throw any exceptions
			Assert.DoesNotThrowAny(TriangleContainsBorderPointAction);

			//src: https://github.com/Outracks/RealtimeStudio/issues/1294
			Assert.IsFalse( Collision2D.TriangleContainsPoint(
			float2(2.425818f, -0.07260615f), float2(1.483035f, 0.2629834f), float2(1.483035f, 0.2629833f), float2(22.40005f, -39.19998f) ) );
		}

		[Test]
		public void AraParallel()
		{
			Assert.IsTrue( Collision2D.AreParallel( float2(1,4), float2(2,8) ) );
			Assert.IsTrue( Collision2D.AreParallel( float2(0,4), float2(1e-8f,8) ) ); //tolerance checked
			Assert.IsFalse( Collision2D.AreParallel( float2(1,5), float2(2,8) ) );
		}

		[Test]
		public void AngleBetween()
		{
			Assert.AreEqual(Math.PI / 2, Collision2D.AngleBetween(float2(10,1), float2(-1,10)));
			Assert.AreEqual(Math.PI / 4, Collision2D.AngleBetween(float2(10,0), float2(10,10)));
			Assert.AreEqual(Math.PI / 4, Collision2D.AngleBetween(float2(10,0), float2(10,-10)));
			Assert.AreEqual(Math.PI, Collision2D.AngleBetween(float2(10,0), float2(-10,0)));
			Assert.AreEqual(Math.PI, Collision2D.AngleBetween(float2(10,5), float2(-10,-5)));
			Assert.AreEqual(0, Collision2D.AngleBetween(float2(10,0), float2(10,0)));
		}

		[Test]
		public void LineIntersectionPoint()
		{
			Assert.AreEqual(float2 (20,20), Collision2D.LineIntersectionPoint(float2 (10,10), float2 (30,30), float2 (10,30), float2 (30,10)));
			Assert.AreEqual(float2 (0,0), Collision2D.LineIntersectionPoint(float2 (-10,-10), float2 (10,10), float2 (-10,10), float2 (10,-10)));
			//lines are parallel
			Assert.AreEqual(float2 (-10,-10), Collision2D.LineIntersectionPoint(float2 (-10,-10), float2 (10,10), float2 (-10,-20), float2 (10,0)));
		}

		//#region provate methods

		void TriangleContainsBorderPointAction()
		{
			Collision2D.TriangleContainsPoint( float2(2,2), float2(5,2), float2(4,-1), float2(4,2) );
		}
	}
}
