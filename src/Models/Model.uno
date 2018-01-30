using Uno;
using Uno.Collections;

namespace Fuse.Content.Models
{
    public sealed class Model
    {
        readonly string _name;
        readonly ModelNode _root;
        readonly ModelDrawable[] _drawables;

        public string Name
        {
            get { return _name; }
        }

        public ModelNode Root
        {
            get { return _root; }
        }

        internal Model(string name, ModelDrawable[] drawables, ModelNode root = null)
        {
            _name = name;
            _drawables = drawables;
            _root = root ?? new ModelNode(name);
        }

        public static Model CreateFromPsg(Buffer psg)
        {
            return new PsgReaderInternal(psg).ReadModel();
        }

        public int DrawableCount
        {
            get { return _drawables.Length; }
        }

        public ModelDrawable GetDrawable(int index)
        {
            return _drawables[index];
        }
    }

    public sealed class ModelNode
    {
        readonly string _name;
        public string Name { get { return _name; } }

        readonly List<ModelParameter<float4x4>> _transforms;
        public IEnumerable<ModelParameter<float4x4>> Transforms { get { return _transforms; } }

        readonly List<ModelDrawable> _drawables;
        public IEnumerable<ModelDrawable> Drawables { get { return _drawables; } }

        readonly List<ModelSkin> _skins;
        public IEnumerable<ModelSkin> Skins { get { return _skins; } }

        readonly Dictionary<string, ModelParameter> _parameters;

        public IEnumerable<KeyValuePair<string, ModelParameter>> Parameters { get { return _parameters; } }

        public ModelParameter GetParameter(string parameterName)
        {
            return _parameters[parameterName];
        }

        readonly List<ModelNode> _children;
        public IEnumerable<ModelNode> Children { get { return _children; } }

        public ModelNode(string name)
        {
            _name = name;
            _transforms = new List<ModelParameter<float4x4>>();
            _drawables = new List<ModelDrawable>();
            _skins = new List<ModelSkin>();
            _parameters = new Dictionary<string, ModelParameter>();
            _children = new List<ModelNode>();
        }

        public ModelNode(string name, List<ModelParameter<float4x4>> transforms, List<ModelDrawable> drawables, List<ModelSkin> skins, Dictionary<string, ModelParameter> parameters, List<ModelNode> children)
        {
            _name = name;
            _transforms = transforms;
            _drawables = drawables;
            _skins = skins;
            _parameters = parameters;
            _children = children;
        }
    }

    public sealed class ModelSkin
    {
        /*readonly*/ float4x4 _bindPose;
        public float4x4 BindPose { get { return _bindPose; } }

        /*readonly*/ float4x4 _skeletonRoot;
        public float4x4 SkeletonRoot { get { return _skeletonRoot; } }

        readonly List<SkinBone> _bones = new List<SkinBone>();
        public IEnumerable<SkinBone> Bones { get { return _bones; } }

        readonly List<SkinDrawable> _drawables = new List<SkinDrawable>();
        public IEnumerable<SkinDrawable> Drawables { get { return _drawables; } }

        public ModelSkin(float4x4 bindPose, float4x4 skeletonRoot, SkinBone[] bones, SkinDrawable[] drawables)
        {
            _bindPose = bindPose;
            _skeletonRoot = skeletonRoot;

            foreach (var b in bones)
                _bones.Add(b);

            foreach (var d in drawables)
                _drawables.Add(d);
        }
    }

    public sealed class SkinBone
    {
        readonly ModelNode _node;
        public ModelNode Node { get { return _node; } }

        /*readonly*/ float4x4 _bindPoseInverse;
        public float4x4 BindPoseInverse { get { return _bindPoseInverse; } }

        public SkinBone(ModelNode node, float4x4 bindPoseInverse)
        {
            _node = node;
            _bindPoseInverse = bindPoseInverse;
        }
    }

    public class SkinDrawable : ModelDrawable
    {
        readonly List<VertexInfluence> _vertexInfluences = new List<VertexInfluence>();
        public IEnumerable<VertexInfluence> VertexInfluences { get { return _vertexInfluences; } }

        public SkinDrawable(ModelMesh mesh, ModelMaterial material, VertexInfluence[] influences)
            : base (mesh, material)
        {
            foreach (var i in influences)
                _vertexInfluences.Add(i);
        }
    }

    public class ModelDrawable
    {
        readonly ModelMesh _mesh;
        public ModelMesh Mesh { get { return _mesh; } }

        readonly ModelMaterial _optionalMaterial;
        public ModelMaterial OptionalMaterial { get { return _optionalMaterial; } }

        public ModelDrawable(ModelMesh mesh, ModelMaterial optionalMaterial = null)
        {
            _mesh = mesh;
            _optionalMaterial = optionalMaterial;
        }
    }

    public sealed class VertexInfluence
    {
        readonly int[] _boneIndices;
        readonly float[] _boneWeights;

        public int InfluenceCount { get { return _boneIndices.Length; } }

        public VertexInfluence(int[] indices, float[] weights)
        {
            _boneIndices = indices;
            _boneWeights = weights;
        }

        public int GetBoneIndex(int i) { return _boneIndices[i]; }

        public float GetBoneWeight(int i) { return _boneWeights[i]; }
    }

    public sealed class ModelMaterial
    {
        readonly string _name;
        public string Name { get { return _name; } }

        readonly Dictionary<string, ModelParameter> _parameters;

        public IEnumerable<KeyValuePair<string, ModelParameter>> Parameters { get { return _parameters; } }

        public ModelParameter GetParameter(string parameterName)
        {
            return _parameters[parameterName];
        }

        public ModelMaterial(string name, Dictionary<string, ModelParameter> parameters)
        {
            _name = name;
            _parameters = parameters;
        }
    }
}
