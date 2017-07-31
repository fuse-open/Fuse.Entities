using Uno;
using Uno.UX;
using Uno.Vector;
using Uno.Math;

using Fuse.Entities.Geometry;

namespace Fuse.Entities
{
	public class Frustum: Component, IFrustum
	{
		float fovRadians;
		float aspect;
		float zNear;
		float zFar;

		public float FovRadians
		{
			get { return fovRadians; }
			set { fovRadians = value; }
		}

		public float FovDegrees
		{
			get { return FovRadians / (float)Math.PI * 180.0f; }
			set { FovRadians = value / 180.0f * (float)Math.PI; }
		}

		public float ZNear
		{
			get { return zNear; }
			set { zNear = value; }
		}

		public float ZFar
		{
			get { return zFar; }
			set { zFar = value; }
		}

		bool _hasExplicitAspect;
		public bool HasExplicitAspect
		{
			get { return _hasExplicitAspect; }
		}

		float _aspect = 1.0f;
		public float ExplicitAspect
		{
			get { return _aspect; }
			set
			{
				_aspect = value;
				_hasExplicitAspect = true;
			}
		}

		public void ResetExplicitAspect()
		{
			_hasExplicitAspect = false;
		}

		public Frustum(float fovRadians, float znear, float zfar)
		{
			FovRadians = fovRadians;
			ZNear = znear;
			ZFar = zfar;
		}

		public Frustum()
		{
			FovRadians = Uno.Math.PIf / 4.0f;
			ZNear = 1.0f;
			ZFar = 1000.0f;
		}

		public void Reset()
		{
			FovRadians = (float)Math.PI / 4.0f;
			ZNear = 1.0f;
			ZFar = 1000.0f;
		}

		public float4x4 View
		{
			get
			{
				return Entity.WorldTransformInverse;
			}
		}

		public float4x4 InverseView
		{
			get
			{
				return Entity.WorldTransform;
			}
		}

		// rect => [-1, 1]
		public Fuse.Entities.Geometry.Frustum GetFrustumGeometry(float aspect, Rect rect)
		{
			var position = Vector.TransformCoordinate(float3(0, 0, 0), InverseView);
			var xAxis = Vector.TransformNormal(float3(1,0,0), InverseView);
			var yAxis = Vector.TransformNormal(float3(0,1,0), InverseView);
			var zAxis = Vector.TransformNormal(float3(0,0,1), InverseView);

			float yScale = Math.Tan(fovRadians * 0.5f);
			float xScale = yScale * aspect;

			float halfWidthNear = zNear * xScale;
			float halfHeightNear = zNear * yScale;

			var fc = position + zAxis * zFar;
			var nc = position + zAxis * zNear;

			Fuse.Entities.Geometry.Frustum result;
			result.Near = new Plane(nc, -zAxis);
			result.Far = new Plane(fc, zAxis);

			result.Left = new Plane(position, Vector.Cross(Vector.Normalize(nc - xAxis * (halfWidthNear * rect.Left) - position), yAxis));
			result.Bottom = new Plane(position, Vector.Cross(Vector.Normalize(nc + yAxis * (halfHeightNear * rect.Bottom) - position), xAxis));

			result.Top = new Plane(position, Vector.Cross(xAxis, Vector.Normalize(nc + yAxis * (halfHeightNear * rect.Top) - position)));
			result.Right = new Plane(position, Vector.Cross(yAxis, Vector.Normalize(nc - xAxis * (halfWidthNear * rect.Right) - position)));

			result.Normalize();

			result.Near.Normal *= -1.0f;
			result.Near.D *= -1.0f;

			return result;
		}

		public Fuse.Entities.Geometry.Frustum GetFrustumGeometry(float aspect)
		{
			return GetFrustumGeometry(aspect, new Rect(-1, 1, 1, -1));
		}

		float ViewportAspect( ICommonViewport viewport )
		{
			return HasExplicitAspect ? ExplicitAspect : viewport.Size.X/viewport.Size.Y;
		}

		public bool TryGetProjectionTransform(ICommonViewport viewport, out float4x4 result)
		{
			result = Matrix.PerspectiveRH(FovRadians, ViewportAspect(viewport), ZNear, ZFar);
			return true;
		}

		public float4x4 GetViewTransform(ICommonViewport viewport)
		{
			return View;
		}

		public bool TryGetProjectionTransformInverse(ICommonViewport viewport, out float4x4 result)
		{
			//TODO: fix to produce directly!
			if (TryGetProjectionTransform(viewport, out result))
			{
				result = Matrix.Invert(result);
				return true;
			}
			return false;
		}

		public float4x4 GetViewTransformInverse(ICommonViewport viewport)
		{
			return InverseView;
		}

		public float2 GetDepthRange(ICommonViewport viewport)
		{
			return float2(ZNear, ZFar);
		}

		public float3 GetWorldPosition(ICommonViewport viewport)
		{
			return Entity.WorldPosition;
		}
	}
}
