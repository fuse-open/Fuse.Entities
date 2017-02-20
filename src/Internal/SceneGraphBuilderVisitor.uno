using Uno;
using Uno.Collections;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;
using Uno.UX;
using Fuse.Drawing;

namespace Fuse.Entities.Internal
{
	public class SceneGraphBuilderVisitor
	{
		readonly List<Entity> _entities = new List<Entity>();

		public void Push(Entity e) { _entities.Add(e); }
		public void Pop() { _entities.RemoveLast(); }
		public Entity Peek { get { return _entities.Count == 0 ? null : _entities.Last(); } }

		public virtual void Visit(Entity e) { }
		public virtual void Visit(Entity e, ModelNode n) { Visit(e); }

		public virtual void Visit(Transform3D t) { }
		public virtual void Visit(Transform3D t, ModelNode n) { Visit(t); }

		public virtual void Visit(Material m) { }
		public virtual void Visit(Material m, ModelNode n) { Visit(m); }

		public virtual void Visit(MeshRenderer m) { }
		public virtual void Visit(Mesh m, ModelDrawable d) { }
	}
}
