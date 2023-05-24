using System.Text.Json;
using Domain.Exceptions;
using Domain.Primitives;
using Xunit;

namespace Domain.Tests.Primitives;

public class QuantityTests
{
    [Fact(DisplayName = "Can serialize quantity")]
    public void GivenQuantity_WhenSerialized_ValueShouldMatch()
    {
        const int value = 56;
        var quantity = new Quantity(value);

        var expected = $@"""{value}""";

        var serialized = JsonSerializer.Serialize(quantity);
        Assert.Equal(expected, serialized);
    }

    [Fact(DisplayName = "Can serialize and deserialize quantity")]
    public void GivenQuantity_WhenSerializedAndDeserialize_ValueShouldMatch()
    {
        const int value = 56;
        var quantity = new Quantity(value);

        var expected = $@"""{value}""";

        var serialized = JsonSerializer.Serialize(quantity);
        var deserialized = JsonSerializer.Deserialize<Quantity>(serialized);
        Assert.Equal(expected, serialized);
        Assert.Equal(quantity, deserialized);
    }

    [InlineData(" ")]
    [InlineData("")]
    [InlineData("[{")]
    [Theory(DisplayName = "Should throw json exception when deserializing empty or malformed string")]
    public void GivenEmptyOrMalformed_WhenDeserialize_ShouldThrowException(string invalid)
    {
        var serialized = JsonSerializer.Serialize(invalid);
        Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<Quantity>(serialized));
    }

    [Fact(DisplayName = "When deserializing null string should be null")]
    public void GivenNull_WhenDeserialize_ShouldBeNull()
    {
        var deserialized = JsonSerializer.Deserialize<Quantity>("null");
        Assert.Null(deserialized);
    }

    [InlineData(0)]
    [InlineData(1)]
    [InlineData(int.MaxValue)]
    [Theory(DisplayName = "Can create a quantity")]
    public void GivenValidInputValue_ShouldCreateANewQuantity(int value)
    {
        var quantity = new Quantity(value);
        Assert.NotNull(quantity);
    }

    [InlineData(-1)]
    [InlineData(int.MinValue)]
    [Theory(DisplayName = "Should throw exception when input is negative")]
    public void GivenInvalidInput_WhenCreatingQuantity_ShouldThrowException(int input)
    {
        Assert.Throws<DomainPrimitiveArgumentException<int>>(() => new Quantity(input));
    }
}