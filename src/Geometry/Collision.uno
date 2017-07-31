using Uno;

namespace Fuse.Entities.Geometry
{
	public static class Collision
	{
		public enum ContainmentType
		{
			Disjoint,
			Contains,
			Intersects
		}

		public enum PlaneIntersectionType
		{
			Back,
			Front,
			Intersecting
		}

		public static void ClosestPointOnSegmentToPoint(float3 segment1, float3 segment2, float3 point, out float3 result)
		{
			float3 ab = segment2 - segment1;
			float t = Vector.Dot(point - segment1, ab) / Vector.Dot(ab, ab);

			if (t < 0.0f)
			t = 0.0f;

			if (t > 1.0f)
			t = 1.0f;

			result = segment1 + ab * t;
		}

		public static void ClosestPointOnPlaneToPoint(Plane plane, float3 point, out float3 result)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 126

			float dot = Vector.Dot(plane.Normal, point);
			float t = dot - plane.D;

			result = point - (plane.Normal * t);
		}

		public static void ClosestPointOnTriangleToPoint(Triangle triangle, float3 point, out float3 result)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 136

			//Check if P in vertex region outside A
			float3 ab = triangle.B - triangle.A;
			float3 ac = triangle.C - triangle.A;
			float3 ap = point - triangle.A;

			float d1 = Vector.Dot(ab, ap);
			float d2 = Vector.Dot(ac, ap);
			if (d1 <= 0.0f && d2 <= 0.0f)
			{
				result = triangle.A; //Barycentric coordinates (1,0,0)
				return;
			}

			//Check if P in vertex region outside B
			float3 bp = point - triangle.B;
			float d3 = Vector.Dot(ab, bp);
			float d4 = Vector.Dot(ac, bp);
			if (d3 >= 0.0f && d4 <= d3)
			{
				result = triangle.B; // barycentric coordinates (0,1,0)
				return;
			}

			//Check if P in edge region of AB, if so return projection of P onto AB
			float vc = d1 * d4 - d3 * d2;
			if (vc <= 0.0f && d1 >= 0.0f && d3 <= 0.0f)
			{
				float v = d1 / (d1 - d3);
				result = triangle.A + ab * v; //Barycentric coordinates (1-v,v,0)
				return;
			}

			//Check if P in vertex region outside C
			float3 cp = point - triangle.C;
			float d5 = Vector.Dot(ab, cp);
			float d6 = Vector.Dot(ac, cp);
			if (d6 >= 0.0f && d5 <= d6)
			{
				result = triangle.C; //Barycentric coordinates (0,0,1)
				return;
			}

			//Check if P in edge region of AC, if so return projection of P onto AC
			float vb = d5 * d2 - d1 * d6;
			if (vb <= 0.0f && d2 >= 0.0f && d6 <= 0.0f)
			{
				float w = d2 / (d2 - d6);
				result = triangle.A + ac * w; //Barycentric coordinates (1-w,0,w)
				return;
			}

			//Check if P in edge region of BC, if so return projection of P onto BC
			float va = d3 * d6 - d5 * d4;
			if (va <= 0.0f && (d4 - d3) >= 0.0f && (d5 - d6) >= 0.0f)
			{
				float w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
				result = triangle.B + (triangle.C - triangle.B) * w; //Barycentric coordinates (0,1-w,w)
				return;
			}

			//P inside face region. Compute Q through its barycentric coordinates (u,v,w)
			float denom = 1.0f / (va + vb + vc);
			float v2 = vb * denom;
			float w2 = vc * denom;
			result = triangle.A + ab * v2 + ac * w2; //= u*triangle.A + v*triangle.B + w*triangle.C, u = va * denom = 1.0.f - v - w
		}

		public static void ClosestPointOnBoxToPoint(Box box, float3 point, out float3 result)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 130

			float3 temp = Math.Max(point, box.Minimum);
			result = Math.Min(temp, box.Maximum);
		}

		public static void ClosestPointOnSphereToPoint(Sphere sphere, float3 point, out float3 result)
		{
			//Source: Jorgy343
			//Reference: None

			//Get the unit direction from the sphere's center to the point.
			result = Vector.Normalize(point - sphere.Center);

			//Multiply the unit direction by the sphere's radius to get a vector
			//the length of the sphere.
			result *= sphere.Radius;

			//Add the sphere's center to the direction to get a point on the sphere.
			result += sphere.Center;
		}

		public static void ClosestPointOnSphereToSphere(Sphere sphere1, Sphere sphere2, out float3 result)
		{
			//Source: Jorgy343
			//Reference: None

			//Get the unit direction from the first sphere's center to the second sphere's center.
			result = Vector.Normalize(sphere2.Center - sphere1.Center);

			//Multiply the unit direction by the first sphere's radius to get a vector
			//the length of the first sphere.
			result *= sphere1.Radius;

			//Add the first sphere's center to the direction to get a point on the first sphere.
			result += sphere1.Center;
		}

		const float _zeroTolerance = 1e-05f;

		public static bool RayIntersectsPoint(Ray ray, float3 point)
		{
			//Source: RayIntersectsSphere
			//Reference: None

			float3 m = ray.Position - point;

			//Same thing as RayIntersectsSphere except that the radius of the sphere (point)
			//is the epsilon for zero.
			float b = Vector.Dot(m, ray.Direction);
			float c = Vector.Dot(m, m) - _zeroTolerance;

			if (c > 0.f && b > 0.f)
			return false;

			float discriminant = b * b - c;

			if (discriminant < 0.f)
			return false;

			return true;
		}

		public static bool RayIntersectsRay(Ray ray1, Ray ray2, out float3 point)
		{
			//Source: Real-Time Rendering, Third Edition
			//Reference: Page 780

			float3 cross = Vector.Cross(ray1.Direction, ray2.Direction);
			float denominator = Vector.Length(cross);

			//Lines are parallel.
			if (Math.Abs(denominator) < _zeroTolerance)
			{
				//Lines are parallel and on top of each other.
				if (Math.Abs(ray2.Position.X - ray1.Position.X) < _zeroTolerance &&
				Math.Abs(ray2.Position.Y - ray1.Position.Y) < _zeroTolerance &&
				Math.Abs(ray2.Position.Z - ray1.Position.Z) < _zeroTolerance)
				{
					point = float3(0);
					return true;
				}
			}

			denominator = denominator * denominator;

			//3x3 matrix for the first ray.
			float m11 = ray2.Position.X - ray1.Position.X;
			float m12 = ray2.Position.Y - ray1.Position.Y;
			float m13 = ray2.Position.Z - ray1.Position.Z;
			float m21 = ray2.Direction.X;
			float m22 = ray2.Direction.Y;
			float m23 = ray2.Direction.Z;
			float m31 = cross.X;
			float m32 = cross.Y;
			float m33 = cross.Z;

			//Determinant of first matrix.
			float dets =
			m11 * m22 * m33 +
			m12 * m23 * m31 +
			m13 * m21 * m32 -
			m11 * m23 * m32 -
			m12 * m21 * m33 -
			m13 * m22 * m31;

			//3x3 matrix for the second ray.
			m21 = ray1.Direction.X;
			m22 = ray1.Direction.Y;
			m23 = ray1.Direction.Z;

			//Determinant of the second matrix.
			float dett =
			m11 * m22 * m33 +
			m12 * m23 * m31 +
			m13 * m21 * m32 -
			m11 * m23 * m32 -
			m12 * m21 * m33 -
			m13 * m22 * m31;

			//t values of the point of intersection.
			float s = dets / denominator;
			float t = dett / denominator;

			//The points of intersection.
			float3 point1 = ray1.Position + (ray1.Direction * s);
			float3 point2 = ray2.Position + (ray2.Direction * t);

			//If the points are not equal, no intersection has occured.
			if (Math.Abs(point2.X - point1.X) > _zeroTolerance ||
			Math.Abs(point2.Y - point1.Y) > _zeroTolerance ||
			Math.Abs(point2.Z - point1.Z) > _zeroTolerance)
			{
				point = float3(0);
				return false;
			}

			point = point1;
			return true;
		}

		public static bool RayIntersectsPlane(Ray ray, Plane plane, out float distance)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 175

			float direction = Vector.Dot(plane.Normal, ray.Direction);

			if (Math.Abs(direction) < _zeroTolerance)
			{
				distance = 0.f;
				return false;
			}

			float position = Vector.Dot(plane.Normal, ray.Position);
			distance = (-plane.D - position) / direction;

			if (distance < 0.f)
			{
				if (distance < -_zeroTolerance)
				{
					distance = 0;
					return false;
				}

				distance = 0.f;
			}

			return true;
		}

		public static bool RayIntersectsPlane(Ray ray, Plane plane, out float3 point)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 175

			float distance;
			if (!RayIntersectsPlane(ray, plane, out distance))
			{
				point = float3(0);
				return false;
			}

			point = ray.Position + (ray.Direction * distance);
			return true;
		}

		public static bool RayIntersectsTriangle(Ray ray, Triangle triangle, out float distance)
		{
			//Source: Fast Minimum Storage Ray / Triangle Intersection
			//Reference: http://www.cs.virginia.edu/~gfx/Courses/2003/ImageSynthesis/papers/Acceleration/Fast%20MinimumStorage%20RayTriangle%20Intersection.pdf

			//Compute vectors along two edges of the triangle.
			//Edge 1
			float3 edge1 = triangle.B - triangle.A;

			//Edge2
			float3 edge2 = triangle.C - triangle.A;

			//Cross product of ray direction and edge2 - first part of determinant.
			float3 directioncrossedge2 = Vector.Cross(ray.Direction, edge2);

			//Compute the determinant.
			float determinant;
			//Dot product of edge1 and the first part of determinant.
			determinant = Vector.Dot(edge1, directioncrossedge2);

			//If the ray is parallel to the triangle plane, there is no collision.
			//This also means that we are not culling, the ray may hit both the
			//back and the front of the triangle.
			if (determinant > -_zeroTolerance && determinant < _zeroTolerance)
			{
				distance = 0.f;
				return false;
			}

			float inversedeterminant = 1.0f / determinant;

			//Calculate the U parameter of the intersection point.
			float3 distanceVector = ray.Position - triangle.A;

			float triangleU;
			triangleU = Vector.Dot(distanceVector, directioncrossedge2);
			triangleU *= inversedeterminant;

			//Make sure it is inside the triangle.
			if (triangleU < 0.f || triangleU > 1.f)
			{
				distance = 0.f;
				return false;
			}

			//Calculate the V parameter of the intersection point.
			float3 distancecrossedge1 = Vector.Cross(distanceVector, edge1);

			float triangleV;
			triangleV = Vector.Dot(ray.Direction, distancecrossedge1);
			triangleV *= inversedeterminant;

			//Make sure it is inside the triangle.
			if (triangleV < 0.f || triangleU + triangleV > 1.f)
			{
				distance = 0.f;
				return false;
			}

			//Compute the distance along the ray to the triangle.
			float raydistance;
			raydistance = Vector.Dot(edge2, distancecrossedge1);
			raydistance *= inversedeterminant;

			//Is the triangle behind the ray origin?
			if (raydistance < 0.f)
			{
				distance = 0.f;
				return false;
			}

			distance = raydistance;
			return true;
		}

		public static bool RayIntersectsTriangle(Ray ray, Triangle triangle, out float3 point)
		{
			float distance;
			if (!RayIntersectsTriangle(ray, triangle, out distance))
			{
				point = float3(0);
				return false;
			}

			point = ray.Position + (ray.Direction * distance);
			return true;
		}

		public static bool RayIntersectsBox(Ray ray, Box box, out float distance)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 179

			distance = 0.f;
			float tmax = float.MaxValue;

			if (Math.Abs(ray.Direction.X) < _zeroTolerance)
			{
				if (ray.Position.X < box.Minimum.X || ray.Position.X > box.Maximum.X)
				{
					distance = 0.f;
					return false;
				}
			}
			else
			{
				float inverse = 1.0f / ray.Direction.X;
				float t1 = (box.Minimum.X - ray.Position.X) * inverse;
				float t2 = (box.Maximum.X - ray.Position.X) * inverse;

				if (t1 > t2)
				{
					float temp = t1;
					t1 = t2;
					t2 = temp;
				}

				distance = Math.Max(t1, distance);
				tmax = Math.Min(t2, tmax);

				if (distance > tmax)
				{
					distance = 0.f;
					return false;
				}
			}

			if (Math.Abs(ray.Direction.Y) < _zeroTolerance)
			{
				if (ray.Position.Y < box.Minimum.Y || ray.Position.Y > box.Maximum.Y)
				{
					distance = 0.f;
					return false;
				}
			}
			else
			{
				float inverse = 1.0f / ray.Direction.Y;
				float t1 = (box.Minimum.Y - ray.Position.Y) * inverse;
				float t2 = (box.Maximum.Y - ray.Position.Y) * inverse;

				if (t1 > t2)
				{
					float temp = t1;
					t1 = t2;
					t2 = temp;
				}

				distance = Math.Max(t1, distance);
				tmax = Math.Min(t2, tmax);

				if (distance > tmax)
				{
					distance = 0.f;
					return false;
				}
			}

			if (Math.Abs(ray.Direction.Z) < _zeroTolerance)
			{
				if (ray.Position.Z < box.Minimum.Z || ray.Position.Z > box.Maximum.Z)
				{
					distance = 0.f;
					return false;
				}
			}
			else
			{
				float inverse = 1.0f / ray.Direction.Z;
				float t1 = (box.Minimum.Z - ray.Position.Z) * inverse;
				float t2 = (box.Maximum.Z - ray.Position.Z) * inverse;

				if (t1 > t2)
				{
					float temp = t1;
					t1 = t2;
					t2 = temp;
				}

				distance = Math.Max(t1, distance);
				tmax = Math.Min(t2, tmax);

				if (distance > tmax)
				{
					distance = 0.f;
					return false;
				}
			}

			return true;
		}

		public static bool RayIntersectsBox(Ray ray, Box box, out float3 point)
		{
			float distance;
			if (!RayIntersectsBox(ray, box, out distance))
			{
				point = float3(0);
				return false;
			}

			point = ray.Position + (ray.Direction * distance);
			return true;
		}

		public static bool RayIntersectsSphere(Ray ray, Sphere sphere, out float distance)
		{
			float3 v = ray.Position - sphere.Center;

			float b = Vector.Dot(v, ray.Direction);
			float c = Vector.Dot(v, v) - (sphere.Radius * sphere.Radius);

			if (c > 0.f && b > 0.f)
			{
				distance = 0.f;
				return false;
			}

			float discriminant = b * b - c;

			if (discriminant < 0.f)
			{
				distance = 0.f;
				return false;
			}

			distance = -b - (float)Math.Sqrt(discriminant);

			if (distance < 0.f)
			distance = 0.f;

			return true;
		}

		public static bool RayIntersectsSphere(Ray ray, Sphere sphere, out float3 point)
		{
			float distance;
			if (!RayIntersectsSphere(ray, sphere, out distance))
			{
				point = float3(0);
				return false;
			}

			point = ray.Position + (ray.Direction * distance);
			return true;
		}

		public static bool RayIntersectsSphere(Ray ray, Sphere sphere, out float3 point, out float3 normal)
		{
			float distance;
			if (!RayIntersectsSphere(ray, sphere, out distance))
			{
				point = float3(0);
				normal = float3(0);
				return false;
			}

			point = ray.Position + (ray.Direction * distance);
			normal = Vector.Normalize(point - sphere.Center);
			return true;
		}

		public static bool RayIntersectsSphere(Ray ray, Sphere sphere, out float3 entrancePoint, out float3 entranceNormal, out float3 exitPoint, out float3 exitNormal)
		{
			float3 v = ray.Position - sphere.Center;

			float b = Vector.Dot(v, ray.Direction);
			float c = Vector.Dot(v, v) - (sphere.Radius * sphere.Radius);

			if (c > 0.f && b > 0.f)
			{
				entrancePoint = float3(0);
				entranceNormal = float3(0);
				exitPoint = float3(0);
				exitNormal = float3(0);
				return false;
			}

			float discriminant = b * b - c;

			if (discriminant < 0.f)
			{
				entrancePoint = float3(0);
				entranceNormal = float3(0);
				exitPoint = float3(0);
				exitNormal = float3(0);
				return false;
			}

			float discriminantSquared = Math.Sqrt(discriminant);
			float distance1 = -b - discriminantSquared;
			float distance2 = -b + discriminantSquared;

			if (distance1 < 0.f)
			{
				distance1 = 0.f;
				entrancePoint = float3(0);
				entranceNormal = float3(0);
			}
			else
			{
				entrancePoint = ray.Position + (ray.Direction * distance1);
				entranceNormal = Vector.Normalize(entrancePoint - sphere.Center);
			}

			exitPoint = ray.Position + (ray.Direction * distance2);
			exitNormal = Vector.Normalize(exitPoint - sphere.Center);

			return true;
		}

		public static PlaneIntersectionType PlaneIntersectsPoint(Plane plane, float3 point)
		{
			float distance = Vector.Dot(plane.Normal, point) + plane.D;

			if (distance > 0.f)
			return PlaneIntersectionType.Front;

			if (distance < 0.f)
			return PlaneIntersectionType.Back;

			return PlaneIntersectionType.Intersecting;
		}

		public static bool PlaneIntersectsPlane(Plane plane1, Plane plane2)
		{
			float3 direction = Vector.Cross(plane1.Normal, plane2.Normal);

			//If direction is the zero vector, the planes are parallel and possibly
			//coincident. It is not an intersection. The dot product will tell us.
			float denominator = Vector.Dot(direction, direction);

			if (Math.Abs(denominator) < _zeroTolerance)
			return false;

			return true;
		}

		public static bool PlaneIntersectsPlane(Plane plane1, Plane plane2, out Ray line)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 207

			float3 direction = Vector.Cross(plane1.Normal, plane2.Normal);

			//If direction is the zero vector, the planes are parallel and possibly
			//coincident. It is not an intersection. The dot product will tell us.
			float denominator = Vector.Dot(direction, direction);

			//We assume the planes are normalized, therefore the denominator
			//only serves as a parallel and coincident check. Otherwise we need
			//to deivide the point by the denominator.
			if (Math.Abs(denominator) < _zeroTolerance)
			{
				line = new Ray();
				return false;
			}

			float3 temp = plane2.Normal * plane1.D - plane1.Normal * plane2.D;
			float3 point = Vector.Cross(temp, direction);

			line.Position = point;
			line.Direction = Vector.Normalize(direction);

			return true;
		}

		public static PlaneIntersectionType PlaneIntersectsTriangle(Plane plane, Triangle triangle)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 207

			var test1 = PlaneIntersectsPoint(plane, triangle.A);
			var test2 = PlaneIntersectsPoint(plane, triangle.B);
			var test3 = PlaneIntersectsPoint(plane, triangle.C);

			if (test1 == PlaneIntersectionType.Front && test2 == PlaneIntersectionType.Front && test3 == PlaneIntersectionType.Front)
			return PlaneIntersectionType.Front;

			if (test1 == PlaneIntersectionType.Back && test2 == PlaneIntersectionType.Back && test3 == PlaneIntersectionType.Back)
			return PlaneIntersectionType.Back;

			return PlaneIntersectionType.Intersecting;
		}

		public static PlaneIntersectionType PlaneIntersectsBox(Plane plane, Box box)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 161

			float3 min;
			float3 max;

			max.X = plane.Normal.X >= 0.0f ? box.Minimum.X : box.Maximum.X;
			max.Y = plane.Normal.Y >= 0.0f ? box.Minimum.Y : box.Maximum.Y;
			max.Z = plane.Normal.Z >= 0.0f ? box.Minimum.Z : box.Maximum.Z;
			min.X = plane.Normal.X >= 0.0f ? box.Maximum.X : box.Minimum.X;
			min.Y = plane.Normal.Y >= 0.0f ? box.Maximum.Y : box.Minimum.Y;
			min.Z = plane.Normal.Z >= 0.0f ? box.Maximum.Z : box.Minimum.Z;

			float distance = Vector.Dot(plane.Normal, max);

			if (distance + plane.D > 0.0f)
			return PlaneIntersectionType.Front;

			distance = Vector.Dot(plane.Normal, min);

			if (distance + plane.D < 0.0f)
			return PlaneIntersectionType.Back;

			return PlaneIntersectionType.Intersecting;
		}

		public static PlaneIntersectionType PlaneIntersectsSphere(Plane plane, Sphere sphere)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 160

			float distance = Vector.Dot(plane.Normal, sphere.Center);
			distance += plane.D;

			if (distance > sphere.Radius)
			return PlaneIntersectionType.Front;

			if (distance < -sphere.Radius)
			return PlaneIntersectionType.Back;

			return PlaneIntersectionType.Intersecting;
		}

		//THIS IMPLEMENTATION IS INCOMPLETE!
		//NEEDS TO BE COMPLETED SOON
		public static bool BoxIntersectsTriangle(Box box, Triangle triangle)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 169

			float p0, /*p1,*/ p2, r;

			//Compute box center and extents (if not already given in that format)
			float3 center = (box.Minimum + box.Maximum) * 0.5f;
			float e0 = (box.Maximum.X - box.Minimum.X) * 0.5f;
			float e1 = (box.Maximum.Y - box.Minimum.Y) * 0.5f;
			float e2 = (box.Maximum.Z - box.Minimum.Z) * 0.5f;

			//Translate triangle as conceptually moving AABB to origin
			float3 vertex1 = triangle.A - center;
			float3 vertex2 = triangle.B - center;
			float3 vertex3 = triangle.C - center;

			//Compute edge vectors for triangle
			float3 f0 = vertex2 - vertex1;
			float3 f1 = vertex3 - vertex2;
			//float3 f2 = vertex1 - vertex3;

			//Test axes a00..a22 (category 3)
			//Test axis a00
			p0 = vertex1.Z * vertex2.Y - vertex1.Y * vertex2.Z;
			p2 = vertex3.Z * (vertex2.Y - vertex1.Y) - vertex3.Z * (vertex2.Z - vertex1.Z);
			r = e1 * Math.Abs(f0.Z) + e2 * Math.Abs(f0.Y);

			if (Math.Max(-Math.Max(p0, p2), Math.Min(p0, p2)) > r)
			return false; //Axis is a separating axis

			//Repeat similar tests for remaining axes a01..a22
			//...

			//Test the three axes corresponding to the face normals of AABB b (category 1).
			//Exit if...
			// ... [-e0, e0] and [Math.Min(vertex1.X,vertex2.X,vertex3.X), Math.Max(vertex1.X,vertex2.X,vertex3.X)] do not overlap
			if (Math.Max(Math.Max(vertex1.X, vertex2.X), vertex3.X) < -e0 || Math.Min(Math.Min(vertex1.X, vertex2.X), vertex3.X) > e0)
			return false;

			// ... [-e1, e1] and [Math.Min(vertex1.Y,vertex2.Y,vertex3.Y), Math.Max(vertex1.Y,vertex2.Y,vertex3.Y)] do not overlap
			if (Math.Max(Math.Max(vertex1.Y, vertex2.Y), vertex3.Y) < -e1 || Math.Min(Math.Min(vertex1.Y, vertex2.Y), vertex3.Y) > e1)
			return false;

			// ... [-e2, e2] and [Math.Min(vertex1.Z,vertex2.Z,vertex3.Z), Math.Max(vertex1.Z,vertex2.Z,vertex3.Z)] do not overlap
			if (Math.Max(Math.Max(vertex1.Z, vertex2.Z), vertex3.Z) < -e2 || Math.Min(Math.Min(vertex1.Z, vertex2.Z), vertex3.Z) > e2)
			return false;

			//Test separating axis corresponding to triangle face normal (category 2)
			Plane plane;
			plane.Normal = Vector.Cross(f0, f1);
			plane.D = Vector.Dot(plane.Normal, vertex1);

			return PlaneIntersectsBox(plane, box) == PlaneIntersectionType.Intersecting;
		}

		public static bool BoxIntersectsBox(Box box1, Box box2)
		{
			if (box1.Minimum.X > box2.Maximum.X || box2.Minimum.X > box1.Maximum.X)
			return false;

			if (box1.Minimum.Y > box2.Maximum.Y || box2.Minimum.Y > box1.Maximum.Y)
			return false;

			if (box1.Minimum.Z > box2.Maximum.Z || box2.Minimum.Z > box1.Maximum.Z)
			return false;

			return true;
		}

		public static bool BoxIntersectsSphere(Box box, Sphere sphere)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 166

			float3 vector = Math.Clamp(sphere.Center, box.Minimum, box.Maximum);
			float distance = Distance.PointPointSquared(sphere.Center, vector);

			return distance <= sphere.Radius * sphere.Radius;
		}

		public static bool SphereIntersectsTriangle(Sphere sphere, Triangle triangle, out float3 point)
		{
			//Source: Real-Time Collision Detection by Christer Ericson
			//Reference: Page 167

			//Bug found: The center point of the sphere should be the fourth parameter while the vertices of the triangle should be the first three.
			ClosestPointOnTriangleToPoint(triangle, sphere.Center, out point);
			float3 v = point - sphere.Center;

			return Vector.Dot(v, v) <= sphere.Radius * sphere.Radius;
		}

		public static bool SphereIntersectsSphere(Sphere sphere1, Sphere sphere2)
		{
			float radiisum = sphere1.Radius + sphere2.Radius;
			return Distance.PointPointSquared(sphere1.Center, sphere2.Center) <= radiisum * radiisum;
		}

		public static ContainmentType BoxContainsPoint(Box box, float3 point)
		{
			if (box.Minimum.X <= point.X && box.Maximum.X >= point.X &&
			box.Minimum.Y <= point.Y && box.Maximum.Y >= point.Y &&
			box.Minimum.Z <= point.Z && box.Maximum.Z >= point.Z)
			{
				return ContainmentType.Contains;
			}

			return ContainmentType.Disjoint;
		}

		public static ContainmentType BoxContainsTriangle(Box box, Triangle triangle)
		{
			var test1 = BoxContainsPoint(box, triangle.A);
			var test2 = BoxContainsPoint(box, triangle.B);
			var test3 = BoxContainsPoint(box, triangle.C);

			if (test1 == ContainmentType.Contains && test2 == ContainmentType.Contains && test3 == ContainmentType.Contains)
			return ContainmentType.Contains;

			if (BoxIntersectsTriangle(box, triangle))
			return ContainmentType.Intersects;

			return ContainmentType.Disjoint;
		}

		public static ContainmentType BoxContainsBox(Box box1, Box box2)
		{
			if (box1.Maximum.X < box2.Minimum.X || box1.Minimum.X > box2.Maximum.X)
			return ContainmentType.Disjoint;

			if (box1.Maximum.Y < box2.Minimum.Y || box1.Minimum.Y > box2.Maximum.Y)
			return ContainmentType.Disjoint;

			if (box1.Maximum.Z < box2.Minimum.Z || box1.Minimum.Z > box2.Maximum.Z)
			return ContainmentType.Disjoint;

			if (box1.Minimum.X <= box2.Minimum.X && (box2.Maximum.X <= box1.Maximum.X &&
			box1.Minimum.Y <= box2.Minimum.Y && box2.Maximum.Y <= box1.Maximum.Y) &&
			box1.Minimum.Z <= box2.Minimum.Z && box2.Maximum.Z <= box1.Maximum.Z)
			{
				return ContainmentType.Contains;
			}

			return ContainmentType.Intersects;
		}

		public static ContainmentType BoxContainsSphere(Box box, Sphere sphere)
		{
			float3 vector = Math.Clamp(sphere.Center, box.Minimum, box.Maximum);
			float distance = Distance.PointPointSquared(sphere.Center, vector);

			if (distance > sphere.Radius * sphere.Radius)
			return ContainmentType.Disjoint;

			if ((((box.Minimum.X + sphere.Radius <= sphere.Center.X) && (sphere.Center.X <= box.Maximum.X - sphere.Radius)) && ((box.Maximum.X - box.Minimum.X > sphere.Radius) &&
			(box.Minimum.Y + sphere.Radius <= sphere.Center.Y))) && (((sphere.Center.Y <= box.Maximum.Y - sphere.Radius) && (box.Maximum.Y - box.Minimum.Y > sphere.Radius)) &&
			(((box.Minimum.Z + sphere.Radius <= sphere.Center.Z) && (sphere.Center.Z <= box.Maximum.Z - sphere.Radius)) && (box.Maximum.X - box.Minimum.X > sphere.Radius))))
			{
				return ContainmentType.Contains;
			}

			return ContainmentType.Intersects;
		}

		public static ContainmentType SphereContainsPoint(Sphere sphere, float3 point)
		{
			if (Distance.PointPointSquared(point, sphere.Center) <= sphere.Radius * sphere.Radius)
			return ContainmentType.Contains;

			return ContainmentType.Disjoint;
		}

		public static ContainmentType SphereContainsTriangle(Sphere sphere, Triangle triangle)
		{
			//Source: Jorgy343
			//Reference: None

			var test1 = SphereContainsPoint(sphere, triangle.A);
			var test2 = SphereContainsPoint(sphere, triangle.B);
			var test3 = SphereContainsPoint(sphere, triangle.C);

			if (test1 == ContainmentType.Contains && test2 == ContainmentType.Contains && test3 == ContainmentType.Contains)
			return ContainmentType.Contains;

			float3 point;
			if (SphereIntersectsTriangle(sphere, triangle, out point))
			return ContainmentType.Intersects;

			return ContainmentType.Disjoint;
		}

		public static ContainmentType SphereContainsBox(Sphere sphere, Box box)
		{
			float3 vector;

			if (!BoxIntersectsSphere(box, sphere))
			return ContainmentType.Disjoint;

			float radiussquared = sphere.Radius * sphere.Radius;
			vector.X = sphere.Center.X - box.Minimum.X;
			vector.Y = sphere.Center.Y - box.Maximum.Y;
			vector.Z = sphere.Center.Z - box.Maximum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Maximum.X;
			vector.Y = sphere.Center.Y - box.Maximum.Y;
			vector.Z = sphere.Center.Z - box.Maximum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Maximum.X;
			vector.Y = sphere.Center.Y - box.Minimum.Y;
			vector.Z = sphere.Center.Z - box.Maximum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Minimum.X;
			vector.Y = sphere.Center.Y - box.Minimum.Y;
			vector.Z = sphere.Center.Z - box.Maximum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Minimum.X;
			vector.Y = sphere.Center.Y - box.Maximum.Y;
			vector.Z = sphere.Center.Z - box.Minimum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Maximum.X;
			vector.Y = sphere.Center.Y - box.Maximum.Y;
			vector.Z = sphere.Center.Z - box.Minimum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Maximum.X;
			vector.Y = sphere.Center.Y - box.Minimum.Y;
			vector.Z = sphere.Center.Z - box.Minimum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			vector.X = sphere.Center.X - box.Minimum.X;
			vector.Y = sphere.Center.Y - box.Minimum.Y;
			vector.Z = sphere.Center.Z - box.Minimum.Z;

			if (Vector.LengthSquared(vector) > radiussquared)
			return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static ContainmentType SphereContainsSphere(Sphere sphere1, Sphere sphere2)
		{
			float distance = Distance.PointPoint(sphere1.Center, sphere2.Center);

			if (sphere1.Radius + sphere2.Radius < distance)
			return ContainmentType.Disjoint;

			if (sphere1.Radius - sphere2.Radius < distance)
			return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static ContainmentType FrustumContainsPoint(Frustum frustum, float3 point)
		{
			var rn = PlaneIntersectsPoint(frustum.Near, point);
			if (rn == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rn == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rf = PlaneIntersectsPoint(frustum.Far, point);
			if (rf == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rf == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rt = PlaneIntersectsPoint(frustum.Top, point);
			if (rt == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rt == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rb = PlaneIntersectsPoint(frustum.Bottom, point);
			if (rb == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rb == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rl = PlaneIntersectsPoint(frustum.Left, point);
			if (rl == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rl == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rr = PlaneIntersectsPoint(frustum.Right, point);
			if (rr == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rr == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static ContainmentType FrustumContainsTriangle(Frustum frustum, Triangle triangle)
		{
			var rn = PlaneIntersectsTriangle(frustum.Near, triangle);
			if (rn == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rn == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rf = PlaneIntersectsTriangle(frustum.Far, triangle);
			if (rf == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rf == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rt = PlaneIntersectsTriangle(frustum.Top, triangle);
			if (rt == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rt == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rb = PlaneIntersectsTriangle(frustum.Bottom, triangle);
			if (rb == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rb == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rl = PlaneIntersectsTriangle(frustum.Left, triangle);
			if (rl == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rl == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rr = PlaneIntersectsTriangle(frustum.Right, triangle);
			if (rr == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rr == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static ContainmentType FrustumContainsBox(Frustum frustum, Box box)
		{
			var rn = PlaneIntersectsBox(frustum.Near, box);

			if (rn == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;

			var rf = PlaneIntersectsBox(frustum.Far, box);

			if (rf == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;

			var rt = PlaneIntersectsBox(frustum.Top, box);

			if (rt == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;

			var rb = PlaneIntersectsBox(frustum.Bottom, box);

			if (rb == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;


			var rl = PlaneIntersectsBox(frustum.Left, box);

			if (rl == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;

			var rr = PlaneIntersectsBox(frustum.Right, box);

			if (rr == PlaneIntersectionType.Front)
			return ContainmentType.Disjoint;

			// We have to check for intersections after we know that we are not outside of the frustum
			// we should probably do this the other places aswell, but i don't have a test case

			if (rn == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;
			if (rf == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;
			if (rt == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;
			if (rb == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;
			if (rl == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;
			if (rr == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static ContainmentType FrustumContainsSphere(Frustum frustum, Sphere sphere)
		{
			var rn = PlaneIntersectsSphere(frustum.Near, sphere);
			if (rn == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rn == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rf = PlaneIntersectsSphere(frustum.Far, sphere);
			if (rf == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rf == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rt = PlaneIntersectsSphere(frustum.Top, sphere);
			if (rt == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rt == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rb = PlaneIntersectsSphere(frustum.Bottom, sphere);
			if (rb == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rb == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rl = PlaneIntersectsSphere(frustum.Left, sphere);
			if (rl == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rl == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			var rr = PlaneIntersectsSphere(frustum.Right, sphere);
			if (rr == PlaneIntersectionType.Front) return ContainmentType.Disjoint;
			else if (rr == PlaneIntersectionType.Intersecting) return ContainmentType.Intersects;

			return ContainmentType.Contains;
		}

		public static bool AreParallel( float3 a, float3 b, float tolerance = _zeroTolerance * 10)
		{
			var c = Vector.Cross( a, b );
			var l = c.X + c.Y + c.Z;
			return Math.Abs(l) < tolerance;
		}
	}
}
