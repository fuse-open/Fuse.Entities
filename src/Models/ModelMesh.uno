using Uno.Collections;
using Uno.Graphics;

namespace Fuse.Content.Models
{
    public class ModelMesh
    {
        readonly string _name;
        public string Name { get { return _name; } }

        readonly PrimitiveType _primitiveType;
        public PrimitiveType PrimitiveType { get { return _primitiveType; } }

        readonly IndexArray _indices;
        public IndexArray Indices { get { return _indices; } }

        readonly Dictionary<string, VertexAttributeArray> _vertexAttributes;

        public IEnumerable<KeyValuePair<string, VertexAttributeArray>> VertexAttributes { get { return _vertexAttributes; } }

        public VertexAttributeArray GetVertexAttribute(string attributeName)
        {
            return _vertexAttributes[attributeName];
        }

        public VertexAttributeArray TryGetVertexAttribute(string name)
        {
            VertexAttributeArray result;
            _vertexAttributes.TryGetValue(name, out result);
            return result;
        }

        public ModelMesh(string name, PrimitiveType type, Dictionary<string, VertexAttributeArray> vertexAttributes, IndexArray indices = null)
        {
            _name = name;
            _primitiveType = type;
            _vertexAttributes = vertexAttributes;
            _indices = indices;
        }

        public int IndexCount
        {
            get { return Indices != null ? Indices.Count : -1; }
        }

        public int VertexCount
        {
            get
            {
                foreach (var attrib in VertexAttributes)
                    return attrib.Value.Count;

                return 0;
            }
        }

        public VertexAttributeArray BoneWeights
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.BoneWeights); }
        }

        public VertexAttributeArray BoneIndices
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.BoneIndices); }
        }

        public VertexAttributeArray Positions
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.Position); }
        }

        public VertexAttributeArray TexCoords
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.TexCoord); }
        }

        public VertexAttributeArray Normals
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.Normal); }
        }

        public VertexAttributeArray Tangents
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.Tangent); }
        }

        public VertexAttributeArray Binormals
        {
            get { return TryGetVertexAttribute(VertexAttributeSemantic.Binormal); }
        }
    }
}
