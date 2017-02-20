using Uno;
using Uno.UX;
using Uno.Content.Models;

using Fuse.Drawing.Meshes;

namespace Fuse.Drawing.Primitives
{
	public block Sphere
	{
		apply DefaultPrimitivesBlock;

		public float Radius: prev, 10.0f;
		public float3 Scale: float3(Radius);

		int Slices: 32;
		int Stacks: 32;

		ModelMesh MeshData: MeshGenerator.CreateSphere(float3(0.0f), 1.0f, Slices, Stacks);
	}
}
