using System;
using System.Security.Cryptography;
using System.Text;

namespace Utilities;

public class RandomString
{
    private const int MinLength = 1;
    private readonly int _length;
    private char[] _validCharacters;

    private RandomString(int length)
    {
        ArgumentNullException.ThrowIfNull(length);
        if (length < MinLength)
        {
            throw new ArgumentOutOfRangeException(nameof(length), $"Argument is out of range: {length}. Length must be more than 0");
        }

        _length = length;
    }

    public static RandomString Create(int length)
    {
        return new RandomString(length);
    }

    public RandomString WithValidCharacters(string validCharacters)
    {
        ArgumentNullException.ThrowIfNull(validCharacters);
        if (validCharacters.Length < MinLength)
        {
            throw new ArgumentOutOfRangeException(nameof(validCharacters),
                $"Argument is out of range: {validCharacters.Length}. Provide at least one valid character");
        }

        _validCharacters = validCharacters.ToCharArray();
        return this;
    }

    public override string ToString()
    {
        if (_validCharacters is null || _validCharacters.Length == 0)
        {
            _validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".ToCharArray();
        }

        var data = new byte[4 * _length];
        using var randomNumberGenerator = RandomNumberGenerator.Create();
        randomNumberGenerator.GetBytes(data);
        var stringBuilder = new StringBuilder(_length);
        for (var i = 0; i < _length; i++)
        {
            var rnd = BitConverter.ToUInt32(data, i * 4);
            var index = rnd % _validCharacters.Length;
            stringBuilder.Append(_validCharacters[index]);
        }

        return stringBuilder.ToString();
    }
}