using DontPanicLabs.Ifx.Configuration.Local;
using DontPanicLabs.Ifx.Services.Contracts;
using TB.AU.Utility.Auth.Interface;
using TB.AU.Utility.Auth.Interface.Criteria;
using TB.AU.Utility.Auth.Interface.Result;

namespace TB.AU.Utility.Auth.Service;

/// <summary>
/// Implementation of IAuthUtility that utilizes Permit.io for authorization checks.
/// This service requires a configured API key and endpoint in your application settings.
/// The PermitClient is initialized as a static instance, but alternatively, this service
/// could be registered as a singleton in your dependency injection container.
/// For more information about Permit.io, see: https://docs.permit.io
/// </summary>
internal class AuthUtility : ServiceBase, IAuthUtility
{
    private static readonly PermitSDK.Permit PermitClient;

    static AuthUtility()
    {
        var config = new Config();
        var apiKey = config["ifx:permit:apiKey"];
        var endpoint = config["ifx:permit:endpoint"];

        PermitClient = new PermitSDK.Permit(apiKey, endpoint);
    }

    public async Task<AuthCheckResultBase> Check(AuthCheckCriteriaBase criteria)
    {
        throw new NotImplementedException();
    }
}