if Settings.dropbox.path =~ %r{^s3://}
  Avalon::Batch::Manifest.concrete_class = Avalon::Batch::S3Manifest
elsif Settings.dropbox.path_to_files =~ %r{^s3://}
  Avalon::Batch::Manifest.concrete_class = Avalon::Batch::HybridManifest
end
