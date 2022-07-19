import gleam/uri.{Uri}
import gleam/option
import gleam/result
import gleam/http
import gleam/http.{Scheme}
import gleam/http/request.{Request}
import glow_auth/uri/params.{Params}

// TODO: Rename to TokenRequestBuilder?

pub type RequestBuilder(body) {
  RequestBuilder(request: Request(body), params: Params)
}

/// Constructor: from request
pub fn from_request(request: Request(body)) -> RequestBuilder(body) {
  RequestBuilder(request: request, params: params.new())
}

/// Access Tokens are requested by form encoded values in the body, while the
/// server returns json.
///
/// Some flows allow a GET request where the request query-encodes into the uri.
///
/// This function handles both depending on the request.method.
pub fn to_token_request(rb: RequestBuilder(body)) -> Request(String) {
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

pub fn put_param(rb: RequestBuilder(body), key: String, value: String) {
  rb.params
  |> params.put(key, value)
  |> set_params(rb, _)
}

pub fn set_params(
  rb: RequestBuilder(body),
  params: Params,
) -> RequestBuilder(body) {
  RequestBuilder(..rb, params: params)
}

pub fn map_request(
  rb: RequestBuilder(a),
  f: fn(Request(a)) -> Request(b),
) -> RequestBuilder(b) {
  RequestBuilder(request: f(rb.request), params: rb.params)
}

/// Convert a Uri to a RequestBuilder
///
/// Note that Request requires a schema and host, but uri doesn't, so here:
///  * If you don't specify a scheme, `https` is assumed
///  * If you don't specify a host, `localhost` is assumed
pub fn from_uri(uri: Uri) -> RequestBuilder(String) {
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
