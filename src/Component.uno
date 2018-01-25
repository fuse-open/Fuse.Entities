using Uno;

namespace Fuse.Entities
{
	public abstract class Component: Behavior
	{
		public Entity Entity { get { return (Entity)Parent; } }
	}
}
