using Uno;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Entities
{
	/**
		Allows a combination of Element and non-Element visuals to be used at the root of an app. This creates a new world on the total available size.
	*/
	public class RenderNode: Visual
	{
		protected override void OnRooted()
		{
			base.OnRooted();
			//expect to draw every frame https://github.com/fusetools/fuselibs/issues/1286
			UpdateManager.AddAction(InvalidateVisual);
		}

		protected override void OnUnrooted()
		{
			UpdateManager.RemoveAction(InvalidateVisual);
			base.OnUnrooted();
		}

		public sealed override void Draw(DrawContext dc)
		{
			OnDraw(dc);
		}

		protected virtual void OnDraw(DrawContext dc)
		{
			for (int i = 0; i < ZOrderChildCount; i++)
				GetZOrderChild(i).Draw(dc);
		}

		override internal FastMatrix ParentWorldTransformInternal
		{
			get { return FastMatrix.Identity(); }
		}

		//this should prevent caching, though admittedly not a clear way to do this (we don't have another way)
		override internal bool CalcIsLocalFlat()
		{
			return false;
		}
	}
}
