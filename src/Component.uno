using Uno;
using Uno.Collections;
using Uno.UX;

namespace Fuse.Entities
{
	public abstract class Component: Behavior
	{
		public Entity Entity { get { return (Entity)Parent; } }
	}
}
