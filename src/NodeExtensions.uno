using Uno;

namespace Fuse.Entities
{
	public static class NodeExtensions
	{
		public static bool IsInSubtreeOf(this Node self, Node parent)
		{
			for (var p = self; p != null; p = p.Parent)
			{
				if (p == parent)
					return true;
			}
			//debug_log self + " is not in subtree of " + parent + " (parent is "+(self != null ? self.Parent.ToString() : "") +")";

			return false;
		}
	}

	class VisitPredicate<T> : VisitType<T>
	{
		Predicate<T> _visit;
		public VisitPredicate(Predicate<T> visit) { _visit = visit; }
		protected override bool Visit(T t) { return _visit(t); }
	}

	class VisitAction<T> : VisitType<T>
	{
		Action<T> _visit;
		public VisitAction(Action<T> visit) { _visit = visit; }
		protected override bool Visit(T t) { _visit(t); return false; }
	}

	abstract class VisitType<T>
	{
		public bool Visit(Node node)
		{
			if (node is T)
				return Visit((T)node);
			return false;
		}
		protected abstract bool Visit(T node);
	}
}
