using System.Text.Json;
using Domain.Exceptions;
using Domain.Primitives;
using Xunit;

namespace Domain.Tests.Primitives;

public class PercentageTests
{
    [Fact(DisplayName = "Can serialize percentage")]
    public void GivenPercentage_WhenSerialized_ValueShouldMatch()
    {
        const decimal pct = 56.5m;
        var percentage = new Percentage(pct);

        const string expected = @"""56.5""";

        var serialized = JsonSerializer.Serialize(percentage);
        Assert.Equal(expected, serialized);
    }

    [Fact(DisplayName = "Can serialize and deserialize a percentage")]
    public void GivenPercentage_WhenSerialized_CanDeserialize()
    {
        const decimal pct = 56.5m;
        var percentage = new Percentage(pct);

        const string expected = @"""56.5""";

        var serialized = JsonSerializer.Serialize(percentage);
        var deserialized = JsonSerializer.Deserialize<Percentage>(serialized);
        Assert.Equal(expected, serialized);
        Assert.Equal(percentage, deserialized);
    }

    [InlineData("47.1", 47.1)]
    [InlineData("32", 32)]
    [Theory(DisplayName = "Deserializes a percentage with invariant culture")]
    public void GivenPercentage_CanDeserialize(string pct, decimal expected)
    {
        var serialized = $@"""{pct}""";
        var deserialized = JsonSerializer.Deserialize<Percentage>(serialized);
        Assert.NotNull(deserialized);
        Assert.Equal(expected, deserialized.Value);
    }

    [Fact(DisplayName = "Should raise DomainPrimitiveArgumentException if value is invalid")]
    public void GivenInvalidPercentage_ShouldRaiseDomainPrimitiveArgumentException()
    {
        Assert.Throws<DomainPrimitiveArgumentException<decimal>>(() => new Percentage(decimal.MinValue));
        Assert.Throws<DomainPrimitiveArgumentException<decimal>>(() => new Percentage(decimal.MinusOne));
        Assert.Throws<DomainPrimitiveArgumentException<decimal>>(() => new Percentage(101));
        Assert.Throws<DomainPrimitiveArgumentException<decimal>>(() => new Percentage(decimal.MaxValue));
    }

    [Fact(DisplayName = "Can create a percentage")]
    public void GivenValidInputValue_ShouldCreateANewPercentage()
    {
        for (var value = 1m; value <= 100m; value++)
        {
            var percentage = new Percentage(value);
            Assert.NotNull(percentage);
        }
    }
}