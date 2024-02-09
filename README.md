# Glow Auth -- for OAuth2

[![Package Version](https://img.shields.io/hexpm/v/glow_auth)](https://hex.pm/packages/glow_auth)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glow_auth/)

Glow Auth is a gleam OAuth 2.0 helper library.

See [RFC6749 - The OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
for all the gory details... however, relevant parts have been adapted
into the docs here.

## Installation

This package can be added to your Gleam project:

```sh
gleam add glow_auth
```

and its documentation can be found at <https://hexdocs.pm/glow_auth>.

The OAuth 2.0 authorization framework enables a third-party
application to obtain limited access to an HTTP service, either on
behalf of a resource owner (e.g. a user) by orchestrating an approval
interaction between the resource owner and the HTTP service, or by
allowing the third-party application to obtain access on its own behalf.


# Grant Types

Access is granted by way of one of the following grant types:

 * Authorization Code, 
 * Implicit (not supported),
 * Resource Owner Password Credentials (not supported), 
 * Client Credentials,
 * Extension Grants (not supported).

Each grant type differs in details, but will result in an 'access token'
when successful. See below for specifics.

Once granted an 'access token', it is typically included as a header
in your requests to access the HTTP service.

 * Use [glow_auth#authorization_header](./glow_auth.html#authorization_header)
   to embed the access token as a header in your request.

It's pretty common for these to have an expiry and support a refresh flow.

 * Use [glow_auth.token_request#refresh](./glow_auth/token_request.html#refresh)
   to refresh a token.

## Authorization Code

Note that the 'client' would typically be your gleam app running as a
web server:

     +----------+          Client Identifier      +---------------+
     |         -+----(A)-- & Redirection URI ---->|               |
     | Browser  |                                 | Authorization |
     |         -+----(B)-- User authenticates --->|     Server    |
     |          |                                 |               |
     |         -+----(C)-- Authorization Code ---<|               |
     +-|----|---+                                 +---------------+
       |    |                                         ^      v
      (A)  (C)                                        |      |
       |    |                                         |      |
       ^    v                                         |      |
     +---------+                                      |      |
     |         |>---(D)-- Authorization Code ---------'      |
     |  Client |          & Redirection URI                  |
     |         |                                             |
     |         |<---(E)----- Access Token -------------------'
     +---------+       (w/ Optional Refresh Token)

[RFC6849: Section 4.1]( https://datatracker.ietf.org/doc/html/rfc6749#section-4.1 )

In this grant type, the users browser is directed to an authorization
server (A) to authenticate (B) and establish whether the user wants to
grant or deny access. When successful, the authorization server
redirects the user back with an 'authorization code' in the uri (C).

 * Use [glow_auth/authorize_uri](./glow_auth/authorize_uri.html) to build up the
   authorization uri to redirect to. 

After receiving the 'authorization code' you must use it to request an
'access token' from the authorization server.

 * Use [glow_auth/token_request#authorize_code](./glow_auth/token_request.html#authorize_code)
   to request an access token.
   * Note: must include the redirection URI used to obtain the 'authorization code'.
 * Use [glow_auth/access_token#decoder](./glow_auth/access_token.html#decoder)
   to decode an access token response to an [Access Token](./glow_auth/access_token.html#AccessToken).

## Implicit

The implicit grant is a simplified authorization code flow optimized
for clients implemented in a browser using a scripting language such
as JavaScript.  In the implicit flow, instead of issuing the client
an authorization code, the client is issued an access token directly.

Not supported.


## Resource Owner Password Credentials

The resource owner password credentials (i.e., username and password)
can be used directly as an authorization grant to obtain an access
token.  The credentials should only be used when there is a high
degree of trust between the resource owner and the client (e.g., the
client is part of the device operating system or a highly privileged
application), and when other authorization grant types are not
available (such as an authorization code).

Not supported (yet).


## Client Credentials

     +---------+                                  +---------------+
     |         |                                  |               |
     |         |>--(A)- Client Authentication --->| Authorization |
     | Client  |                                  |     Server    |
     |         |<--(B)---- Access Token ---------<|               |
     |         |                                  |               |
     +---------+                                  +---------------+

   (A)  The client authenticates with the authorization server and
        requests an access token from the token endpoint.

   (B)  The authorization server authenticates the client, and if valid,
        issues an access token.

More details at [RFC 6749: Section 4.4](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4)

 * Use [glow_auth/token_request#client_credentials](./glow_auth/token_request.html#client_credentials)
   to do the token request.
 * Use [glow_auth/access_token#decoder](./glow_auth/access_token.html#decoder)
   to decode an access token response to an [Access Token](./glow_auth/access_token.html#AccessToken).

# Refreshing

Issuing a refresh token is optional at the discretion of the
authorization server.  _If_ the authorization server issues a refresh
token, it is included when issuing an access token, typically also with
seconds till expiry.

 * Use [glow_auth.token_request#refresh](./glow_auth/token_request.html#refresh)
   to refresh a token.


# Concurrency Considerations

 1. When receiving a code in an AuthCode flow redirect, be aware that if an
    auth code is used more than once, it MUST be denied, and all tokens
    previously issued based on it
 1. When refreshing a token, typically the old access tokens are revoked.
