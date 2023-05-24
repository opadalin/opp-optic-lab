using System;
using Domain.Primitives;

namespace Domain.Models;

public record Product
{
    public Product(ProductId id, ProductName name, Quantity quantity)
    {
        ArgumentNullException.ThrowIfNull(id);
        ArgumentNullException.ThrowIfNull(name);
        ArgumentNullException.ThrowIfNull(quantity);
        
        Id = id;
        Name = name;
        Quantity = quantity;
    }

    public ProductId Id { get; }
    public ProductName Name { get; }
    public Quantity Quantity { get; }
}