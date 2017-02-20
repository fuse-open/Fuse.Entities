using Uno;
using Uno.UX;
using Uno.Content.Models;

using Fuse.Drawing;
using Fuse.Drawing.Meshes;

namespace Fuse.Drawing.Primitives
{
	public block Cube
	{
		apply DefaultPrimitivesBlock;

		public float Size: 10.0f;
		public float3 Scale: float3(Size);

		ModelMesh MeshData: MeshGenerator.CreateCube(float3(0.0f), .5f);
	}

	public block WireCube
	{

		float3[] verts: new []
		{
			float3(-1,-1, -1),
			float3( 1,-1, -1),
			float3( 1, 1, -1),
			float3(-1, 1, -1),
			float3(-1,-1,  1),
			float3( 1,-1,  1),
			float3( 1, 1,  1),
			float3(-1, 1,  1)
		};

		ushort[] indices : new ushort[]
		{
			0,1, 1,2, 2,3, 3,0,
			4,5, 5,6, 6,7, 7,4,
			0,4, 1,5, 2,6, 3,7,
		};

		PrimitiveType: Uno.Graphics.PrimitiveType.Lines;
		public float3 VertexPosition: vertex_attrib(verts, indices);

	}

	public block SolidCube
	{
		float3[] verts: new []
		{
			float3(-1,-1, -1),
			float3( 1,-1, -1),
			float3( 1, 1, -1),
			float3(-1, 1, -1),
			float3(-1,-1,  1),
			float3( 1,-1,  1),
			float3( 1, 1,  1),
			float3(-1, 1,  1)
		};

		ushort[] indices : new ushort[]
		{
			0,1,2,2,3,0,
			1,5,6,6,2,1,
			4,7,6,6,5,4,
			0,3,7,7,4,0,
			5,1,0,0,4,5,
			2,6,7,7,3,2,
		};
		PrimitiveType: Uno.Graphics.PrimitiveType.Triangles;
		public float3 Corners: vertex_attrib(verts, indices);
		//public Uno.Graphics.PrimitiveType PrimitiveType: Uno.Graphics.PrimitiveType.Lines;
		public float3 VertexPosition : Corners;
	}
}
