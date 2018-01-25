using Uno;
using Uno.Collections;
using Uno.Graphics;

namespace Fuse.Content.Models
{
    public sealed class VertexAttributeArray
    {
        readonly Buffer _buffer;
        readonly VertexAttributeType _type;

        public VertexAttributeType Type
        {
            get { return _type; }
        }

        public Buffer Buffer
        {
            get { return _buffer; }
        }

        public int Count
        {
            get { return _buffer.SizeInBytes / VertexAttributeTypeHelpers.GetStrideInBytes(_type); }
        }

        public VertexAttributeArray(VertexAttributeType type, Buffer buffer)
        {
            _buffer = buffer;
            _type = type;
        }

        public VertexAttributeArray(float[] data)
            : this(VertexAttributeType.Float, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(float2[] data)
            : this(VertexAttributeType.Float2, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(float3[] data)
            : this(VertexAttributeType.Float3, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(float4[] data)
            : this(VertexAttributeType.Float4, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(short[] data, bool normalized)
            : this(normalized ? VertexAttributeType.ShortNormalized : VertexAttributeType.Short, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        /*public VertexAttributeArray(short2[] data, bool normalized)
            : this(normalized ? VertexAttributeType.Short2Normalized : VertexAttributeType.Short2, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(short4[] data, bool normalized)
            : this(normalized ? VertexAttributeType.Short4Normalized : VertexAttributeType.Short4, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }*/

        public VertexAttributeArray(ushort[] data, bool normalized)
            : this(normalized ? VertexAttributeType.UShortNormalized : VertexAttributeType.UShort, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        /*public VertexAttributeArray(ushort2[] data, bool normalized)
            : this(normalized ? VertexAttributeType.UShort2Normalized : VertexAttributeType.UShort2, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(ushort4[] data, bool normalized)
            : this(normalized ? VertexAttributeType.UShort4Normalized : VertexAttributeType.UShort4, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }*/

        public VertexAttributeArray(sbyte4[] data, bool normalized)
            : this(normalized ? VertexAttributeType.SByte4Normalized : VertexAttributeType.SByte4, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public VertexAttributeArray(byte4[] data, bool normalized)
            : this(normalized ? VertexAttributeType.Byte4Normalized : VertexAttributeType.Byte4, Uno.Runtime.Implementation.Internal.BufferConverters.ToBuffer(data))
        {
        }

        public byte4 GetByte4Normalized(int index)
        {
            if (_type == VertexAttributeType.Byte4Normalized)
                return _buffer.GetByte4(index * 4);
            else
            {
                var v = GetFloat4(index) * 255.0f;
                return byte4((byte)v.X, (byte)v.Y, (byte)v.Z, (byte)v.W);
            }
        }

        public byte4 GetByte4(int index)
        {
            if (_type == VertexAttributeType.Byte4)
                return _buffer.GetByte4(index * 4);
            else
            {
                var v = GetFloat4(index);
                return byte4((byte)v.X, (byte)v.Y, (byte)v.Z, (byte)v.W);
            }
        }

        public float4 GetFloat4(int index)
        {
            switch (_type)
            {
                case VertexAttributeType.Float:
                    {
                        var v = _buffer.GetFloat(index * 4);
                        return float4(v, 0, 0, 0);
                    }

                case VertexAttributeType.Float2:
                    {
                        var v = _buffer.GetFloat2(index * 4 * 2);
                        return float4(v, 0, 0);
                    }

                case VertexAttributeType.Float3:
                    {
                        var v = _buffer.GetFloat3(index * 4 * 3);
                        return float4(v, 0);
                    }

                case VertexAttributeType.Float4:
                    {
                        var v = _buffer.GetFloat4(index * 4 * 4);
                        return v;
                    }

                case VertexAttributeType.Short:
                    {
                        var v = _buffer.GetShort(index * 2);
                        return float4((float)v, 0, 0, 0);
                    }

                case VertexAttributeType.ShortNormalized:
                    {
                        var v = _buffer.GetShort(index * 2);
                        return float4((float)v, 0, 0, 0) * float4(1.0f / short.MaxValue);
                    }

                case VertexAttributeType.Short2:
                    {
                        var v = _buffer.GetShort2(index * 2 * 2);
                        return float4((float)v.X, (float)v.Y, 0, 0);
                    }

                case VertexAttributeType.Short2Normalized:
                    {
                        var v = _buffer.GetShort2(index * 2 * 2);
                        return float4((float)v.X, (float)v.Y, 0, 0) * float4(1.0f / short.MaxValue);
                    }

                case VertexAttributeType.Short4:
                    {
                        var v = _buffer.GetShort4(index * 2 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W);
                    }

                case VertexAttributeType.Short4Normalized:
                    {
                        var v = _buffer.GetShort4(index * 2 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W) * float4(1.0f / short.MaxValue);
                    }

                case VertexAttributeType.UShort:
                    {
                        var v = _buffer.GetUShort(index * 2 * 1);
                        return float4((float)v, 0, 0, 0);
                    }

                case VertexAttributeType.UShortNormalized:
                    {
                        var v = _buffer.GetUShort(index * 2 * 1);
                        return float4((float)v, 0, 0, 0) * float4(1.0f / ushort.MaxValue);
                    }

                case VertexAttributeType.UShort2:
                    {
                        var v = _buffer.GetUShort2(index * 2 * 2);
                        return float4((float)v.X, (float)v.Y, 0, 0);
                    }

                case VertexAttributeType.UShort2Normalized:
                    {
                        var v = _buffer.GetUShort2(index * 2 * 2);
                        return float4((float)v.X, (float)v.Y, 0, 0) * float4(1.0f / ushort.MaxValue);
                    }

                case VertexAttributeType.UShort4:
                    {
                        var v = _buffer.GetUShort4(index * 2 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W);
                    }

                case VertexAttributeType.UShort4Normalized:
                    {
                        var v = _buffer.GetUShort4(index * 2 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W) * float4(1.0f / ushort.MaxValue);
                    }

                case VertexAttributeType.SByte4:
                    {
                        var v = _buffer.GetSByte4(index * 1 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W);
                    }

                case VertexAttributeType.SByte4Normalized:
                    {
                        var v = _buffer.GetSByte4(index * 1 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W) * float4(1.0f / sbyte.MaxValue);
                    }

                case VertexAttributeType.Byte4:
                    {
                        var v = _buffer.GetByte4(index * 1 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W);
                    }

                case VertexAttributeType.Byte4Normalized:
                    {
                        var v = _buffer.GetByte4(index * 1 * 4);
                        return float4((float)v.X, (float)v.Y, (float)v.Z, (float)v.W) * float4(1.0f / byte.MaxValue);
                    }

                default:
                    // TODO: Error
                    return float4(0);
            }
        }
    }
}
