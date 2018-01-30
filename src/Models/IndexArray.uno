using Uno;
using Uno.Collections;
using Uno.Graphics;
using Uno.Runtime.Implementation.Internal;

namespace Fuse.Content.Models
{
    public sealed class IndexArray
    {
        readonly Buffer _buffer;
        readonly IndexType _type;

        public IndexType Type
        {
            get { return _type; }
        }

        public Buffer Buffer
        {
            get { return _buffer; }
        }

        public int Count
        {
            get { return _buffer.SizeInBytes / IndexTypeHelpers.GetStrideInBytes(_type); }
        }

        public IndexArray(IndexType type, Buffer buffer)
        {
            _buffer = buffer;
            _type = type;
        }

        public IndexArray(byte[] data)
            : this(IndexType.Byte, BufferConverters.ToBuffer(data))
        {
        }

        public IndexArray(ushort[] data)
            : this(IndexType.UShort, BufferConverters.ToBuffer(data))
        {
        }

        public IndexArray(uint[] data)
            : this(IndexType.UInt, BufferConverters.ToBuffer(data))
        {
        }

        public int GetInt(int index)
        {
            switch (_type)
            {
                case IndexType.Byte:
                    return (int)_buffer.GetByte(index * 1);

                case IndexType.UShort:
                    return (int)_buffer.GetUShort(index * 2);

                case IndexType.UInt:
                    return (int)_buffer.GetUInt(index * 4);

                default:
                    // TODO: Error
                    return 0;
            }
        }
    }
}
