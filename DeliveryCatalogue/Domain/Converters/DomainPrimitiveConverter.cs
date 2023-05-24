using System;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;
using Domain.Primitives;

namespace Domain.Converters;

public class DomainPrimitiveConverter<TDomainPrimitive, TPrimitiveType> : JsonConverter<TDomainPrimitive>
    where TDomainPrimitive : IDomainPrimitive<TPrimitiveType>
{
    private readonly Type _primitiveType;

    public DomainPrimitiveConverter()
    {
        _primitiveType = typeof(TPrimitiveType);
    }

    public override TDomainPrimitive Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType != JsonTokenType.String)
        {
            throw new JsonException();
        }

        var value = reader.GetString();

        try
        {
            if (_primitiveType == typeof(decimal)
                && decimal.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var decimalValue))
            {
                return (TDomainPrimitive) Activator.CreateInstance(typeof(TDomainPrimitive), decimalValue);
            }
            
            if (_primitiveType == typeof(int)
                && int.TryParse(value, NumberStyles.Number, CultureInfo.InvariantCulture, out var intValue))
            {
                return (TDomainPrimitive) Activator.CreateInstance(typeof(TDomainPrimitive), intValue);
            }

            return (TDomainPrimitive) Activator.CreateInstance(typeof(TDomainPrimitive), value);
        }
        catch (Exception e)
        {
            throw new JsonException($"Error creating instance of {typeof(TDomainPrimitive)} with value '{value}'", e);
        }
    }

    public override void Write(Utf8JsonWriter writer, TDomainPrimitive value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString());
    }
}