namespace Domain.Primitives;

public interface IDomainPrimitive<out T>
{
    T Value { get; }
}