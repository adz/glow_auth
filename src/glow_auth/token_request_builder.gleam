//// Request Builder to help building up token requests.
////
//// It's basically just a [Request](https://hexdocs.pm/gleam_http/gleam/http/request.html#Request)
//// with additional Params to form-encode in the body, or (less commonly) use
//// as the query part of the Uri.
////
//// TODO: Rename to TokenTokenRequestBuilder?
////
//// Some requirements:
////  *  MAY have query component
////  *  MUST NOT have fragment component
////  *  MUST use TLS
////  *  MUST be "POST"
////  *  Params without value MUST be same as omission
////  *  No repeat params
////  *  `scope` space-delimited case insensitive strings defined by auth server
////    *  MAY full or partly ignore
////    *  If different, MUST include `scope` in response
////    *  A default must be defined

import gleam/uri.{Uri}
import gleam/option
import gleam/result
import gleam/http
import gleam/http.{Scheme}
import gleam/http/request.{Request}
import glow_auth/uri/params.{Params}

pub type TokenRequestBuilder(body) {
  TokenRequestBuilder(request: Request(body), params: Params)
}

/// Constructor: from request
pub fn from_request(request: Request(body)) -> TokenRequestBuilder(body) {
  TokenRequestBuilder(request: request, params: params.new())
}

/// Access Tokens are requested by form encoded values in the body, while the
/// server returns json.
///
/// Some flows allow a GET request where the request query-encodes into the uri.
///
/// This function handles both depending on the request.method.
pub fn to_token_request(rb: TokenRequestBuilder(body)) -> Request(String) {
  case rb.request.method {
    http.Get ->
      rb.request
      |> request.set_query(params.to_list(rb.params))
      |> request.set_body("")

    _ ->
      rb.request
      |> request.prepend_header(
        "content-type",
        "application/x-www-form-urlencoded",
      )
      |> request.prepend_header("accept", "application/json")
      |> request.set_body(params.to_query(rb.params))
  }
}

/// Put one param in
pub fn put_param(rb: TokenRequestBuilder(body), key: String, value: String) {
  rb.params
  |> params.put(key, value)
  |> set_params(rb, _)
}

/// Set all the Params
pub fn set_params(
  rb: TokenRequestBuilder(body),
  params: Params,
) -> TokenRequestBuilder(body) {
  TokenRequestBuilder(..rb, params: params)
}

/// Map `f` over the request.
pub fn map_request(
  rb: TokenRequestBuilder(a),
  f: fn(Request(a)) -> Request(b),
) -> TokenRequestBuilder(b) {
  TokenRequestBuilder(request: f(rb.request), params: rb.params)
}

/// Convert a Uri to a TokenRequestBuilder
///
/// Note that Request requires a schema and host, but uri doesn't, so here:
///  * If you don't specify a scheme, `https` is assumed
///  * If you don't specify a host, `localhost` is assumed
pub fn from_uri(uri: Uri) -> TokenRequestBuilder(String) {
  Request(
    method: http.Post,
    headers: [],
    body: "",
    scheme: scheme_from_uri(uri, default: http.Https),
    host: option.unwrap(uri.host, "localhost"),
    port: uri.port,
    path: uri.path,
    query: uri.query,
  )
  |> from_request()
}

fn scheme_from_uri(uri: Uri, default default_scheme: Scheme) {
  uri.scheme
  |> option.unwrap("")
  |> http.scheme_from_string()
  |> result.unwrap(default_scheme)
}
