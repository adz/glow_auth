import gleam/map.{Map}
import gleam/uri

pub type Params {
  Params(map: Map(String, String))
}

pub fn from_map(map: Map(String, String)) -> Params {
  Params(map: map)
}

pub fn new() -> Params {
  from_map(map.new())
}

pub fn put(params: Params, key: String, value: String) -> Params {
  params.map
  |> map.insert(key, value)
  |> Params()
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
