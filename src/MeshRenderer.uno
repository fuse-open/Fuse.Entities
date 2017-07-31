using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.UX;
using Uno.Content;
using Uno.Content.Models;

using Fuse.Entities.Designer;
using Fuse.Drawing.Batching;

namespace Fuse.Entities
{
	public enum MeshHitTestMode
	{
		None,
		BoundingBox,
		BoundingSphere,
		Precise
	}

	public class MeshRenderer : Visual
	{
		Mesh _mesh;

		[UXPrimary]
		public Mesh Mesh
		{
			get { return _mesh; }
			set
			{
				if (value == _mesh) return;
				_mesh = value;
			}
		}

		public Entity Entity { get { return (Entity)Parent; } }

		MeshHitTestMode _hitTestMode = MeshHitTestMode.None;
		public MeshHitTestMode HitTestMode
		{
			get { return _hitTestMode; }
			set
			{
				_hitTestMode = value;
			}
		}

		Material _material;
		[UXContent]
		public Material Material
		{
			get
			{
				if (_material != null) return _material;

				var e = Entity;
				while (e != null)
				{
					e = e.ParentEntity;
					if (e != null && e.MeshRenderer != null)
						return e.MeshRenderer.Material;
				}

				return null;
			}
			set
			{
				_material = value;
			}
		}

		protected override VisualBounds HitTestLocalBounds
		{
			get
			{
				if (HitTestMode == MeshHitTestMode.None || _mesh == null)
					return VisualBounds.Empty;
				return VisualBounds.Infinite;
			}
		}

		protected override void OnHitTest(HitTestContext args)
		{
			if (HitTestMode == MeshHitTestMode.None)
				return;

			if (_mesh == null)
				return;

			var worldRay = Viewport.PointToWorldRay(args.WindowPoint);
			var objRay = Ray.Transform(worldRay, Entity.WorldTransformInverse);

			float distance;
			bool hit = Collision.RayIntersectsBox(objRay, _mesh.BoundingBox, out distance);

			if (hit)
			{
				if (HitTestMode == MeshHitTestMode.BoundingSphere)
				{
					hit = Fuse.Entities.Geometry.Collision.RayIntersectsSphere(objRay, _mesh.BoundingSphere, out distance);
				}
				else if (HitTestMode == MeshHitTestMode.Precise)
				{
					hit = ModelMeshCollision.RayIntersectsModelMesh(objRay, _mesh.ModelMesh, out distance);
				}

				var hitPoint = Vector.TransformCoordinate(objRay.Position + objRay.Direction * distance,
					Entity.WorldTransform);
				var dist = Vector.Length(hitPoint - args.WorldRay.Position);

				if (hit)
					args.Hit(Entity, dist);
			}
		}

		public bool RayIntersectWorldSpace(Ray worldSpaceRay, out float distance)
		{
			return RayIntersectObjectSpace(Ray.Transform(worldSpaceRay, Entity.WorldTransformInverse), out distance);
		}

		public bool RayIntersectObjectSpace(Ray objectSpaceRay, out float distance)
		{
			if (_mesh == null)
			{
				distance = 0;
				return false;
			}

			if (!Collision.RayIntersectsBox(objectSpaceRay, _mesh.BoundingBox, out distance))
				return false;

			if (!ModelMeshCollision.RayIntersectsModelMesh(objectSpaceRay, _mesh.ModelMesh, out distance))
				return false;

			return true;
		}

		//public bool NeverCull { get; set; }

		protected virtual void Validate() {}

		public override void Draw(DrawContext dc)
		{
			Validate();

			if (_mesh == null) return;
			if (Material == null) return;

			var m = Entity.WorldTransform;

			if (!Material.Draw(_mesh, m))
			{
				MeshBatchingEngine.Singleton.Draw(dc, _mesh, m, Material);
				MeshBatchingEngine.FlushAllActive();
			}
		}

		public void DrawDepthInternal(DrawContext dc)
		{
			if (_mesh == null) return;

			foreach(var batch in _mesh.Batches)
				DrawDepth(batch);
		}

		public void DrawSelectionCueInternal(bool isSelected, bool isPreviewSelected, bool isSelectedSubtree)
		{
			if (_mesh == null) return;
			foreach(var batch in _mesh.Batches)
				DrawSelectionCue(batch, isSelected, isPreviewSelected, isSelectedSubtree);
		}

		void DrawDepth(Batch batch)
		{
			draw this, DefaultShading, batch
			{
				World: Entity.WorldTransform;
				WriteRed: false;
				WriteGreen : false;
				WriteBlue : false;
				WriteAlpha : false;
				//float Pulse: f;
				//VertexPosition : prev + VertexNormal * f * 5f;
				//PixelColor : float4(0.8f, 0.85f, 1.0f+x , 0.01f+x*0.025f) * (1.0f-f) * 3.0f;

				PixelColor : float4(0.8f, 0.85f, 1.0f, 1.0f);
			};
		}

		void DrawSelectionCue(Batch batch, bool selected, bool previewSelected, bool selectedSubtree)
		{
			//float f = ((float)Uno.Application.FrameTime - selectionCool) / 0.22f;
			//f = f * f * f * f;
			//var x = Math.Min(1.0f, f);
			// 		f = Math.Max(0.00f, 0.5f - f);

			float alpha = 0.0f;

			if (selected)
				alpha = 0.8f;
			else
			{
				if (previewSelected)
					alpha += 0.2f;
				if (selectedSubtree)
					alpha += 0.2f;
			}


			draw this, DefaultShading, batch
			{
				World: Entity.WorldTransform;
				BlendEnabled : true;
				BlendSrc: BlendOperand.SrcAlpha;
				BlendDst: BlendOperand.OneMinusSrcAlpha;
				WriteAlpha: false;

				DepthFunc: CompareFunc.LessOrEqual;

				//float Pulse: f;
				//VertexPosition : prev + VertexNormal * f * 5f;
				//PixelColor : float4(0.8f, 0.85f, 1.0f+x , 0.01f+x*0.025f) * (1.0f-f) * 3.0f;

				PixelColor : float4(0.8f, 0.85f, 1.0f, alpha);
			};
		}

	}

}
