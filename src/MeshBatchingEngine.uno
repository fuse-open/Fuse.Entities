using Uno;
using Uno.Collections;

using Fuse;
using Fuse.Drawing;
using Fuse.Drawing.Batching;

namespace Fuse.Entities
{
	struct Entry
	{
		public Mesh Mesh;
		public float4x4 World;
		public float4x4 WorldInverse;
		public Entry(Mesh m, float4x4 t, float4x4 worldInverse)
		{
			Mesh = m;
			World = t;
			WorldInverse = worldInverse;
		}
	}

	public class MeshBatchingEngine
	{
		static MeshBatchingEngine _singleton;
		public static MeshBatchingEngine Singleton
		{
			get { return _singleton ?? (_singleton = new MeshBatchingEngine()); }
		}

		Dictionary<Material, List<Entry>> drawLists = new Dictionary<Material, List<Entry>>();
		Dictionary<Mesh, MeshBatcher> batchers = new Dictionary<Mesh, MeshBatcher>();

		DrawContext _drawContext;
		static List<MeshBatchingEngine> _activeBatchEngines = new List<MeshBatchingEngine>();

		void OnRenderTargetChange(object sender, EventArgs args)
		{
			Flush(_drawContext);
		}

		public void Draw(DrawContext dc, Mesh mesh, float4x4 transform, Material material)
		{
			if (!material.IsBatchable)
			{
				Flush(dc);
			}

			List<Entry> list;
			if (!drawLists.TryGetValue(material, out list))
			{
				list = new List<Entry>();
				drawLists.Add(material, list);
			}

			list.Add(new Entry(mesh, transform, Matrix.Invert(transform)));

			if (list.Count == 1)
			{
				// first batched draw!

				if (_drawContext != null)
					throw new Exception("starting new batch, but previous batch was not flushed!");

				_activeBatchEngines.Add(this);
				dc.RenderTargetChange += OnRenderTargetChange;
				_drawContext = dc;
			}
		}

		public static void FlushAllActive()
		{
			var active = _activeBatchEngines.ToArray();
			foreach (var e in active)
				e.Flush(e._drawContext);
		}

		public void Flush(DrawContext dc)
		{
			foreach (var p in drawLists)
			{
				DrawList(dc, p.Key, p.Value);
			}

			drawLists.Clear();

			dc.RenderTargetChange -= OnRenderTargetChange;
			_activeBatchEngines.Remove(this);
			_drawContext = null;
		}

		void DrawList(DrawContext dc, Material material, List<Entry> entries)
		{
			if (entries.Count > 2)
			{
				var meshCounts = new Dictionary<Mesh, List<Entry>>();
				for (int i = 0; i < entries.Count; i++)
				{
					if (!meshCounts.ContainsKey(entries[i].Mesh)) meshCounts.Add(entries[i].Mesh, new List<Entry>());

					meshCounts[entries[i].Mesh].Add(entries[i]);
				}

				foreach (var p in meshCounts)
				{
					if (p.Key.ModelMesh.VertexCount > 20000 || p.Value.Count < 3)
					{
						DrawIndividual(dc, material, p.Value);
					}
					else
					{
						var batcher = FindOrCreateBatcher(p.Key);
						DrawBatched(dc, material, batcher, p.Value);
					}
				}
			}
			else
			{
				DrawIndividual(dc, material, entries);
			}
		}

		const int maxInstancesPerBatch = 16;

		int MeshVertexCount(Mesh mesh)
		{
			return (mesh.ModelMesh.IndexCount != -1 ? mesh.ModelMesh.IndexCount : mesh.ModelMesh.VertexCount);
		}

		MeshBatcher FindOrCreateBatcher(Mesh mesh)
		{
			MeshBatcher batcher;
			if (!batchers.TryGetValue(mesh, out batcher))
			{
				batcher = new MeshBatcher();
				batchers[mesh] = batcher;


				int instanceCount = (int)Math.Min(maxInstancesPerBatch, 65535 / Math.Max(1, MeshVertexCount(mesh)));
				for (int i = 0; i < instanceCount; i++) batcher.AddMesh(mesh.ModelMesh);

				batcher.Flush();
			}
			return batcher;
		}

		public void PrepareMesh(Mesh m)
		{
			FindOrCreateBatcher(m);
		}

		public float4x4[] worldArray = new float4x4[maxInstancesPerBatch];
		public float4x4[] normalArray = new float4x4[maxInstancesPerBatch];

		public fixed float4x4 fixedWorldArray[16] : fixed []
		{
			worldArray[0],
			worldArray[1],
			worldArray[2],
			worldArray[3],
			worldArray[4],
			worldArray[5],
			worldArray[6],
			worldArray[7],
			worldArray[8],
			worldArray[9],
			worldArray[10],
			worldArray[11],
			worldArray[12],
			worldArray[13],
			worldArray[14],
			worldArray[15]
		};

		public fixed float4x4 fixedNormalArray[16] : fixed []
		{
			normalArray[0],
			normalArray[1],
			normalArray[2],
			normalArray[3],
			normalArray[4],
			normalArray[5],
			normalArray[6],
			normalArray[7],
			normalArray[8],
			normalArray[9],
			normalArray[10],
			normalArray[11],
			normalArray[12],
			normalArray[13],
			normalArray[14],
			normalArray[15]
		};


		void DrawBatched(DrawContext dc, Material material, MeshBatcher batcher, List<Entry> entries)
		{
			for (int k = 0; k < maxInstancesPerBatch; k++)
				worldArray[k] = float4x4(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);

			int bc = 0;
			for (int i = 0; i < entries.Count; i++)
			{
				worldArray[bc] = entries[i].World;
				normalArray[bc] = entries[i].WorldInverse;
				bc++;

				if (bc >= batcher.EntryCount-1 || i == entries.Count-1)
				{
					var batch = Uno.Collections.EnumerableExtensions.FirstOrDefault(batcher.Batches);
					if (batch != null)
					{
						var vc = bc * MeshVertexCount(entries[0].Mesh);
						draw this,
							batch,
							virtual material,
							{
								float4x4 World:
									req(InstanceIndex as float)
									req(fixedWorldArray as fixed float4x4[])
									fixedWorldArray[(int)InstanceIndex];

								int iInstanceIndex : req (InstanceIndex as float)
									(int)InstanceIndex;

								float4x4 WorldInverse :
									req(iInstanceIndex as int)
									req(fixedNormalArray as fixed float4x4[])
									fixedNormalArray[iInstanceIndex];

								float3x3 WorldInverse3x3:
									float3x3(WorldInverse[0].XYZ, WorldInverse[1].XYZ, WorldInverse[2].XYZ);


								float3x3 WorldRotation: req (WorldInverse3x3 as float3x3)
									Matrix.Transpose(WorldInverse3x3);
								VertexCount: vc;
							};
					}
					bc = 0;
					for (int k = 0; k < maxInstancesPerBatch; k++)
						worldArray[k] = float4x4(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0);
				}
			}
		}

		void DrawIndividual(DrawContext dc, Material m, List<Entry> entries)
		{
			foreach (var e in entries)
			{
				DrawMesh(dc, m, e.Mesh, e.World, e.WorldInverse);
			}
		}

		void DrawMesh(DrawContext dc, Material m, Mesh mesh, float4x4 world, float4x4 worldInverse)
		{
			foreach (var b in mesh.Batches)
			{
				DrawBatch(dc, m, b, world, worldInverse);
			}
		}

		void DrawBatch(DrawContext dc, Material material, Batch batch, float4x4 world, float4x4 worldInverse)
		{
			draw this,
				batch,
				virtual material,
				{
					DrawContext DrawContext: dc;
					float4x4 World: world;
					float4x4 WorldInverse: worldInverse;
				};
		}
	}
}
