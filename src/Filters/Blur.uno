using Uno;
using Uno.Graphics;
using Uno.UX;
using Fuse.Drawing.Primitives;

namespace Fuse.Entities.Filters
{
	public class Blur: RenderNode
	{
		float _quality = 100;

		public float Quality
		{
			get { return _quality; }
			set
			{
				if (_quality != value)
				{
					_quality = value;
					if (_quality < 1) _quality = 1;
					if (_quality > 100) _quality = 100;
				}
			}
		}

		int _passes = 4;
		public int Passes
		{
			get { return _passes; }
			set
			{
				if (_passes != value)
				{
					_passes = value;
					if (_passes < 0) _passes = 0;
					if (_passes > 20) _passes = 20;
				}
			}
		}

		public float4 ClearColor { get; set; }

		public Blur()
		{
			ClearColor = float4(0,0,0,0);
		}

		public bool Glow { get; set; }

		protected override void OnDraw(DrawContext dc)
		{
			int width = (int)(dc.GLViewportPixelSize.X * Quality / 100.0f);
			int height = (int)(dc.GLViewportPixelSize.Y * Quality / 100.0f);
			if (width < 1) width = 1;
			if (height < 1) height = 1;

			var fb1 = FramebufferPool.Lock(width, height, Format.RGBA8888, true);
			var fb2 = FramebufferPool.Lock(width, height, Format.RGBA8888, false);

			dc.PushRenderTarget(fb1.RenderTarget);
			dc.Clear(ClearColor, 1);

			base.OnDraw(dc);

			dc.PopRenderTarget();

			for (int i = 1; i < Passes; i++)
			{
				dc.PushRenderTarget(fb2.RenderTarget);
				dc.Clear(float4(1,1,1,0), 1);
				DirectionalBlur(fb1.ColorBuffer, float2(0.5f, 0.0f));
				dc.PopRenderTarget();

				dc.PushRenderTarget(fb1.RenderTarget);
				dc.Clear(float4(1,1,1,0), 1);
				DirectionalBlur(fb2.ColorBuffer, float2(0.0f, 0.5f));
				dc.PopRenderTarget();
			}

			if (Glow)
			{
				base.OnDraw(dc);
				MeshBatchingEngine.FlushAllActive();
			}

			Blitter.Instance.Blit(fb1.ColorBuffer, Glow);

			FramebufferPool.Release(fb1);
			FramebufferPool.Release(fb2);
		}

		void DirectionalBlur(texture2D tex, float2 dir)
		{
			draw Quad
			{
				DepthTestEnabled: false;
				CullFace: PolygonFace.None;

				float2 tc: VertexPosition.XY * 0.5f + 0.5f;
				float2 delta: float2(dir.X / tex.Size.X, dir.Y / tex.Size.Y);

				PixelColor:
					sample(tex, tc + delta) +
					sample(tex, tc - delta) +
					sample(tex, tc + delta * 3) +
					sample(tex, tc - delta * 3);

				PixelColor: prev * .25f;
			};
		}
	}

	class Blitter
	{
		static Blitter _instance;
		public static Blitter Instance
		{
			get { return _instance ?? (_instance = new Blitter()); }
		}

		public void Blit(texture2D tex, bool blend)
		{
			draw Quad
			{
				BlendEnabled: blend;
				BlendSrc: BlendOperand.One;
				BlendDst: BlendOperand.One;
				DepthTestEnabled: false;
				CullFace: PolygonFace.None;
				float2 tc: VertexPosition.XY * 0.5f + 0.5f;
				PixelColor: sample(tex, tc);
			};
		}
	}
}
