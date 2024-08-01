# Usage Examples

## Prerequisites

To make use of the example code below, you will first need to follow your Identity Provider's 
process for creating a client id and client secret and obtaining the token request URI and 
scope value(s).

## Authorization Code

```
// TODO
```

## Client Credentials

```gleam
import gleam/hackney
import gleam/io
import gleam/result
import gleam/uri
import glow_auth.{Client}
import glow_auth/access_token.{decode_token_from_response}
import glow_auth/token_request.{RequestBody, ScopeString, client_credentials}
import glow_auth/uri/uri_builder.{RelativePath}

pub fn main() {
  // Replace the values for the let bindings with the values for your auth server
  // and client.
  let client_id = "<your client id>"
  let client_secret = "<your client secret>"
  let base_uri = "https://example.com"
  let token_endpoint = "token"
  let scope = "scope1 scope2[ ... scopeN]"

  // Use the values above to create and send a token request to the auth server.   
  //  1. Create the site Uri to serve as the base path.
  use site <- result.then(uri.parse(base_uri))

  //  2. Create a Client using the client_id, client_secret, and site.
  let client = Client(client_id, client_secret, site)

  //  3. Create a request by calling client_credentials with parameters:
  //    a. The Client created in step (2).
  //    b. The token path to be appended to the site Uri created in step (1).
  //    c. The AuthScheme. (RequestBody or AuthHeader)
  //    d. The Access Token Scope. (ScopeList, ScopeString, or DefaultScope)
  let request =
    client_credentials(
      client,
      RelativePath(token_endpoint),
      RequestBody,
      ScopeString(scope),
    )

  //  4. Send the token request to the auth server.
  let response = hackney.send(request)

  // 5. Decode the token from the response body when an Ok.
  //    Handle a Error response according to your application's needs.
  let token = case response {
    Ok(wrapped) -> decode_token_from_response(wrapped.body)
    _ -> panic
  }

  // View the Result token in the console.
  io.debug(token)
  |> Ok
}
```