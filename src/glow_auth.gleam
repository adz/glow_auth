import gleam/io

/// Endpoints
/// ---------
/// https://datatracker.ietf.org/doc/html/rfc6749#section-3o)
/// OAuth2 defines two authorization server endpoints:
///  - Authorization endpoint - obtain auth from resource owner via rediredct
///    - MAY have query component
///    - MUST NOT have fragment component
///    - MUST use TLS
///    - MUST support GET method
///    - MAY support POST as well
///    - Params without value MUST be same as omission
///    - No repeat params
///    - MUST include response_type
///   RESPONSE
///    - MUST include "code" for AuthCode, "token" for Implicit
///    - MUST return error if response_type is missing or misunderstood
///
///  - Token endpoint - used to retrieve a token
///    - MAY have query component
///    - MUST NOT have fragment component
///    - MUST use TLS
///    - MUST be "POST"
///    - Params without value MUST be same as omission
///    - No repeat params
///    - `scope` space-delimited case insensitive strings defined by auth server
///       - MAY full or partly ignore
///       - If different, MUST include `scope` in response
///       - A default must be defined
/// 
/// ... and one client endpoint
///  - Redirection endpoint - auth server redirects user here with a cred or code 
///    - MAY have query component
///    - MUST NOT have fragment component
///    - SHOULD use TLS for "code" or "token"
///    - Typically are registered in advance of usage
///    - Receiving response SHOULD NOT do js, but redirect again without exposing creds
///
///
/// AuthCode flow
/// -------------
/// Generate an authorisation uri, used by AuthCode and Implicit flows
/// Fetch a token using 'code' from authorisation uri redirect
/// Decode token response
///
/// Refresh flow
/// -------------
/// Fetch a token using 'refresh' token
/// Decode token response
///
/// ClientCredentials flow
/// ----------------------
/// Fetch a token
/// Decode token response
///
/// Requesting resources
/// --------------------
/// Append a token to a request header
/// Detect token is expiring, and deal
///  - Use refresh flow if given a refresh token in a token response
///  - Use plain fetch a token if ClientCredentials flow
///
/// Considering concurrency
/// -----------------------
/// Receiving a code in an AuthCode flow redirect:
///  - If an auth code is used more than once, it MUST be denied,
///    and all tokens previously issued based on it
pub fn main() {
  io.println("Hello from glowauth!")
  io.println("Mate")
}
