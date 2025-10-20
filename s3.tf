# create a new bucket
resource "aws_s3_bucket" "s3_bucket_barath" {
  bucket = "nodejs-barath-bucket"

  tags = {
    Name        = "NodeJs Static Files"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "s3_object_barath" {
  bucket   = aws_s3_bucket.s3_bucket_barath.bucket
  for_each = fileset("../public/images", "**") # get all files in the images directory.
  key      = "images/${each.key}" # each.key is the filename
  source   = "../public/images/${each.key}"  # source directory
  
}

