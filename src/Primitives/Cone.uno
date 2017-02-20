using Uno;
using Uno.UX;
using Uno.Content.Models;

using Fuse.Drawing;
using Fuse.Drawing.Meshes;

namespace Fuse.Drawing.Primitives
{
	public block Cone
	{
		apply DefaultPrimitivesBlock;

		public float Size: 10.0f;
		public float3 Scale: float3(Size);

		ModelMesh MeshData: MeshGenerator.CreateCone(2.0f, 1.0f, 32, 32);
	}
}
