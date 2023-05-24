using System.Globalization;
using System.Text.Json.Serialization;
using Domain.Converters;
using Domain.Exceptions;

namespace Domain.Primitives;

[JsonConverter(typeof(DomainPrimitiveConverter<Percentage, decimal>))]
public sealed record Percentage : IDomainPrimitive<decimal>
{
    public Percentage(decimal value)
    {
        AssertValid(value);
        Value = value;
    }

    public decimal Value { get; }
    
    public static bool IsValid(decimal value)
    {
        return value is >= 0.00m and <= 100.00m;
    }

    private static void AssertValid(decimal value)
    {
        if (!IsValid(value))
        {
            throw new DomainPrimitiveArgumentException<decimal>(value);
        }
    }

    public override string ToString()
    {
        return Value.ToString(CultureInfo.InvariantCulture);
    }
}