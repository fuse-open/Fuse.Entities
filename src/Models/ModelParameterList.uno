using Uno.Math;

namespace Fuse.Content.Models
{
    public class ModelParameterList<T> : ModelParameter
    {
        readonly ModelParameterValueType _itemType;
        readonly ModelParameter<T>[] _items;
        readonly T[] _values;

        public ModelParameterList(ModelParameterValueType itemType, ModelParameter<T>[] items)
        {
            _itemType = itemType;
            _items = items;
            _values = new T[items.Length];
            Update(StartTime);
        }

        public override ModelParameterType ParameterType
        {
            get { return ModelParameterType.List; }
        }

        public override ModelParameterValueType ValueType
        {
            get { return ModelParameterValueType.List; }
        }

        bool _isAnimated, _hasAnimInfo;
        double _start, _end;

        void UpdateAnimInfo()
        {
            if (_hasAnimInfo) return;

            _start = 100000.0;
            _end = -100000.0;
            _isAnimated = false;

            for (int i = 0; i < _items.Length; i++)
            {
                if (_items[i].IsAnimated)
                {
                    _start = Min(_items[i].StartTime, _start);
                    _end = Max(_items[i].EndTime, _end);
                    _isAnimated = true;
                }
            }

            _hasAnimInfo = true;
        }

        public override bool IsAnimated
        {
            get
            {
                UpdateAnimInfo();
                return _isAnimated;
            }
        }

        public override double StartTime
        {
            get
            {
                UpdateAnimInfo();
                return _start;
            }
        }

        public override double EndTime
        {
            get
            {
                UpdateAnimInfo();
                return _end;
            }
        }

        public override void Update(double time)
        {
            for (int i = 0; i < _items.Length; i++)
            {
                if (_items[i].IsAnimated)
                {
                    _items[i].Update(time);
                    _values[i] = _items[i].Value;
                }
            }
        }

        public override int ListLength
        {
            get { return _items.Length; }
        }

        public override ModelParameterValueType ListItemType
        {
            get { return _itemType; }
        }

        public override ModelParameter GetListItem(int index)
        {
            return _items[index];
        }
    }
}
