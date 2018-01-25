using Uno;
using Uno.Collections;
using Uno.Testing;

using Fuse;
using Fuse.Controls;

class TestRootPanel : Panel
{
	RootViewport _rootViewport;

	public TestRootPanel()
	{
		_rootViewport = new RootViewport(Uno.Application.Current.Window, 1);
		_rootViewport.Children.Add(this);
	}

	static public TestRootPanel CreateWithChild(Node child, int2 layoutSize)
	{
		var root = new TestRootPanel();
		root.Children.Add(child);
		return root;
	}

	static public TestRootPanel CreateWithChild(Node child)
	{
		return CreateWithChild(child, int2(800,600));
	}
}

namespace Fuse.Entities.Test
{
	public class EntityTest
	{
		public class DummyComp : Component
		{
		}

		public class DummyCompChangeTrans : Component
		{
			Transform3D _trans;
			public DummyCompChangeTrans(float3 pos, float4 rot, float3 scale) { _trans = new Transform3D(pos, rot, scale); }
			protected override void OnRooted() { base.OnRooted(); Entity.Children.Add(_trans); }
			protected override void OnUnrooted() { base.OnUnrooted(); Entity.Children.Remove(_trans); }
		}

		[Test]
		public void InstantiateWithComponents_1()
		{
			var c1 = new DummyComp();
			var c2 = new DummyComp();
			var c3 = new DummyComp();
			var c4 = new DummyComp();
			var e = new Entity(c1,c2,c3,c4);
			Assert.AreEqual(4, e.Children.Count);
		}

		[Test]
		public void InstantiateWithComponents_2()
		{
			var c = new Component[1000];
			for (int i = 0; i < 1000; i++)
			{
				c[i] = new DummyComp();
			}
			var e = new Entity(c);
			Assert.AreEqual(1000, e.Children.Count);
		}

		[Test]
		public void FindAllComponents()
		{
			var c1 = new DummyComp(); _dummyComps.Add(c1);
			var c2 = new DummyComp(); _dummyComps.Add(c2);
			var c3 = new DummyComp(); _dummyComps.Add(c3);
			var c4 = new DummyComp(); _dummyComps.Add(c4);
			var e1 = new Entity(c1,c2);
			var e2 = new Entity(c3,c4);
			e1.Children.Add(e2);
			e1.FindAllComponents<DummyComp>(FindAllCompsCallBack, true);
			Assert.AreCollectionsEqual(_dummyComps, _foundComps);
		}

		List<DummyComp> _dummyComps = new List<DummyComp>();
		List<DummyComp> _foundComps = new List<DummyComp>();
		public void FindAllCompsCallBack(DummyComp dc)
		{
			_foundComps.Add(dc);
			Assert.IsTrue(dc != null);
			Assert.Contains(dc, _dummyComps);
		}

		[Test]
		public void ParentEntity_1()
		{
			var root = new TestRootPanel();
			var child = new Entity();
			var parent = new Entity();
			root.Children.Add(parent);
			parent.Children.Add(child);
			Assert.AreEqual(parent, child.ParentEntity);
		}

		[Test]
		public void ParentEntity_2()
		{
			var root = new TestRootPanel();
			var child1 = new Entity();
			var child2 = new Entity();
			var parent = new Entity();
			var grandparent = new Entity();
			grandparent.Children.Add(parent);
			parent.Children.Add(child1);
			parent.Children.Add(child2);
			root.Children.Add(grandparent);

			Assert.AreEqual(child2.ParentEntity, child1.ParentEntity);
			Assert.AreEqual(grandparent, child1.ParentEntity.ParentEntity);
			Assert.AreEqual(grandparent, parent.ParentEntity);
		}

		[Test]
		public void WorldPosition_1()
		{
			var e = new Entity();
			var abspos = e.WorldPosition;
			Assert.AreEqual(float3(), abspos);
		}

		[Test]
		public void WorldPosition_2()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c = new DummyCompChangeTrans(float3(10,20,30), float4(1,0,0,0), float3(1));
			e.Children.Add(c);
			Assert.AreEqual(float3(10,20,30), e.WorldPosition);
		}

		[Test]
		public void WorldPosition_TwoComponents()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c1 = new DummyCompChangeTrans(float3(10,20,30), Quaternion.FromEulerAngle(float3(0f)), float3(1));
			var c2 = new DummyCompChangeTrans(float3(30,20,10), Quaternion.FromEulerAngle(float3(0f)), float3(1));
			e.Children.Add(c1);
			e.Children.Add(c2);
			Assert.AreEqual(float3(40,40,40), e.WorldPosition);
		}

		[Test]
		public void WorldRotationQuaternion()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c = new DummyCompChangeTrans(float3(0), float4(0.943714364147489f, 0.2685358227515692f, 0.03813457647485014f, 0.18930785741199999f), float3(1));
			e.Children.Add(c);
			Assert.AreEqual(float4(0.943714364147489f, 0.2685358227515692f, 0.03813457647485014f, 0.18930785741199999f), e.WorldRotationQuaternion);
		}

		[Test]
		public void WorldRight_1()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c = new DummyCompChangeTrans(float3(0), Quaternion.FromEulerAngleDegrees(float3(0)), float3(10));
			e.Children.Add(c);
			Assert.AreEqual(float3(1,0,0), e.WorldRight);
		}

		[Test]
		public void WorldForward_1()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c = new DummyCompChangeTrans(float3(0), Quaternion.FromEulerAngleDegrees(float3(0)), float3(20, 1, 5));
			e.Children.Add(c);
			Assert.AreEqual(float3(0,0,-1), e.WorldForward);
		}

		[Test]
		public void WorldUp_1()
		{
			var e = new Entity();
			var rootPanel = TestRootPanel.CreateWithChild(e);
			var c = new DummyCompChangeTrans(float3(0), Quaternion.FromEulerAngleDegrees(float3(0)), float3(20, 9, 5));
			e.Children.Add(c);
			Assert.AreEqual(float3(0,1,0), e.WorldUp);
		}

		[Test]
		public void Transform()
		{
			var e = new Entity();
			Assert.IsTrue(e.Transform == null);
			e.Children.Add(new Transform3D());
			Assert.IsTrue(e.Transform != null);
		}
	}
}
