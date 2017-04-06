using Uno;
using Uno.Testing;

namespace Fuse.Entities.Geometry.Test
{
	public class CollisionTest
	{
		[Test]
		public void ClosestPointOnSegmentToPoint()
		{
			float3 res;

			Collision.ClosestPointOnSegmentToPoint(float3 (-2,-2,2), float3 (4,2,4), float3 (11,22,5), out res);
			Assert.AreEqual(float3 (4,2,4), res);

			Collision.ClosestPointOnSegmentToPoint(float3 (-3,-3,0), float3 (3,3,0), float3 (-1,1,0), out res);
			Assert.AreEqual(float3 (0,0,0), res);

			Collision.ClosestPointOnSegmentToPoint(float3 (-3,-3,0), float3 (3,3,0), float3 (-1,-1,0), out res);
			Assert.AreEqual(float3 (-1,-1,0), res);
		}

		[Test]
		[Ignore("#1677")]
		public void ClosestPointOnPlaneToPoint()
		{
			float3 res;
			var plane = new Plane(0,0,1,0);

			Collision.ClosestPointOnPlaneToPoint(plane, float3 (1,3,5), out res);
			Assert.AreEqual(float3 (1,3,0), res);

			Collision.ClosestPointOnPlaneToPoint(plane, float3 (1,5,0), out res);
			Assert.AreEqual(float3 (1,5,0), res);

			plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			plane.Normalize();
			Collision.ClosestPointOnPlaneToPoint(plane, float3 (1,1,4), out res);
			Assert.AreEqual(float3 (1,1,4), res);
		}

		[Test]
		public void ClosestPointOnTriangleToPoint()
		{
			float3 res;
			var triangle = new Triangle(float3 (7,7,0), float3 (-3,7,0), float3 (2,2,0));
			Collision.ClosestPointOnTriangleToPoint(triangle, float3 (7,7,0), out res);
			Assert.AreEqual(float3 (7,7,0), res);

			Collision.ClosestPointOnTriangleToPoint(triangle, float3 (3,6,0), out res);
			Assert.AreEqual(float3 (3,6,0), res);

			Collision.ClosestPointOnTriangleToPoint(triangle, float3 (7,7,5), out res);
			Assert.AreEqual(float3 (7,7,0), res);
		}

		[Test]
		[Ignore("#1678")]
		public void ClosestPointOnBoxToPoint()
		{
			float3 res;
			var minimumEdges = float3 (-3, -3, -3);
			var maximumEdges = float3 (3, 3, 3);
			var box = new Box(minimumEdges, maximumEdges);

			Collision.ClosestPointOnBoxToPoint(box, float3 (7,7,0), out res);
			Assert.AreEqual(float3 (3,3,0), res);

			Collision.ClosestPointOnBoxToPoint(box, float3 (7,7,11), out res);
			Assert.AreEqual(float3 (3,3,3), res);

			Collision.ClosestPointOnBoxToPoint(box, float3 (1,1,1), out res);
			Assert.AreEqual(float3 (3,3,1), res);

			Collision.ClosestPointOnBoxToPoint(box, float3 (3,3,0), out res);
			Assert.AreEqual(float3 (3,3,0), res);
		}

		[Test]
		public void ClosestPointOnSphereToPoint()
		{
			float3 res;
			var sphere = new Sphere(float3 (3,3,3), 15);

			Collision.ClosestPointOnSphereToPoint(sphere, float3 (1,1,1), out res);
			Assert.AreEqual(float3 (3-15/Math.Sqrt(3),3-15/Math.Sqrt(3),3-15/Math.Sqrt(3)), res);

			Collision.ClosestPointOnSphereToPoint(sphere, float3 (29,3,3), out res);
			Assert.AreEqual(float3 (18,3,3), res);

			Collision.ClosestPointOnSphereToPoint(sphere, float3 (18,3,3), out res);
			Assert.AreEqual(float3 (18,3,3), res);
		}

		[Test]
		public void ClosestPointOnSphereToSphere()
		{
			float3 res;
			var sphere1 = new Sphere(float3 (3,3,3), 3);

			Collision.ClosestPointOnSphereToSphere(sphere1, new Sphere(float3 (15,3,3), 5), out res);
			Assert.AreEqual(float3 (6,3,3), res);

			Collision.ClosestPointOnSphereToSphere(sphere1, new Sphere(float3 (2,2,2), 2), out res);
			Assert.AreEqual(float3 (3-3/Math.Sqrt(3),3-3/Math.Sqrt(3),3-3/Math.Sqrt(3)), res);

			Collision.ClosestPointOnSphereToSphere(sphere1, new Sphere(float3 (2,2,2), 1), out res);
			Assert.AreEqual(float3 (3-3/Math.Sqrt(3),3-3/Math.Sqrt(3),3-3/Math.Sqrt(3)), res);
		}

		[Test]
		public void RayIntersectsPoint()
		{
			var ray = new Ray(float3 (4,5,6), float3 (2,3,4));

			Assert.IsTrue(Collision.RayIntersectsPoint(ray, float3 (4,5,6)));
			Assert.IsTrue(Collision.RayIntersectsPoint(ray, float3 (6,7,8)));

			Assert.IsFalse(Collision.RayIntersectsPoint(ray, float3 (0,1,2)));
			Assert.IsFalse(Collision.RayIntersectsPoint(ray, float3 (10,1,2)));
		}

		[Test]
		[Ignore("#1680")]
		public void RayIntersectsRay()
		{
			float3 res;
			var ray1 = Ray.Normalize(new Ray(float3 (4,5,6), float3 (0,0,1)));
			var ray2 = Ray.Normalize(new Ray(float3 (6,5,6), float3 (0,0,1)));
			Assert.IsFalse(Collision.RayIntersectsRay(ray1, ray2, out res));

			ray1 = new Ray(float3 (4,0,0), float3 (0,0,1));
			ray2 = new Ray(float3 (0,0,3), float3 (1,0,0));
			Assert.IsTrue(Collision.RayIntersectsRay(ray1, ray2, out res));
			Assert.AreEqual(float3 (4,0,3), res);
		}

		[Test]
		public void RayIntersectsPlaneDistance()
		{
			float distance;
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			var ray = new Ray(float3 (1,1,6), float3 (1,0,0));
			Assert.IsFalse(Collision.RayIntersectsPlane(ray, plane, out distance));
			Assert.AreEqual(0, distance);

			ray = new Ray(float3 (1,1,2), float3 (0,0,1));
			Assert.IsTrue(Collision.RayIntersectsPlane(ray, plane, out distance));
			Assert.AreEqual(2, distance);
		}

		[Test]
		public void RayIntersectsPlanePoint()
		{
			float3 res;
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			var ray = new Ray(float3 (1,1,6), float3 (1,0,0));
			Assert.IsFalse(Collision.RayIntersectsPlane(ray, plane, out res));
			Assert.AreEqual(float3 (0), res);

			ray = new Ray(float3 (1,1,0), float3 (0,0,1));
			Assert.IsTrue(Collision.RayIntersectsPlane(ray, plane, out res));
			Assert.AreEqual(float3 (1,1,4), res);
		}

		[Test]
		public void RayIntersectsTriangleDistance()
		{
			float distance;
			var ray = new Ray(float3 (1,1,6), float3 (1,0,0));
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.IsFalse(Collision.RayIntersectsTriangle(ray, triangle, out distance));
			Assert.AreEqual(0, distance);

			ray = new Ray(float3 (4,5,6), float3 (0,0,1));
			Assert.IsFalse(Collision.RayIntersectsTriangle(ray, triangle, out distance));
			Assert.AreEqual(0, distance);

			ray = new Ray(float3 (4,5,6), float3 (0,0,-1));
			Assert.IsTrue(Collision.RayIntersectsTriangle(ray, triangle, out distance));
			Assert.AreEqual(6-4/5.0f, distance);
		}

		[Test]
		public void RayIntersectsTrianglePoint()
		{
			float3 res;
			var ray = new Ray(float3 (1,1,6), float3 (1,0,0));
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.IsFalse(Collision.RayIntersectsTriangle(ray, triangle, out res));
			Assert.AreEqual(float3 (0), res);

			ray = new Ray(float3 (4,5,6), float3 (0,0,-1));
			Assert.IsTrue(Collision.RayIntersectsTriangle(ray, triangle, out res));
			Assert.AreEqual(float3 (4,5,4/5.0f), res);
		}

		[Test]
		public void RayIntersectsBoxDistance()
		{
			float distance;
			var minimumEdges = float3 (-3, -3, -3);
			var maximumEdges = float3 (3, 3, 3);
			var box = new Box(minimumEdges, maximumEdges);
			var ray = new Ray(float3 (6,6,3), float3 (1,0,0));

			Assert.IsFalse(Collision.RayIntersectsBox(ray, box, out distance));
			Assert.AreEqual(0, distance);

			ray = new Ray(float3 (6,2,2), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out distance));
			Assert.AreEqual(3, distance);

			ray = new Ray(float3 (6,3,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out distance));
			Assert.AreEqual(3, distance);

			ray = new Ray(float3 (2,2,2), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out distance));
			Assert.AreEqual(0, distance);
		}

		[Test]
		public void RayIntersectsBoxPoint()
		{
			float3 res;
			var minimumEdges = float3 (-3, -3, -3);
			var maximumEdges = float3 (3, 3, 3);
			var box = new Box(minimumEdges, maximumEdges);
			var ray = new Ray(float3 (6,6,3), float3 (1,0,0));

			Assert.IsFalse(Collision.RayIntersectsBox(ray, box, out res));
			Assert.AreEqual(float3 (0), res);

			ray = new Ray(float3 (6,2,2), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out res));
			Assert.AreEqual(float3 (3,2,2), res);

			ray = Ray.Normalize(new Ray(float3 (6,6,3), float3 (-1,-1,0)));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out res));
			Assert.AreEqual(float3 (3,3,3), res);

			ray = new Ray(float3 (2,2,2), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsBox(ray, box, out res));
			Assert.AreEqual(float3 (2,2,2), res);
		}

		[Test]
		public void RayIntersectsSphereDistance()
		{
			float distance;
			var sphere = new Sphere(float3 (3,3,3), 15);
			var ray = new Ray(float3 (6,6,3), float3 (1,0,0));

			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out distance));
			Assert.AreEqual(0, distance);

			ray = new Ray(float3 (21,6,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out distance));
			Assert.AreEqual(18-Math.Sqrt(216), distance);

			ray = new Ray(float3 (21,6,3), float3 (1,0,0));
			Assert.IsFalse(Collision.RayIntersectsSphere(ray, sphere, out distance));
			Assert.AreEqual(0, distance);
		}

		[Test]
		public void RayIntersectsSpherePoint()
		{
			float3 res;
			var sphere = new Sphere(float3 (3,3,3), 15);
			var ray = new Ray(float3 (21,6,3), float3 (1,0,0));

			Assert.IsFalse(Collision.RayIntersectsSphere(ray, sphere, out res));
			Assert.AreEqual(float3 (0), res);

			ray = new Ray(float3 (21,6,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out res));
			Assert.AreEqual(float3 (3+Math.Sqrt(216),6,3), res);

			ray = new Ray(float3 (18,3,10), float3 (0,0,-1));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out res));
			Assert.AreEqual(float3 (18,3,3), res);

			ray = new Ray(float3 (6,6,3), float3 (1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out res));
			Assert.AreEqual(float3 (6,6,3), res);
		}

		[Test]
		public void RayIntersectsSphereNormal()
		{
			float3 point, normal;
			var sphere = new Sphere(float3 (3,3,3), 15);
			var ray = new Ray(float3 (21,6,3), float3 (1,0,0));

			Assert.IsFalse(Collision.RayIntersectsSphere(ray, sphere, out point, out normal));
			Assert.AreEqual(float3 (0), point);
			Assert.AreEqual(float3 (0), normal);

			ray = new Ray(float3 (21,6,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out point, out normal));
			Assert.AreEqual(float3 (3+Math.Sqrt(216),6,3), point);
			Assert.AreEqual(float3 (Math.Sqrt(216)/15,0.2f,0), normal);
		}

		[Test]
		public void RayIntersectsSphereTwoPoints()
		{
			float3 entrancePoint, exitPoint, entranceNormal, exitNormal;
			var sphere = new Sphere(float3 (3,3,3), 15);
			var ray = new Ray(float3 (21,6,3), float3 (1,0,0));

			Assert.IsFalse(Collision.RayIntersectsSphere(ray, sphere, out entrancePoint, out entranceNormal, out exitPoint, out exitNormal));
			Assert.AreEqual(float3 (0), entrancePoint);
			Assert.AreEqual(float3 (0), entranceNormal);
			Assert.AreEqual(float3 (0), exitPoint);
			Assert.AreEqual(float3 (0), exitNormal);

			ray = new Ray(float3 (21,6,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out entrancePoint, out entranceNormal, out exitPoint, out exitNormal));
			Assert.AreEqual(float3 (3+Math.Sqrt(216),6,3), entrancePoint);
			Assert.AreEqual(float3 (Math.Sqrt(216)/15,0.2f,0), entranceNormal);
			Assert.AreEqual(float3 (3-Math.Sqrt(216),6,3), exitPoint);
			Assert.AreEqual(float3 (-Math.Sqrt(216)/15,0.2f,0), exitNormal);

			ray = new Ray(float3 (6,6,3), float3 (-1,0,0));
			Assert.IsTrue(Collision.RayIntersectsSphere(ray, sphere, out entrancePoint, out entranceNormal, out exitPoint, out exitNormal));
			Assert.AreEqual(float3 (0), entrancePoint);
			Assert.AreEqual(float3 (0), entranceNormal);
			Assert.AreEqual(float3 (3-Math.Sqrt(216),6,3), exitPoint);
			Assert.AreEqual(float3 (-Math.Sqrt(216)/15,0.2f,0), exitNormal);
		}

		[Test]
		public void PlaneIntersectsPoint()
		{
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Front, Collision.PlaneIntersectsPoint(plane, float3 (1,1,15)));
			Assert.AreEqual(Collision.PlaneIntersectionType.Back, Collision.PlaneIntersectsPoint(plane, float3 (-31,1,1)));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsPoint(plane, float3 (0,0,4)));
		}

		[Test]
		public void PlaneIntersectsPlane()
		{
			Ray line;
			var plane1 = new Plane(float3 (1,1,4), float3 (0,0,1));
			var plane2 = new Plane(float3 (3,3,9), float3 (0,0,1));
			Assert.IsFalse(Collision.PlaneIntersectsPlane(plane1, plane2, out line));
			Assert.AreEqual(float3 (0), line.Position);
			Assert.AreEqual(float3 (0), line.Direction);

			plane2 = new Plane(float3 (3,3,9), float3 (0,1,0));
			Assert.IsTrue(Collision.PlaneIntersectsPlane(plane1, plane2, out line));
			Assert.AreEqual(float3 (0,-3,-4), line.Position);
			Assert.AreEqual(float3 (1,0,0), Math.Abs(line.Direction));
		}

		[Test]
		public void PlaneIntersectsTriangle()
		{
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.AreEqual(Collision.PlaneIntersectionType.Back, Collision.PlaneIntersectsTriangle(plane, triangle));

			plane = new Plane(float3 (1,1,4), float3 (0,0,-1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Front, Collision.PlaneIntersectsTriangle(plane, triangle));

			plane = new Plane(float3 (1,1,4), float3 (2,2,1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Front, Collision.PlaneIntersectsTriangle(plane, triangle));

			plane = new Plane(float3 (3,3,4), float3 (2,2,0));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsTriangle(plane, triangle));

			plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			triangle = new Triangle(float3 (7,7,4), float3 (3,7,4), float3 (2,2,4));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsTriangle(plane, triangle));
		}

		[Test]
		public void PlaneIntersectsBox()
		{
			var plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			var minimumEdges = float3 (-3, -3, -3);
			var maximumEdges = float3 (3, 3, 3);
			var box = new Box(minimumEdges, maximumEdges);
			Assert.AreEqual(Collision.PlaneIntersectionType.Back, Collision.PlaneIntersectsBox(plane, box));

			plane = new Plane(float3 (1,1,3), float3 (0,0,1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsBox(plane, box));

			plane = new Plane(float3 (1,1,4), float3 (-1,-1,-1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsBox(plane, box));
		}

		[Test]
		public void PlaneIntersectsSphere()
		{
			var plane = new Plane(float3 (1,1,5), float3 (0,0,1));
			var sphere = new Sphere(float3 (3,3,-3), 7);
			Assert.AreEqual(Collision.PlaneIntersectionType.Back, Collision.PlaneIntersectsSphere(plane, sphere));

			plane = new Plane(float3 (1,1,5), float3 (0,0,-1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Front, Collision.PlaneIntersectsSphere(plane, sphere));

			plane = new Plane(float3 (1,1,4), float3 (0,0,1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsSphere(plane, sphere));

			plane = new Plane(float3 (1,1,2), float3 (0,0,-1));
			Assert.AreEqual(Collision.PlaneIntersectionType.Intersecting, Collision.PlaneIntersectsSphere(plane, sphere));
		}

		[Test]
		public void BoxIntersectsTriangle()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (8,8,3));
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.IsTrue(Collision.BoxIntersectsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (8,8,2));
			Assert.IsTrue(Collision.BoxIntersectsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (3,3,1));
			Assert.IsTrue(Collision.BoxIntersectsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (0,0,-1));
			Assert.IsFalse(Collision.BoxIntersectsTriangle(box, triangle));
		}

		[Test]
		public void BoxIntersectsBox()
		{
			var box1 = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			var box2 = new Box(float3 (4,4,5), float3 (6,6,6));
			Assert.IsFalse(Collision.BoxIntersectsBox(box1, box2));

			box2 = new Box(float3 (-1,-1,-1), float3 (2,2,2));
			Assert.IsTrue(Collision.BoxIntersectsBox(box1, box2));

			box2 = new Box(float3 (3,3,3), float3 (7,8,9));
			Assert.IsTrue(Collision.BoxIntersectsBox(box1, box2));
		}

		[Test]
		public void BoxIntersectsSphere()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			var sphere = new Sphere(float3 (3,3,-3), 7);
			Assert.IsTrue(Collision.BoxIntersectsSphere(box, sphere));

			sphere = new Sphere(float3 (1,1,1), 1);
			Assert.IsTrue(Collision.BoxIntersectsSphere(box, sphere));

			sphere = new Sphere(float3 (-10,1,1), 3);
			Assert.IsFalse(Collision.BoxIntersectsSphere(box, sphere));
		}

		[Test]
		[Ignore("#1681")]
		public void SphereIntersectsTriangle()
		{
			float3 res;
			var sphere = new Sphere(float3 (9,9,0), 3);
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,0));
			Assert.IsTrue(Collision.SphereIntersectsTriangle(sphere, triangle, out res));

			sphere = new Sphere(float3 (3,3,-3), 2);
			Assert.IsFalse(Collision.SphereIntersectsTriangle(sphere, triangle, out res));
			Assert.AreEqual(float3 (0), res);
		}

		[Test]
		public void SphereIntersectsSphere()
		{
			var sphere1 = new Sphere(float3 (3,3,-3), 4);
			var sphere2 = new Sphere(float3 (3,3,11), 5);
			Assert.IsFalse(Collision.SphereIntersectsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (2,2,-3), 2);
			Assert.IsTrue(Collision.SphereIntersectsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (2,2,-5), 7);
			Assert.IsTrue(Collision.SphereIntersectsSphere(sphere1, sphere2));
		}

		[Test]
		public void BoxContainsPoint()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.BoxContainsPoint(box, float3 (5,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsPoint(box, float3 (3,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsPoint(box, float3 (1,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsPoint(box, float3 (1,2,0)));
		}

		[Test]
		public void BoxContainsTriangle()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (8,8,3));
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (8,8,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (3,3,1));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.BoxContainsTriangle(box, triangle));

			box = new Box(float3 (-3,-3,-3), float3 (0,0,-1));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.BoxContainsTriangle(box, triangle));
		}

		[Test]
		public void BoxContainsBox()
		{
			var box1 = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			var box2 = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsBox(box1, box2));

			box2 = new Box(float3 (-2,-2,-2), float3 (2,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsBox(box1, box2));

			box2 = new Box(float3 (-2,-2,-2), float3 (2,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsBox(box1, box2));

			box2 = new Box(float3 (4,5,6), float3 (8,8,7));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.BoxContainsBox(box1, box2));

			box2 = new Box(float3 (-1,-1,-2), float3 (4,4,4));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.BoxContainsBox(box1, box2));

			box2 = new Box(float3 (3,3,3), float3 (4,4,4));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.BoxContainsBox(box1, box2));
		}

		[Test]
		public void BoxContainsSphere()
		{
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			var sphere = new Sphere(float3 (3,3,3), 4);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.BoxContainsSphere(box, sphere));

			sphere = new Sphere(float3 (0,0,0), 2);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.BoxContainsSphere(box, sphere));

			sphere = new Sphere(float3 (3,3,6), 3);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.BoxContainsSphere(box, sphere));

			sphere = new Sphere(float3 (3,3,-35), 3);
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.BoxContainsSphere(box, sphere));
		}

		[Test]
		public void SphereContainsPoint()
		{
			var sphere = new Sphere(float3 (3,3,3), 4);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsPoint(sphere, float3 (5,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsPoint(sphere, float3 (3,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.SphereContainsPoint(sphere, float3 (11,3,3)));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.SphereContainsPoint(sphere, float3 (0,2,-61)));
		}

		[Test]
		public void SphereContainsTriangle()
		{
			var sphere = new Sphere(float3 (3,3,0), 6);
			var triangle = new Triangle(float3 (7,7,0), float3 (3,7,0), float3 (2,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsTriangle(sphere, triangle));

			sphere = new Sphere(float3 (3,3,3), 4);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.SphereContainsTriangle(sphere, triangle));

			sphere = new Sphere(float3 (15,3,3), 4);
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.SphereContainsTriangle(sphere, triangle));
		}

		[Test]
		public void SphereContainsBox()
		{
			var sphere = new Sphere(float3 (3,3,3), 4);
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.SphereContainsBox(sphere, box));

			sphere = new Sphere(float3 (0,0,0), 2);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.SphereContainsBox(sphere, box));

			sphere = new Sphere(float3 (0,0,0), 8);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsBox(sphere, box));

			sphere = new Sphere(float3 (3,3,-35), 3);
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.SphereContainsBox(sphere, box));
		}

		[Test]
		public void SphereContainsSphere()
		{
			var sphere1 = new Sphere(float3 (3,3,3), 4);
			var sphere2 = new Sphere(float3 (11,3,3), 3);
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.SphereContainsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (1,2,1), 1);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (2,1,2), 8);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.SphereContainsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (2,1,2), 3);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.SphereContainsSphere(sphere1, sphere2));

			sphere2 = new Sphere(float3 (3,3,3), 4);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.SphereContainsSphere(sphere1, sphere2));
		}

		[Test]
		public void FrustumContainsPoint()
		{
			var frustum = CreateTestFrustum();
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.FrustumContainsPoint(frustum, float3 (4,0,0)));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.FrustumContainsPoint(frustum, float3 (7,11,10)));

			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsPoint(frustum, float3 (5,0,0)));

			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.FrustumContainsPoint(frustum, float3 (10,1,1)));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.FrustumContainsPoint(frustum, float3 (5.01f,1,1)));
		}

		[Test]
		public void FrustumContainsTriangle()
		{
			var frustum = CreateTestFrustum();

			var triangle = new Triangle(float3 (15,7,0), float3 (6,2,0), float3 (10,2,2));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsTriangle(frustum, triangle));

			triangle = new Triangle(float3 (15,7,-1), float3 (6,2,-1), float3 (10,2,2));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsTriangle(frustum, triangle));

			triangle = new Triangle(float3 (15,7,1), float3 (6,2,1), float3 (10,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.FrustumContainsTriangle(frustum, triangle));

			triangle = new Triangle(float3 (15,7,8), float3 (6,2,5), float3 (10,2,11));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.FrustumContainsTriangle(frustum, triangle));
		}

		[Test]
		public void FrustumContainsBox()
		{
			var frustum = CreateTestFrustum();
			var box = new Box(float3 (-3,-3,-3), float3 (3,3,3));
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.FrustumContainsBox(frustum, box));

			box = new Box(float3 (-3,-3,-3), float3 (10,10,3));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsBox(frustum, box));

			box = new Box(float3 (6,1,1), float3 (10,2,2));
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.FrustumContainsBox(frustum, box));

			box = new Box(float3 (5,0,0), float3 (8,1,1));
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsBox(frustum, box));
		}

		[Test]
		public void FrustumContainsSphere()
		{
			var frustum = CreateTestFrustum();
			var sphere = new Sphere(float3 (9,2,2), 1);
			Assert.AreEqual(Collision.ContainmentType.Contains, Collision.FrustumContainsSphere(frustum, sphere));

			sphere = new Sphere(float3 (-7,2,2), 2);
			Assert.AreEqual(Collision.ContainmentType.Disjoint, Collision.FrustumContainsSphere(frustum, sphere));

			sphere = new Sphere(float3 (5,2,2), 2);
			Assert.AreEqual(Collision.ContainmentType.Intersects, Collision.FrustumContainsSphere(frustum, sphere));
		}

		[Test]
		public void AreParallel()
		{
			Assert.IsTrue(Collision.AreParallel(float3 (1,0,3), float3 (1,0,3)));
			Assert.IsTrue(Collision.AreParallel(float3 (2,3,4), float3 (4,6,8)));

			Assert.IsFalse(Collision.AreParallel(float3 (2,3,4), float3 (2,3,5)));
			Assert.IsFalse(Collision.AreParallel(float3 (2,3,4), float3 (4,6,8.001f)));
			Assert.IsTrue(Collision.AreParallel(float3 (2,3,4), float3 (4,6,8.001f), 0.01f)); //tolerance check
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
