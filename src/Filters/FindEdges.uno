using Uno;
using Uno.UX;
using Fuse.Drawing.Primitives;

namespace Fuse.Entities.Filters
{
	public class FindEdges: RenderNode
	{
		public FindEdges()
		{
			Spread = 1;
			Strength = 0.25f;
			BackgroundColor = float4(0,0,0,0);
			EdgeColor = float4(1,1,1,1);
		}

		public float Spread { get; set; }

		public float Strength { get; set; }

		public float4 BackgroundColor { get; set; }

		public float4 EdgeColor { get; set; }

		public bool BlendEnabled { get; set; }
		public Uno.Graphics.BlendOperand BlendSrc { get; set; }
		public Uno.Graphics.BlendOperand BlendDst { get; set; }

		protected override void OnDraw(DrawContext dc)
		{
			var fb = FramebufferPool.Lock((int)dc.GLViewportPixelSize.X, (int)dc.GLViewportPixelSize.Y, Uno.Graphics.Format.RGBA8888, true);

			dc.PushRenderTarget(fb.RenderTarget);
			dc.Clear(float4(1,1,1,0), 1);
			base.OnDraw(dc);
			dc.PopRenderTarget();

			if (BlendEnabled)
			{
				base.OnDraw(dc);
				MeshBatchingEngine.FlushAllActive();
			}

			draw this, Quad
			{
				float2 delta: float2(Spread / fb.Size.X, Spread / fb.Size.Y);
				TexCoord: float2(prev.X, 1.0f - prev.Y);

				float3 s1 : sample(fb.ColorBuffer, TexCoord).XYZ;
				float3 s2 : sample(fb.ColorBuffer, TexCoord + float2(delta.X, 0)).XYZ;
				float3 s3 : sample(fb.ColorBuffer, TexCoord + float2(0, delta.Y)).XYZ;
				float3 s4 : sample(fb.ColorBuffer, TexCoord + float2(-delta.X, 0)).XYZ;
				float3 s5 : sample(fb.ColorBuffer, TexCoord + float2(0, -delta.Y)).XYZ;

				float d1 : Vector.Length(s2 - s1);
				float d2 : Vector.Length(s3 - s1);
				float d3 : Vector.Length(s4 - s1);
				float d4 : Vector.Length(s5 - s1);

				float xx : Math.Min(1.0f, (d1+d2+d3+d4) * Strength);

				PixelColor: pixel(BackgroundColor * (1.0f - xx) + EdgeColor * xx);
			};

			FramebufferPool.Release(fb);
		}
	}
}
