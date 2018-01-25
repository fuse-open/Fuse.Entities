using Fuse.Content.Splines;

namespace Fuse.Content.Models
{
    public class ModelParameterAnimation<T> : ModelParameter<T> where T : struct
    {
        readonly Spline<T> _spline;

        public ModelParameterAnimation(ModelParameterValueType valueType, Spline<T> spline)
            : base(valueType, spline.First)
        {
            _spline = spline;
        }

        public override ModelParameterType ParameterType
        {
            get { return ModelParameterType.Animation; }
        }

        public override bool IsAnimated
        {
            get { return true; }
        }

        public override double StartTime
        {
            get { return _spline.Start; }
        }

        public override double EndTime
        {
            get { return _spline.End; }
        }

        public override void Update(double time)
        {
            _spline.Sample(time, out _value);
        }
    }
}
