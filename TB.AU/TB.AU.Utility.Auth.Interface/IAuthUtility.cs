using DontPanicLabs.Ifx.Services.Contracts;
using TB.AU.Utility.Auth.Interface.Criteria;
using TB.AU.Utility.Auth.Interface.Result;

namespace TB.AU.Utility.Auth.Interface;

public interface IAuthUtility : IUtility
{
    Task<AuthCheckResultBase> Check(AuthCheckCriteriaBase criteria);
}