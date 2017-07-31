using Uno;
using Uno.UX;

namespace Fuse.Entities
{
	public class Scene : RenderNode, IViewport, IRenderViewport
	{
		extern (MOBILE) public event Uno.EventHandler WindowResized
		{
			add { Fuse.Platform.SystemUI.FrameChanged += value; }
			remove { Fuse.Platform.SystemUI.FrameChanged -= value; }
		}

		extern (!MOBILE) public event Uno.EventHandler WindowResized
		{
			add { Uno.Application.Current.Window.Resized += value; }
			remove { Uno.Application.Current.Window.Resized -= value; }
		}

		public Entity Camera { get; set; }

		public bool AlwaysUseOwnCamera { get; set; }

		public bool AlwaysClear { get; set; }

		public float4 ClearColor { get; set; }

		public Scene()
		{
			ClearColor = float4(1);
		}

		bool HasCamera { get { return Camera != null && Camera.FrustumComponent != null; } }

		protected override void OnDraw(DrawContext dc)
		{
			if (AlwaysClear)
				dc.Clear(ClearColor, 1);

			if (HasCamera)
				dc.PushViewport(this);
			base.OnDraw(dc);

			if (HasCamera)
				dc.PopViewport();
		}

		protected override void OnHitTest(HitTestContext args)
		{
			var w = Viewport;
			if (w == null)
				return;

			var ray = PointToWorldRay(args.WindowPoint);
			var oldRay = args.PushWorldRay(ray);
			base.OnHitTest(args);
			args.PopWorldRay(oldRay);
		}

		/*public override VisualBounds HitTestBounds
		{
			get { return VisualBounds.Infinite; }
		}*/

		public float2 Size { get { return Parent.Viewport.Size; } }
		public float2 PixelSize { get { return Parent.Viewport.PixelSize; } }
		public float PixelsPerPoint { get { return Parent.Viewport.PixelsPerPoint; } }

		public float4x4 ProjectionTransform
		{
			get
			{
				float4x4 result;
				if (Camera.FrustumComponent.TryGetProjectionTransform(this, out result))
					return result;
				else
					return float4x4.Identity;
			}
		}

		float4x4 ProjectionTransformInverse
		{
			get
			{
				float4x4 result;
				if (Camera.FrustumComponent.TryGetProjectionTransformInverse(this, out result))
					return result;
				else
					return float4x4.Identity;
			}
		}

		public float4x4 ViewProjectionTransform
		{
			get { return Matrix.Mul(ViewTransform,ProjectionTransform); }
		}

		float4x4 ViewProjectionTransformInverse
		{
			get { return Matrix.Mul(ProjectionTransformInverse,ViewTransformInverse); }
		}

		public float4x4 ViewTransform
		{
			get { return Camera.FrustumComponent.GetViewTransform(this); }
		}

		float4x4 ViewTransformInverse
		{
			get { return Camera.FrustumComponent.GetViewTransformInverse(this); }
		}

		public Ray PointToWorldRay(float2 pointPos)
		{
			var pr = Parent.Viewport.PointToWorldRay(pointPos);
			var local = Parent.Viewport.WorldToLocalRay(Parent.Viewport, pr, this);
			pointPos = ViewportHelpers.LocalPlaneIntersection(local);

			var r = ViewportHelpers.PointToWorldRay(this, ViewProjectionTransformInverse, pointPos);
			return r;
		}

		public Ray WorldToLocalRay(IViewport world, Ray worldRay, Visual where)
		{
			return ViewportHelpers.WorldToLocalRay(this, world, worldRay, where);
		}

		public float3 ViewOrigin
		{
			get { return Camera.FrustumComponent.GetWorldPosition(this); }
		}

		public float2 ViewRange
		{
			get { return Camera.FrustumComponent.GetDepthRange(this); }
		}
	}
}
