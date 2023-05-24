using System;
using System.Text.Json.Serialization;
using Domain.Converters;
using Domain.Exceptions;

namespace Domain.Primitives;

[JsonConverter(typeof(DomainPrimitiveConverter<ProductId, string>))]
public sealed record ProductId : IDomainPrimitive<string>
{
    public ProductId(string value)
    {
        AssertValid(value);
        Value = value;
    }

    public ProductId(Guid value) : this(value.ToString("D"))
    {
    }
    
    private ProductId() : this(Guid.NewGuid())
    {
    }

    public static ProductId NewProductId()
    {
        return new ProductId();
    }

    public string Value { get; }

    public static bool IsValid(string value)
    {
        return Guid.TryParseExact(value, "D", out var result) && result != Guid.Empty;
    }

    private static void AssertValid(string value)
    {
        if (!IsValid(value))
        {
            throw new DomainPrimitiveArgumentException<string>(value);
        }
    }

    public override string ToString()
    {
        return Value;
    }
}