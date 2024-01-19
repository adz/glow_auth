//// WIP -- not used, but the idea is to help out in decode of access token...

import gleam/string
import gleam/list
import gleam/result
import gleam/http.{type Header}
import gleam/http/request.{type Request}

pub fn content_type_from_request(request: Request(body)) -> String {
  case get_content_type_header(request.headers) {
    Ok(content_type) ->
      content_type
      |> remove_params

    // TODO: parse content type
    // |> parse_content_type
    Error(_) -> "application/json"
  }
}

fn remove_params(content_type: String) -> String {
  content_type
  |> string.split(on: ";")
  // split returns at least one element, but 
  // that isn't represented in 'list' type returned
  // ... so unwrap the result
  |> list.first()
  |> result.unwrap("")
}

// fn parse_content_type(content_type: String) -> Result(String) {
// case String.split(content_type, "/") do
//   [type, subtype] ->
//     type <> "/" <> subtype
//   _ ->
//     raise OAuth2.Error, reason: "bad content-type: #{content_type}"
// }

fn get_content_type_header(headers: List(Header)) -> Result(String, Nil) {
  headers
  |> list.key_find("content-type")
}
