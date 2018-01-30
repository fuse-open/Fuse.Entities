using Uno;
using Uno.Math;

namespace Fuse.Content.Models
{
    public abstract class ModelParameter
    {
        public abstract ModelParameterType ParameterType { get; }
        public abstract ModelParameterValueType ValueType { get; }

        public virtual bool IsAnimated
        {
            get { return false; }
        }

        public virtual double StartTime
        {
            get { return 0.0; }
        }

        public virtual double EndTime
        {
            get { return 0.0; }
        }

        public virtual void Update(double time)
        {
        }

        public virtual int ListLength
        {
            get { return 0; }
        }

        public virtual ModelParameterValueType ListItemType
        {
            get { return ModelParameterValueType.Invalid; }
        }

        public virtual ModelParameter GetListItem(int index)
        {
            throw new IndexOutOfRangeException();
        }
    }

    public class ModelParameter<T> : ModelParameter
    {
        protected T _value;
        readonly ModelParameterValueType _valueType;

        public override ModelParameterType ParameterType
        {
            get { return ModelParameterType.Constant; }
        }

        public override ModelParameterValueType ValueType
        {
            get { return _valueType; }
        }

        public T Value
        {
            get { return _value; }
        }

        public ModelParameter(ModelParameterValueType valueType, T value)
        {
            _valueType = valueType;
            _value = value;
        }
    }
}
