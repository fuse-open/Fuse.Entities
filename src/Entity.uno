using Uno;
using Uno.Collections;
using Uno.UX;

using Fuse.Entities.Geometry;

namespace Fuse.Entities
{
	public class Entity : Visual
	{
		//optimization to avoid repeated lookups in Scene
		IFrustum _frustumComponent;
		internal IFrustum FrustumComponent
		{
			get
			{
				if (_frustumComponent == null)
					_frustumComponent = FindComponent<IFrustum>();
				return _frustumComponent;
			}
		}

		public Entity() {}

		public Entity(params Component[] initComponents)
		{
			if (initComponents != null)
				for (int i = 0; i < initComponents.Length; i++) Children.Add(initComponents[i]);
		}

		public override void Draw(DrawContext dc)
		{
			for (int i = 0; i < Children.Count; i++)
			{
				var v = Children[i] as Visual;
				if (v != null) v.Draw(dc);
			}
		}

		public static Entity FromModel(Uno.Content.Models.Model model)
		{
			return new Internal.SceneGraphBuilder().Build(model);
		}

		public void FindAllComponents<T>(Action<T> callback, bool recursive)
		{
			for (int i = 0; i < Children.Count; i++)
				if (Children[i] is T) callback((T)Children[i]);

			if (recursive && HasChildren)
				for (int i = 0; i < Children.Count; i++)
					if (Children[i] is Entity) (Children[i] as Entity).FindAllComponents(callback, recursive);
		}

		public T FindComponent<T>() where T : object
		{
			for (int i = 0; i < Children.Count; i++)
				if (Children[i] is T)
					return (T)(object)Children[i];
			return null;
		}

		public Entity ParentEntity
		{
			get
			{
				return Parent as Entity;
			}
		}

		public float4 WorldRotationQuaternion
		{
			get
			{
				float3 scale, translation;
				float4 rotation;
				Matrix.Decompose(WorldTransform, out scale, out rotation, out translation);

				return rotation;
			}
			set
			{
				var parentToAbs = ParentEntity != null ? ParentEntity.WorldRotationQuaternion : float4(0,0,0,1);
				var absToParent = Vector.Normalize( Quaternion.Invert( parentToAbs ) );
				Transform.RotationQuaternion = Quaternion.Mul( value, absToParent );
			}
		}


		public float3 WorldRight
		{
			get { return Vector.Normalize(Vector.TransformNormal(float3(1, 0, 0), WorldTransform)); }
		}


		public float3 WorldUp
		{
			get { return Vector.Normalize(Vector.TransformNormal(float3(0, 1, 0), WorldTransform)); }
		}


		public float3 WorldForward
		{
			get { return Vector.Normalize(Vector.TransformNormal(float3(0, 0, -1), WorldTransform)); }
		}

		public Frustum Frustum
		{
			get
			{
				for (int i = 0; i < Children.Count; i++)
				{
					if (Children[i] is Frustum) return (Frustum)Children[i];
				}
				return null;
			}
		}
		public Transform3D Transform

		{
			get
			{
				for (int i = Children.Count; i --> 0; )
				{
					if (Children[i] is Transform3D) return (Transform3D)Children[i];
				}
				return null;
			}
		}

		public MeshRenderer MeshRenderer { get; private set; }

		public override VisualBounds HitTestBounds
		{
			//safe option for now
			get { return VisualBounds.Infinite; }
		}

		public override Box LocalBounds
		{
			get
			{
				// TODO: this should compound child+component bounds
				return new Box(float3(0), float3(0));
			}
		}
	}
}
