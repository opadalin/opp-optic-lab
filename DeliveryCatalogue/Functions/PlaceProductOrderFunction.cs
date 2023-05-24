using System.Net;
using System.Threading.Tasks;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Functions;

public class PlaceProductOrderFunction
{
    private readonly ILogger _logger;

    public PlaceProductOrderFunction(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<PlaceProductOrderFunction>();
    }

    [Function(nameof(PlaceProductOrderFunction))]
    public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "post", Route = "products")] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        await response.WriteStringAsync("Welcome to Azure Functions!");

        return response;
    }
}