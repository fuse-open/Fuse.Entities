using Uno;
using Uno.Graphics;
using Uno.Collections;
using Uno.Runtime.Implementation.Internal;

using Fuse.Content.Splines;

namespace Fuse.Content.Models
{
    class PsgReaderInternal
    {
        enum PsgModelBlockType
        {
            End = 0,
            BufferList = 1,
            ParameterList = 2,
            MeshList = 3,
            MaterialList = 4,
        }

        enum PsgNodeBlockType
        {
            End = 0,
            NodeList = 1,
            ParameterList = 2,
            DrawableList = 3,
            SkinList = 4,
            //CameraList,
            //LightList,
        }

        [Flags]
        enum PsgSkinFlags
        {
            BindPose = 1 << 0,
            SkeletonRoot = 1 << 1,
        }

        enum PsgSplineType
        {
            Sampled = 0,
            Linear = 1,
        }

        readonly Buffer _buffer;
        readonly BufferReader r;

        string _name;
        int[] _bufferOffsets;
        ModelMesh[] _meshes;
        ModelParameter[] _parameters;
        ModelMaterial[] _materials;

        ModelNode[] _nodes;

        List<ModelDrawable> _drawables = new List<ModelDrawable>();

        int _rootNodeIndex;

        public PsgReaderInternal(Buffer buffer)
        {
            _buffer = buffer;
            r = new BufferReader(buffer);
        }

        public Model ReadModel()
        {
            ReadHeader();
            ReadBlocks();
            ReadNodes();

            return new Model(_name, _drawables.ToArray(), _nodes[_rootNodeIndex]);
        }

        void ReadHeader()
        {
            var magic = r.ReadUInt();
            if (magic != 0x02475350)
                throw new Exception("Invalid magic number");
            _name = r.ReadString();
        }

        void ReadBlocks()
        {
            while (true)
            {
                var blockType = (PsgModelBlockType)(int)r.ReadByte();
                switch (blockType)
                {
                    case PsgModelBlockType.BufferList: ReadBufferList(); break;
                    case PsgModelBlockType.ParameterList: ReadParameterList(); break;
                    case PsgModelBlockType.MeshList: ReadMeshList(); break;
                    case PsgModelBlockType.MaterialList: ReadMaterialList(); break;
                    case PsgModelBlockType.End: default: return;
                }
            }
        }

        void ReadBufferList()
        {
            var buffersCount = r.ReadCompressedInt();
            _bufferOffsets = new int[buffersCount];

            for (int i =0; i<buffersCount; i++)
            {
                var bufferLength = r.ReadCompressedInt();
                _bufferOffsets[i] = r.Position;
                r.Position += bufferLength;
            }
        }

        void ReadMeshList()
        {
            var meshCount = r.ReadCompressedInt();
            _meshes = new ModelMesh[meshCount];
            for (int i =0; i<meshCount; i++)
            {
                _meshes[i] = ReadMesh();
            }
        }

        ModelMesh ReadMesh()
        {
            var name = r.ReadString();
            var primitiveType = (PrimitiveType)(int)r.ReadByte();
            var vertexCount = r.ReadCompressedInt();

            var vertexAttributes = new Dictionary<string, VertexAttributeArray>();
            var attributeCount = r.ReadCompressedInt();
            for (int i =0; i<attributeCount; i++)
            {
                var semantics = r.ReadString();
                var attributeType = (VertexAttributeType)(int)r.ReadByte();
                var bufferIndex = r.ReadCompressedInt();
                vertexAttributes[semantics] = new VertexAttributeArray(attributeType, _buffer.CreateReadOnlySubBuffer(_bufferOffsets[bufferIndex], VertexAttributeTypeHelpers.GetStrideInBytes(attributeType) * vertexCount));
            }

            IndexArray indices = null;
            var indexCount = r.ReadCompressedInt();
            if (indexCount > 0)
            {
                var indexStride = r.ReadByte();

                var indexType = indexStride == 1
                    ? IndexType.Byte
                    : indexStride == 2
                        ? IndexType.UShort
                        : IndexType.UInt;

                var bufferIndex = r.ReadCompressedInt();
                indices = new IndexArray(indexType, _buffer.CreateReadOnlySubBuffer(_bufferOffsets[bufferIndex], IndexTypeHelpers.GetStrideInBytes(indexType) * indexCount));
            }

            return new ModelMesh(name, primitiveType, vertexAttributes, indices);
        }

        void ReadParameterList()
        {
            var parameterCount = r.ReadCompressedInt();
            _parameters = new ModelParameter[parameterCount];
            for (int i = 0; i<parameterCount; i++)
            {
                _parameters[i] = ReadParameter(r, _parameters);
            }
        }

        void ReadMaterialList()
        {
            var materialCount = r.ReadCompressedInt();
            _materials = new ModelMaterial[materialCount];
            for (int i =0; i<materialCount; i++)
            {
                _materials[i] = ReadMaterial(r, _parameters);
            }
        }


        void ReadNodes()
        {
            var count = r.ReadCompressedInt();

            _nodes = new ModelNode[count];
            for(int i =0 ; i<count; i++)
                _nodes[i] = new NodeReaderInternal(this).ReadNode();

            _rootNodeIndex = r.ReadCompressedInt();
        }

        class NodeReaderInternal
        {
            readonly BufferReader r;
            readonly PsgReaderInternal _model;

            List<ModelParameter<float4x4>> _transforms = new List<ModelParameter<float4x4>>();
            Dictionary<string, ModelParameter> _parameters = new Dictionary<string, ModelParameter>();
            List<ModelDrawable> _drawables = new List<ModelDrawable>();
            List<ModelSkin> _skins = new List<ModelSkin>();
            List<ModelNode> _children = new List<ModelNode>();

            public NodeReaderInternal(PsgReaderInternal model)
            {
                r = model.r;
                _model = model;
            }

            public ModelNode ReadNode()
            {
                var nodeName = r.ReadString();

                ReadTransforms();
                ReadNodeBlocks();

                return new ModelNode(nodeName, _transforms, _drawables, _skins, _parameters, _children);
            }

            void ReadTransforms()
            {
                var nodeTransformCount = r.ReadCompressedInt();
                //_transforms = new List<ModelParameter>(); //[nodeTransformCount];
                for (int i=0; i<nodeTransformCount; i++)
                    _transforms.Add((ModelParameter<float4x4>)_model._parameters[r.ReadCompressedInt()]);
            }

            void ReadNodeBlocks()
            {
                while (true)
                {
                    var blockType = (PsgNodeBlockType)(int)r.ReadByte();
                    switch (blockType)
                    {
                        case PsgNodeBlockType.NodeList: ReadNodeList(); break;
                        case PsgNodeBlockType.ParameterList: ReadMeshParameterList(); break;
                        case PsgNodeBlockType.DrawableList: ReadDrawableList(); break;
                        case PsgNodeBlockType.SkinList: ReadSkinList(); break;
                        case PsgNodeBlockType.End: default: return;
                    }
                }
            }

            void ReadMeshParameterList()
            {
                var nodeParametersCount = r.ReadCompressedInt();
                //_parameters = new Dictionary<string, ModelParameter>();
                for (int i =0; i<nodeParametersCount; i++)
                {
                    var name = r.ReadString();
                    var index = r.ReadCompressedInt();
                    _parameters[name] = _model._parameters[index];
                }
            }

            void ReadDrawableList()
            {
                var nodeDrawablesCount = r.ReadCompressedInt();
                //_drawables = new List<ModelDrawable>();//[nodeDrawablesCount];
                for (int i =0; i<nodeDrawablesCount; i++)
                {
                    var meshIndex = r.ReadCompressedInt();
                    var materialIndex = r.ReadCompressedInt();
                    var mesh = _model._meshes[meshIndex];
                    var material = materialIndex == -1 ? null : _model._materials[materialIndex];
                    var d = new ModelDrawable(mesh, material);
                    _drawables.Add(d);
                    _model._drawables.Add(d);
                }
            }

            void ReadSkinList()
            {
                var nodeSkinsCount = r.ReadCompressedInt();
                //_skins = new List<ModelSkin>(); //[nodeSkinsCount];
                for (int i =0; i<nodeSkinsCount; i++)
                    _skins.Add(ReadSkin());
            }

            void ReadNodeList()
            {
                var nodeChildrenCount = r.ReadCompressedInt();
                //_children = new List<ModelNode>() //[nodeChildrenCount];
                for (int i =0; i<nodeChildrenCount; i++)
                    _children.Add(_model._nodes[r.ReadCompressedInt()]);
            }


            ModelSkin ReadSkin()
            {
                var skinFlags = (PsgSkinFlags)(int)r.ReadByte();

                float4x4 bindPose = skinFlags.HasFlag(PsgSkinFlags.BindPose)
                    ? r.ReadFloat4x4()
                    : float4x4.Identity;

                float4x4 skeletonRoot = skinFlags.HasFlag(PsgSkinFlags.SkeletonRoot)
                    ? r.ReadFloat4x4()
                    : float4x4.Identity;

                var boneCount = r.ReadCompressedInt();
                var bones = new SkinBone[boneCount];
                for (int i = 0; i<boneCount; i++)
                    bones[i] = ReadSkinBone();

                var drawableCount = r.ReadCompressedInt();
                var drawables = new SkinDrawable[drawableCount];
                for (int i =0; i<drawableCount; i++)
                    _model._drawables.Add(drawables[i] = ReadSkinDrawable(bones));

                return new ModelSkin(bindPose, skeletonRoot, bones, drawables);
            }

            SkinBone ReadSkinBone()
            {
                var node = _model._nodes[r.ReadCompressedInt()];
                var bpi = r.ReadFloat4x4();

                return new SkinBone(node, bpi);
            }

            int _currentBonesPerVertex;

            SkinDrawable ReadSkinDrawable(SkinBone[] bones)
            {
                var meshIndex = r.ReadCompressedInt();
                var mesh = _model._meshes[meshIndex];

                var materialIndex = r.ReadCompressedInt();
                var material = materialIndex == -1 ? null : _model._materials[materialIndex];

                var vertexInfluenceCountTableLength = r.ReadCompressedInt();
                var vertexInfluenceCountTable = new int2[vertexInfluenceCountTableLength];
                var totalVertexCount = 0;
                for (int i = 0; i < vertexInfluenceCountTableLength; i++)
                {
                    var vertexCount = r.ReadCompressedInt();
                    var influenceCountPerVertex = r.ReadCompressedInt();
                    vertexInfluenceCountTable[i] = int2(vertexCount, influenceCountPerVertex);
                    totalVertexCount += vertexCount;
                }

                var influences = new VertexInfluence[totalVertexCount];
                int vertex = 0;
                for (int g = 0; g < vertexInfluenceCountTableLength; g++)
                {
                    var vertexCount = vertexInfluenceCountTable[g].X;
                    var influenceCountPerVertex = vertexInfluenceCountTable[g].Y;

                    for (int v = 0; v < vertexCount; v++)
                    {
                        var iIndices = new int[influenceCountPerVertex];
                        var iWeights = new float[influenceCountPerVertex];
                        for (int vi = 0; vi < influenceCountPerVertex; vi++)
                        {
                            iIndices[vi] = r.ReadCompressedInt();
                            iWeights[vi] = r.ReadFloat();
                        }
                        influences[vertex++] =  new VertexInfluence(iIndices, iWeights);
                    }
                }

                return new SkinDrawable(mesh, material, influences);
            }
        }

        internal static ModelMaterial ReadMaterial(BufferReader r, ModelParameter[] parameters)
        {
            var name = r.ReadString();

            var dict = new Dictionary<string, ModelParameter>();
            int paramCount = r.ReadCompressedInt();
            for (int i = 0; i < paramCount; i++)
            {
                var key = r.ReadString();
                var index = r.ReadCompressedInt();
                dict.Add(key, parameters[index]);
            }

            return new ModelMaterial(name, dict);
        }

        internal static ModelParameter ReadParameter(BufferReader r, ModelParameter[] parameters)
        {
            var valueType = (ModelParameterValueType)r.ReadByte();

            switch (valueType)
            {
                case ModelParameterValueType.List:
                    {
                        var itemType = (ModelParameterValueType)r.ReadByte();

                        switch (itemType)
                        {
                            case ModelParameterValueType.Float:
                                return ReadParameterList<float>(r, parameters, itemType);

                            case ModelParameterValueType.Float2:
                                return ReadParameterList<float2>(r, parameters, itemType);

                            case ModelParameterValueType.Float3:
                                return ReadParameterList<float3>(r, parameters, itemType);

                            case ModelParameterValueType.Float4:
                                return ReadParameterList<float4>(r, parameters, itemType);

                            case ModelParameterValueType.Float4x4:
                                return ReadParameterList<float4x4>(r, parameters, itemType);

                            case ModelParameterValueType.String:
                                return ReadParameterList<string>(r, parameters, itemType);
                        }
                    }

                    break;

                case ModelParameterValueType.String:
                    if ((ModelParameterType)r.ReadByte() != ModelParameterType.Constant) break;
                    return new ModelParameter<string>(valueType, r.ReadString());

                case ModelParameterValueType.Float:
                    return ReadParameter<float>(r, valueType, 4, BufferReader.ReadFloat);

                case ModelParameterValueType.Float2:
                    return ReadParameter<float2>(r, valueType, 8, BufferReader.ReadFloat2);

                case ModelParameterValueType.Float3:
                    return ReadParameter<float3>(r, valueType, 12, BufferReader.ReadFloat3);

                case ModelParameterValueType.Float4:
                    return ReadParameter<float4>(r, valueType, 16, BufferReader.ReadFloat4);

                case ModelParameterValueType.Float4x4:
                    return ReadParameter<float4x4>(r, valueType, 64, BufferReader.ReadFloat4x4);
            }

            throw new Exception("Unsupported model parameter");
        }

        internal static ModelParameterList<T> ReadParameterList<T>(BufferReader r, ModelParameter[] parameters, ModelParameterValueType itemType)
        {
            var items = new ModelParameter<T>[r.ReadCompressedInt()];
            for (int i = 0; i < items.Length; i++) items[i] = (ModelParameter<T>)parameters[r.ReadCompressedInt()];
            return new ModelParameterList<T>(itemType, items);
        }

        internal static FullsampledSpline<T> ReadAnimationSampledSpline<T>(BufferReader r, int keyStride, Func<BufferReader, T> readKey) where T : struct
        {
            var start = r.ReadDouble();
            var fps = r.ReadDouble();

            var size = r.ReadCompressedInt();
            var keys = new T[size / keyStride];

            for (int i = 0; i < keys.Length; i++)
                keys[i] = readKey(r);

            return new FullsampledSpline<T>(start, fps, keys);
        }

        internal static KeyframedSpline<T, T>.Key[] ReadAnimationKeys<T>(BufferReader r, int keyStride, Func<BufferReader, T> readValue) where T : struct
        {
            var size = r.ReadCompressedInt();
            var keys = new KeyframedSpline<T, T>.Key[size / (keyStride + 8)];

            for (int i = 0; i < keys.Length; i++)
            {
                var time = r.ReadDouble();
                var value = readValue(r);
                keys[i] = new KeyframedSpline<T, T>.Key(time, value);
            }

            return keys;
        }

        internal static object ReadAnimationLinearSpline(BufferReader r, int keyStride, Delegate readKey)
        {
            switch (keyStride)
            {
                case 4:
                    return new LinearSplineFloat(ReadAnimationKeys<float>(r, keyStride, (Func<BufferReader, float>)readKey));

                case 8:
                    return new LinearSplineFloat2(ReadAnimationKeys<float2>(r, keyStride, (Func<BufferReader, float2>)readKey));

                case 12:
                    return new LinearSplineFloat3(ReadAnimationKeys<float3>(r, keyStride, (Func<BufferReader, float3>)readKey));

                case 16:
                    return new LinearSplineFloat4(ReadAnimationKeys<float4>(r, keyStride, (Func<BufferReader, float4>)readKey));

                case 64:
                    return new LinearSplineFloat4x4(ReadAnimationKeys<float4x4>(r, keyStride, (Func<BufferReader, float4x4>)readKey));

                default:
                    throw new Exception("Unsupported LinearSpline animation");
            }
        }

        internal static ModelParameterAnimation<T> ReadParameterAnimation<T>(BufferReader r, ModelParameterValueType keyType, int keyStride, Func<BufferReader, T> readKey) where T : struct
        {
            var type = (PsgSplineType)r.ReadByte();

            switch (type)
            {
                case PsgSplineType.Sampled:
                    return new ModelParameterAnimation<T>(keyType, ReadAnimationSampledSpline(r, keyStride, readKey));

                case PsgSplineType.Linear:
                    return new ModelParameterAnimation<T>(keyType, (Spline<T>)ReadAnimationLinearSpline(r, keyStride, readKey));
            }

            throw new Exception("Unsupported spline type <" + type.ToString() + ">");
        }

        internal static ModelParameter<T> ReadParameter<T>(BufferReader r, ModelParameterValueType valueType, int valueStride, Func<BufferReader, T> readValue) where T : struct
        {
            var type = (ModelParameterType)r.ReadByte();

            switch (type)
            {
                case ModelParameterType.Animation:
                    return ReadParameterAnimation(r, valueType, valueStride, readValue);

                case ModelParameterType.Constant:
                    return new ModelParameter<T>(valueType, readValue(r));
            }

            throw new Exception("Unsupported model parameter type <" + type.ToString() + ">");
        }
    }
}
