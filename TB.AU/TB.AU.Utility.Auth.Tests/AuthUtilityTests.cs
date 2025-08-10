namespace TB.AU.Utility.Auth.Tests;

/// <summary>
/// These tests can be used to test integration with Permit.io if you add in an
/// API key (suggested method below in your user secrets).
///
/// If you're running Permit's container locally, you can use the endpoint "http://localhost:7766".
/// You can also run using "https://cloudpdp.api.permit.io", but keep in mind that this is not
/// recommended for production.
/// 
/// <code>
/// {
///   "ifx": {
///     "permit": {
///       "apiKey": "YOUR KEY HERE"
///     }
///   }
/// }
/// </code>
/// </summary>
[TestClass]
public class AuthUtilityTests
{
    [TestMethod]
    public void TestMethod1()
    {
    }
}