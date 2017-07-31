using Uno;
using Uno.Collections;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;
using Uno.UX;
using Fuse.Drawing;

namespace Fuse.Entities.Internal
{
	public class SceneGraphBuilder
	{
		readonly SceneGraphBuilderVisitor _visitor;

		public SceneGraphBuilder(SceneGraphBuilderVisitor visitor = null)
		{
			_visitor = visitor ?? new SceneGraphBuilderVisitor();
		}

		public Entity Build(Model model)
		{
			return CreateNode(model.Root, true);
		}

		Entity CreateNode(ModelNode node, bool isRoot = false)
		{
			var entity = new Entity();
			_visitor.Push(entity);

			foreach (var child in node.Children)
				entity.Children.Add(CreateNode(child));

			var transform = TryCreateCompositTransform(node);
			if (transform != null)
				entity.Children.Add(transform);
			else if (isRoot)
				entity.Children.Add(CreateTransform());

			if (isRoot)
				entity.Children.Add(CreateMeshRenderer(CreateMaterial()));

			foreach (var dr in node.Drawables)
				entity.Children.Add(CreateMeshRenderer(CreateMesh(dr)));

			_visitor.Pop();
			_visitor.Visit(entity, node);
			return entity;
		}

		Material CreateMaterial()
		{
			var m = new DefaultMaterial();
			_visitor.Visit(m);
			return m;
		}

		MeshRenderer CreateMeshRenderer(Material mat)
		{
			var mr = new MeshRenderer();
			mr.Material = mat;
			_visitor.Visit(mr);
			return mr;
		}

		MeshRenderer CreateMeshRenderer(Mesh mesh)
		{
			var mr = new MeshRenderer();
			mr.Mesh = mesh;
			_visitor.Visit(mr);
			return mr;
		}

		Mesh CreateMesh(ModelDrawable dr)
		{
			var mesh = new Mesh(dr);
			_visitor.Visit(mesh, dr);
			return mesh;
		}

		Transform3D CreateTransform()
		{
			var t = new Transform3D();
			_visitor.Visit(t);
			return t;
		}


		Transform3D TryCreateCompositTransform(ModelNode node)
		{
			var mat = MakeMatrix(node.Transforms);
			if (IsIdentity(mat))
			return null;

			float3 scaling;
			float4 rotationQuaternion;
			float3 translation;
			Matrix.Decompose(mat, out scaling, out rotationQuaternion, out translation);

			var t = new Transform3D();
			t.Position = translation;
			t.RotationDegrees = Uno.Quaternion.ToEulerAngleDegrees(rotationQuaternion);
			t.Scaling = scaling;
			_visitor.Visit(t, node);
			return t;
		}

		static Float4x4 MakeMatrix(IEnumerable<ModelParameter<float4x4>> transforms)
		{
			var mat = float4x4.Identity;
			foreach (var transform in transforms) // This might not work!
			mat = Matrix.Mul(mat, transform.Value);
			return mat;
		}

		static bool IsIdentity(float4x4 mat)
		{
			var id = float4x4.Identity;
			for (int i = 0; i < 4; i++)
			{
				var d = mat[i] - id[i];
				const float zeroTolerance = 1e-05f;
				if (Math.Abs(d.X) > zeroTolerance) return false;
				if (Math.Abs(d.Y) > zeroTolerance) return false;
				if (Math.Abs(d.Z) > zeroTolerance) return false;
				if (Math.Abs(d.W) > zeroTolerance) return false;
			}
			return true;
		}
	}
}
