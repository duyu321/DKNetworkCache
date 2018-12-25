
Pod::Spec.new do |s|
  s.name         = "DKNetworkCache"
  s.version      = "0.0.1"
  s.ios.deployment_target = '8.0'
  s.summary      = "An AFN and FMDB encapsulation with cache"
  s.homepage     = "https://github.com/duyu321/DKNetworkCache"
  s.license      = "MIT"
  s.author             = { "duyu321" => "291168744@qq.com" }
  s.social_media_url   = "http://weibo.com/exceptions"
  s.source       = { :git => "https://github.com/duyu321/DKNetworkCache.git", :tag => s.version }
  s.source_files  = "DKNetworkCache"
  s.requires_arc = true
  #s.frameworks = "Foundation","UIKit","libsqlite3"
  s.dependency "AFNetworking", "~> 3.2.1"
  s.dependency "FMDB", "~> 2.7.5"
  s.dependency "MJExtension", "~> 3.0.15.1"
end
