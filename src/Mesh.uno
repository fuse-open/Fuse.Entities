using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Content.Models;
using Uno.Collections.EnumerableExtensions;

using Fuse.Drawing.Batching;

namespace Fuse.Entities
{
	public class Mesh : IDisposable
	{
		readonly ModelDrawable _drawable;
		public ModelDrawable Drawable { get { return _drawable; } }

		internal ModelMesh ModelMesh { get { return _drawable.Mesh; } }

		bool _meshBoxDirty = true;
		Uno.Geometry.Box _meshBox;

		bool isDirty = true;
		Batch[] batches;
		MeshBatcher batcher = null;

		public void Dispose()
		{
			// TODO
		}

		public Uno.Geometry.Box BoundingBox
		{
			get
			{
				if (_meshBoxDirty)
				{
					_meshBox = ModelMeshHelpers.CalculateAABB(ModelMesh);
					_meshBoxDirty = false;
				}
				return _meshBox;
			}
		}

		bool _meshSphereDirty = true;
		Uno.Geometry.Sphere _meshSphere;

		public Uno.Geometry.Sphere BoundingSphere
		{
			get
			{
				if (_meshSphereDirty)
				{
					_meshSphere = ModelMeshHelpers.CalculateBoundingSphere(ModelMesh);
					_meshSphereDirty = false;
				}
				return _meshSphere;
			}
		}

		public Batch[] Batches
		{
			get
			{
				if (isDirty) Flush();
				return batches ?? ToArray(batcher.Batches);
			}
		}

		public Batch FirstBatch
		{
			get { return Batches[0]; }
		}

		public Mesh(ModelMesh modelMesh)
			: this (new ModelDrawable(modelMesh))
		{ }

		public Mesh(ModelDrawable modelDrawable)
		{
			_drawable = modelDrawable;
		}

		public void Invalidate()
		{
			isDirty = true;
		}

		public void Flush()
		{
			if (!isDirty) return;

			if (ModelMesh != null && ModelMesh.Indices != null && ModelMesh.Indices.Type == IndexType.UInt)
			{
				batcher = new MeshBatcher();
				batcher.AddMesh(ModelMesh);
				batcher.Flush();
				batches = null;
			}
			else
			{
				batcher = null;
				batches = new [] { BatchHelpers.CreateSingleBatch(ModelMesh) };
			}
			isDirty = false;
			_meshBoxDirty = true;
			_meshSphereDirty = true;
		}
	}
}
