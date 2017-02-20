using Uno;
using Uno.Graphics;
using Uno.UX;
using Fuse.Drawing.Primitives;

namespace Fuse.Entities
{
	public class RenderToTexture: RenderNode
	{
		framebuffer fb;

		int2 resolution;
		public int2 Resolution
		{
			get
			{
				return resolution;
			}
			set
			{
				if (resolution != value)
				{
					resolution = (int2)Math.Max(int2(0), Math.Min(value, int2(2048,2048)));
					if (fb != null) fb.Dispose();
					fb = new framebuffer(resolution, PixelFormat, FramebufferFlags.DepthBuffer);
				}
			}
		}

		Format format = Format.RGBA8888;
		public Format PixelFormat
		{
			get { return format; }
			set { format = value; }
		}

		bool depth = true;
		public bool DepthBuffer
		{
			get { return depth; }
			set { depth = value; }
		}

		public bool Clear { get; set; }

		public float4 ClearColor { get; set; }

		public float ClearDepth { get; set; }

		public RenderToTexture()
		{
			Clear = true;
			ClearDepth = 1.0f;
			Resolution = int2(128, 128);
		}

		public bool FlipVertically { get; set; }

		protected override void OnDraw(DrawContext dc)
		{
			if (FlipVertically)
			{
				var tempfb = FramebufferPool.Lock(resolution.X, resolution.Y, format, depth);

				dc.PushRenderTarget(tempfb);
				if (Clear) dc.Clear(ClearColor, ClearDepth);
				base.OnDraw(dc);
				dc.PopRenderTarget();

				dc.PushRenderTarget(fb);
				BlitFlipped(tempfb.ColorBuffer);
				dc.PopRenderTarget();

				FramebufferPool.Release(tempfb);
			}
			else
			{
				dc.PushRenderTarget(fb);
				if (Clear) dc.Clear(ClearColor, ClearDepth);
				base.OnDraw(dc);
				dc.PopRenderTarget();
			}
		}

		void BlitFlipped(texture2D tex)
		{
			draw this, Quad
			{
				DepthTestEnabled: false;
				CullFace: PolygonFace.None;
				float2 tc: VertexPosition.XY * float2(0.5f, -0.5f) + 0.5f;
				PixelColor: sample(tex, tc);
			};
		}

		public texture2D Result
		{
			get
			{
				if (fb != null) return fb.ColorBuffer;
				else return null;
			}
		}

		Entity raycastTarget;
		public Entity EventRaycastTarget
		{
			get { return raycastTarget; }
			set
			{
				raycastTarget = value;
			}
		}
	}
}
