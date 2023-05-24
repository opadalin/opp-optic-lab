using System.Text.Json;
using Domain.Exceptions;
using Domain.Primitives;
using Utilities;
using Xunit;

namespace Domain.Tests.Primitives;

public class ProductNameTests
{
    [InlineData(3)]
    [InlineData(150)]
    [Theory(DisplayName = "Should be able to create a product name with valid input")]
    public void GivenValidInput_WhenCreatingProductName_ShouldNotThrowException(int length)
    {
        // given 
        var name = RandomString.Create(length).WithValidCharacters("qwerty123456").ToString();

        // when
        var productName = new ProductName(name);

        // then
        Assert.NotNull(productName);
    }

    [InlineData(2)]
    [InlineData(151)]
    [Theory(DisplayName = "Should throw exception when input is either too small or too great")]
    public void GivenInputIsOutOfRange_WhenCreatingProductName_ShouldThrowException(int length)
    {
        // given
        var name = RandomString.Create(length).ToString();

        // then
        Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductName(name));
    }
    
    [InlineData("")]
    [InlineData(" ")]
    [InlineData(null)]
    [InlineData("_/?")]
    [Theory(DisplayName = "Should throw exception when input has illegal characters")]
    public void GivenInvalidInput_WhenCreatingProductName_ShouldThrowException(string input)
    {
        Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductName(input));
    }

    [Fact(DisplayName = "Given two product names with the same input, should treat as equal")]
    public void GivenSameInput_WhenComparingTwoProductNames_ShouldBeTheSame()
    {
        // given
        var name = RandomString.Create(length: 10).ToString();

        // when
        var productName1 = new ProductName(name);
        var productName2 = new ProductName(name);

        // then
        Assert.Equal(productName1, productName2);
        Assert.Equal(productName1.Value, productName2.Value);
        Assert.Equal(productName1.GetHashCode(), productName2.GetHashCode());
    }

    [Fact(DisplayName = "Can serialize product name")]
    public void GivenProductName_WhenSerialized_ValueShouldMatch()
    {
        // given
        var name = RandomString.Create(length: 10).ToString();
        
        var productName = new ProductName(name);
        var expected = @$"""{name}""";

        // when
        var serialized = JsonSerializer.Serialize(productName);

        // then
        Assert.Equal(expected, serialized);
    }

    [Fact(DisplayName = "Can serialize and deserialize a product name")]
    public void GivenProductName_WhenSerialized_CanDeserialize()
    {
        // given
        var name = RandomString.Create(length: 10).ToString();
        var productName = new ProductName(name);

        // when
        var serialized = JsonSerializer.Serialize(productName);
        var deserialized = JsonSerializer.Deserialize<ProductName>(serialized);

        // then
        Assert.Equal(productName, deserialized);
    }
}