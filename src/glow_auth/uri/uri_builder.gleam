//// Uri Builder helps to append relative paths to a Uri, but!
////
//// with the capacity to fully replace the path
//// ...or full Uri via an explicit UriAppendage type.
////

import gleam/uri.{Uri}
import gleam/string

/// Uri Appendage defines a few handy ways of appending to an existing Uri.
///
/// See `append` for how you can use this.
pub type UriAppendage {
  /// Represent a relative path, expected to be directly appended to existing Uri.
  RelativePath(String)

  /// Represent a full path, expected to completely replace an existing Uri.
  FullPath(String)

  /// Represent a full uri, expected to completely replace the Uri.
  FullUri(Uri)
}

/// Append to an existing Uri in explicit ways.
///
/// ## Examples
///
/// ```gleam
/// > import gleam/uri.Uri
/// >
/// > my_uri = Uri(Some("https"), None, Some("example.com"), Some(443), "/the/path", None, None)
/// > RelativePath("to/the/thing") |> uri_append(to: my_uri)
/// 
/// Uri(...my_uri, path: "/the/path/to/the/thing")
///
/// > FullPath("to/the/thing") |> uri_append(to: my_uri)
/// 
/// Uri(...my_uri, path: "to/the/thing")
///
/// > another_uri = Uri(Some("http"), None, Some("localhost"), Some(80), "/over/here", None, None)
/// > FullUri(another_uri) |> uri_append(to: my_uri)
///
/// another_uri // <- it is the same as identity(another_uri)
///
pub fn append(to uri: Uri, with appendage: UriAppendage) -> Uri {
  case appendage {
    RelativePath(path) ->
      Uri(
        ..uri,
        path: [uri.path, path]
        |> string.join("/"),
      )
    FullPath(path) -> Uri(..uri, path: path)
    FullUri(uri) -> uri
  }
}
