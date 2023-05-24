using System;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Functions;

public class GetProductFunction
{
    private readonly ILogger _logger;

    public GetProductFunction(ILoggerFactory loggerFactory)
    {
        ArgumentNullException.ThrowIfNull(loggerFactory);

        _logger = loggerFactory.CreateLogger<GetProductFunction>();
    }

    [Function(nameof(GetProductFunction))]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "get", Route = "products/{productId}")]
        HttpRequestData req, string productId)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        await response.WriteStringAsync("Welcome to Azure Functions!", Encoding.UTF8);
        
        return response;
    }
}