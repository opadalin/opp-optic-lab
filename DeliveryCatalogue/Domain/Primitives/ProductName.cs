using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using Domain.Converters;
using Domain.Exceptions;

namespace Domain.Primitives;

[JsonConverter(typeof(DomainPrimitiveConverter<ProductName, string>))]
public sealed record ProductName : IDomainPrimitive<string>
{
    private const int MinLength = 3;
    private const int MaxLength = 150;

    private static readonly string ProductNamePattern = @$"^[a-zA-Z0-9-]{{{MinLength},{MaxLength}}}$";

    public ProductName(string value)
    {
        AssertValid(value);
        Value = value;
    }

    public static bool IsValid(string value)
    {
        return !string.IsNullOrWhiteSpace(value) && Regex.IsMatch(value, ProductNamePattern);
    }

    private static void AssertValid(string value)
    {
        if (!IsValid(value))
        {
            throw new DomainPrimitiveArgumentException<string>(value);
        }
    }

    public string Value { get; }

    public override string ToString()
    {
        return Value;
    }
}