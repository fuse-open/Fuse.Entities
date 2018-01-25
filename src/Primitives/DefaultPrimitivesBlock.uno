using Uno.Content.Models;

using Fuse.Drawing.Batching;

namespace Fuse.Drawing.Primitives
{
	public block DefaultPrimitivesBlock
	{
		Batch SingleBatch : req (MeshData as ModelMesh) BatchHelpers.CreateSingleBatch(MeshData);
		apply SingleBatch;
	}
}
