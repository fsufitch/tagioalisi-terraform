### Configuration for the web interface runtime

resource "aws_s3_bucket" "web" {
  bucket = format("Tagioalisi-Web__%s", var.stack_suffix)
  acl    = "public-read"

  # TODO: allow pipeline service role write access

  website {
    index_document = "index.html"
    error_document = "index.html" # hm...
  }
}

# TODO: cloudfront distribution? cert? HTTPS?
