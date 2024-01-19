import gleam/dict.{type Dict}
import gleam/uri

pub type Params {
  Params(map: Dict(String, String))
}

pub fn from_map(map: Dict(String, String)) -> Params {
  Params(map: map)
}

pub fn new() -> Params {
  from_map(dict.new())
}

pub fn put(params: Params, key: String, value: String) -> Params {
  params.map
  |> dict.insert(key, value)
  |> Params()
}

pub fn to_list(params: Params) -> List(#(String, String)) {
  params.map
  |> dict.to_list()
}

pub fn to_query(params: Params) -> String {
  params
  |> to_list()
  |> uri.query_to_string()
}
