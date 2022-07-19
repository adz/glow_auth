import gleam/map.{Map}
import gleam/uri
import gleam/option.{None, Some}

pub type Params {
  Params(map: Map(String, String))
}

pub fn from_map(map: Map(String, String)) -> Params {
  Params(map: map)
}

pub fn new() -> Params {
  from_map(map.new())
}

pub fn from_list(list: List(#(String, String))) -> Params {
  from_map(map.from_list(list))
}

pub fn put(params: Params, key: String, value: String) -> Params {
  params.map
  |> map.insert(key, value)
  |> Params()
}

/// Put the opt_value param in, but only if it is Some(value)
pub fn put_option(params, key, opt_value) -> Params {
  case opt_value {
    Some(value) -> put(params, key, value)
    None -> params
  }
}

pub fn to_list(params: Params) -> List(#(String, String)) {
  params.map
  |> map.to_list()
}

pub fn to_query(params: Params) -> String {
  params
  |> to_list()
  |> uri.query_to_string()
}
