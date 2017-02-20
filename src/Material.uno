using Uno;
using Uno.Graphics;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Entities
{
	public abstract class Material: PropertyObject
	{
		public virtual bool IsBatchable
		{
			get { return true; }
		}

		public virtual bool Draw(Mesh m, float4x4 transform)
		{
			return false;
		}

		//workaround to allow `draw` to get the DrawContext to the material (old method used
		//a static instance, which isn't good)
		public DrawContext DrawContext;
	}
}
