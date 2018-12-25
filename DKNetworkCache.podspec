
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
  s.dependency "AFNetworking"    #所依赖的第三方库，没有就不用写
  s.dependency "FMDB"
  s.dependency "MJExtension"
end
