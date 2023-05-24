using System;
using System.Runtime.Serialization;

namespace Domain.Exceptions;

[Serializable]
public class DomainPrimitiveArgumentException<T> : ArgumentException
{
    public DomainPrimitiveArgumentException(T value) : base(@$"The value {value} is not valid.")
    {
    }

    public DomainPrimitiveArgumentException(string message, T value) : base(message)
    {
        Value = value;
    }

    public T Value { get; }

    protected DomainPrimitiveArgumentException(SerializationInfo info, StreamingContext context) : base(info, context)
    {
        Value = (T) info.GetValue(nameof(Value), typeof(T));
    }
}