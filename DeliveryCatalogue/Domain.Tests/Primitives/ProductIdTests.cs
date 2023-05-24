using System;
using System.Text.Json;
using Domain.Exceptions;
using Domain.Primitives;
using Xunit;
using Xunit.Abstractions;

namespace Domain.Tests.Primitives;

public class ProductIdTests
{
    private readonly ITestOutputHelper _testOutputHelper;

    public ProductIdTests(ITestOutputHelper testOutputHelper)
    {
        _testOutputHelper = testOutputHelper;
    }

    [InlineData(null)]
    [InlineData("")]
    [InlineData(" ")]
    [InlineData("invalid input")]
    [Theory(DisplayName = "Should raise exception when input string is null, empty, whitespace or invalid")]
    public void GivenProductId_WhenTheStringIsInvalid_RaiseDomainPrimitiveArgumentException(string invalidId)
    {
        var exception = Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductId(invalidId));
        _testOutputHelper.WriteLine(exception.Message);
    }

    [Fact(DisplayName = "Should raise exception when input is empty guid")]
    public void GivenProductId_WhenEmptyGuid_RaiseDomainPrimitiveArgumentException()
    {
        // given
        var emptyGuidString = Guid.Empty.ToString("D");
        
        // then
        Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductId(emptyGuidString));
        Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductId(Guid.Empty));
    }

    [InlineData("B")]
    [InlineData("N")]
    [InlineData("P")]
    [InlineData("X")]
    [Theory(DisplayName = "Should raise exception when input has illegal format")]
    public void GivenProductId_WhenInputHasInvalidFormat_RaiseDomainPrimitiveArgumentException(string illegalFormat)
    {
        // given
        var idAsStringIllegalFormat = Guid.NewGuid().ToString(illegalFormat);

        // then
        Assert.Throws<DomainPrimitiveArgumentException<string>>(() => new ProductId(idAsStringIllegalFormat));
    }

    [Fact(DisplayName = "Should treat as equal if values are the same")]
    public void GivenTwoProductIds_WhenCreatedWithCorrectGuid_ValueShouldBeTheSame()
    {
        // given
        const string idAsString = "3bce3f70-5ca1-446f-ac15-58a38fed3b28";
        var idAsGuid = Guid.ParseExact(idAsString, "D");

        // when
        var productId1 = new ProductId(idAsString);
        var productId2 = new ProductId(idAsGuid);

        // then
        Assert.Equal(productId1, productId2);
        Assert.Equal(productId1.Value, productId2.Value);
    }

    [Fact(DisplayName = "Should have equal hash codes if values are the same")]
    public void GivenTwoProductIds_HavingEqualValues_ShouldHaveEqualHashCodes()
    {
        // given
        var idAsGuid = Guid.NewGuid();

        // when
        var productId1 = new ProductId(idAsGuid);
        var productId2 = new ProductId(idAsGuid);

        // then
        Assert.Equal(productId1.GetHashCode(), productId2.GetHashCode());
    }

    [Fact(DisplayName = "When generating a new product id, should be unique")]
    public void GivenTwoNewProductId_WhenCheckingForEquality_ShouldBeUnique()
    {
        // given
        var productId1 = ProductId.NewProductId();
        var productId2 = ProductId.NewProductId();

        // then
        Assert.NotEqual(productId1, productId2);
        Assert.NotStrictEqual(productId1, productId2);
        Assert.NotEqual(productId1.Value, productId2.Value);
    }
    
    [Fact(DisplayName = "Can serialize product id correctly")]
    public void GivenProductId_WhenSerialized_ValueShouldMatch()
    {
        const string idAsString = "c44441d9-8f15-4789-8256-4a28517c7d56";
        var productId = new ProductId(idAsString);

        const string expected = $@"""{idAsString}""";

        var serialized = JsonSerializer.Serialize(productId);
        Assert.Equal(expected, serialized);
    }
    
    [Fact(DisplayName = "Can serialize and deserialize a product id correctly")]
    public void GivenProductId_WhenSerialized_CanDeserialize()
    {
        const string idAsString = "c44441d9-8f15-4789-8256-4a28517c7d56";
        var productId = new ProductId(idAsString);

        const string expected = $@"""{idAsString}""";

        var serialized = JsonSerializer.Serialize(productId);
        var deserialized = JsonSerializer.Deserialize<ProductId>(serialized);
        Assert.Equal(expected, serialized);
        Assert.Equal(productId, deserialized);
    }
}