import gleam/uri.{Uri}

pub type Client(body) {
  Client(id: String, secret: String, site: Uri)
}

pub fn new(id: String, secret: String, site: Uri) {
  Client(id, secret, site)
}
