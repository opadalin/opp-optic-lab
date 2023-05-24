using System.Text.Json.Serialization;
using Domain.Converters;
using Domain.Exceptions;

namespace Domain.Primitives;

[JsonConverter(typeof(DomainPrimitiveConverter<Quantity, int>))]
public record Quantity : IDomainPrimitive<int>
{
    public Quantity(int value)
    {
        AssertValid(value);
        Value = value;
    }

    public int Value { get; }

    public static bool IsValid(int value)
    {
        return value >= 0;
    }

    private static void AssertValid(int value)
    {
        if (!IsValid(value))
        {
            throw new DomainPrimitiveArgumentException<int>(value);
        }
    }

    public override string ToString()
    {
        return $"{Value}";
    }
}