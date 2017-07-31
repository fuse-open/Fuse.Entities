using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse.Entities;
using Uno.Content;
using Uno.Content.Models;
using Uno.UX;

namespace Fuse.Entities
{
	public interface ILightVisitor
	{
		void Visit(Light light);
		void Visit(PointLight light);
		void Visit(DirectionalLight light);
		void Visit(SpotLight light);
		void Visit(EnvironmentLight light);
	}

	public abstract class Light : Component
	{
		public float Range { get; set; }

		public float3 Color { get; set; }

		public float Multiplier { get; set; }

		public bool CastShadow { get; set; } // TODO: should be extension property?

		public float ShadowMapNearPlane { get; set; } // TODO: should be extension property?

		public int ShadowMapResolution { get; set; } // TODO: should be extension property?

		public float ShadowMapDepthBias { get; set; } // TODO: should be extension property?

		//[Range(0,1), Group("Shadows"), DesignerName("Dithering")]
		//public float ShadowMapDithering	 { get; set; } // TODO: should be extension property?

		bool showSprite = true;
		public bool ShowDesignerSprite { get { return showSprite; } set { showSprite = value; } }

		protected Light()
		{
			Color = float3(1,1,1);
			Multiplier = 1.0f;
			ShadowMapResolution = 1024;
			ShadowMapDepthBias = 0.5f;
			ShadowMapNearPlane = 10.0f;
			//ShadowMapDithering = 1.0f;
		}

		public virtual void Accept(ILightVisitor visitor)
		{
			visitor.Visit(this);
		}
	}

	public class EnvironmentLight : Light
	{
		public TextureCube EnvironmentMap;

		public override void Accept(ILightVisitor visitor)
		{
			visitor.Visit(this);
		}
	}

	public class SpotLight : Light
	{
		public float Extent { get; set; }

		public SpotLight()
		{
			Range = 500.0f;
			Extent = 90.0f;
		}

		public override void Accept(ILightVisitor visitor)
		{
			visitor.Visit(this);
		}

	}

	public class PointLight : Light
	{
		public PointLight()
		{
			Range = 200.0f;
		}

		public override void Accept(ILightVisitor visitor)
		{
			visitor.Visit(this);
		}
	}

	public class DirectionalLight : Light
	{
		public Box Box { get; set; }

		public DirectionalLight()
		{
			Box = new Box(float3(-100,-100,0), float3(100,100,5000));
		}

		public override void Accept(ILightVisitor visitor)
		{
			visitor.Visit(this);
		}
	}
}
