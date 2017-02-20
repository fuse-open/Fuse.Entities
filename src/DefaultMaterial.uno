using Uno;
using Uno.UX;
using Fuse.Drawing;

namespace Fuse.Entities
{
	public class DefaultMaterial: Material
	{
		apply DefaultShading;

		public float3 DiffuseColor { get; set; }

		public float3 SpecularColor { get; set; }

		public float Shininess { get; set; }

		public float2 Tiling { get; set; }

		public float2 Offset { get; set; }

		TexCoord : prev * Tiling + Offset;

		public bool IsEmissive { get; set; }

		public float3 EmissiveColor { get; set; }

		public texture2D DiffuseMap { get; set; }

		public texture2D NormalMap { get; set; }

		public texture2D SpecularMap { get; set; }

		public texture2D EmissiveMap { get; set; }

		public float3 EmissiveMapColor: sample(EmissiveMap, TexCoord).XYZ;

		public float3 MaterialEmissive : EmissiveMap != null
			? EmissiveColor * EmissiveMapColor
			: EmissiveColor;

		public float3 Emissive : MaterialEmissive;

		public DefaultMaterial()
		{
			Tiling = float2(1);
			DiffuseColor = float3(1);
			SpecularColor = float3(1);
			Shininess = 6;
		}
	}
}
