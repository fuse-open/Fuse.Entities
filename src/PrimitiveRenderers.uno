using Uno;
using Uno.UX;
using Uno.Content.Models;

using Fuse.Drawing.Meshes;

namespace Fuse.Entities.Primitives
{
	public class CubeRenderer: MeshRenderer
	{
		public CubeRenderer()
		{
			Mesh = new Mesh(MeshGenerator.CreateCube(float3(0.0f), 5f));
			HitTestMode = MeshHitTestMode.BoundingBox;
		}
	}

	public class SphereRenderer: MeshRenderer
	{
		bool _isDirty = false;

		float _radius = 5.0f;
		public float Radius
		{
			get { return _radius; }
			set
			{
				if (_radius != value)
				{
					_radius = value;
					_isDirty = true;
				}
			}
		}

		int _quality = 16;
		public int Quality
		{
			get { return _quality; }
			set
			{
				if (_quality != value)
				{
					_quality = value;
					_isDirty = true;
				}
			}
		}

		public SphereRenderer()
		{
			HitTestMode = MeshHitTestMode.BoundingSphere;
		}

		protected override void Validate()
		{
			if (_isDirty || Mesh == null)
			{
				if (Mesh != null) Mesh.Dispose();
				Mesh = new Mesh(MeshGenerator.CreateSphere(float3(0.0f), _radius, _quality, _quality));
				_isDirty = false;
			}
		}
	}

	public class ConeRenderer: MeshRenderer
	{
		public ConeRenderer()
		{
			Mesh = new Mesh(MeshGenerator.CreateCone(10.0f, 5f, 16,16));
		}
	}

	public class CylinderRenderer: MeshRenderer
	{
		public CylinderRenderer()
		{
			Mesh = new Mesh(MeshGenerator.CreateCylinder(10.0f, 5f, 16,16));
		}
	}
}
