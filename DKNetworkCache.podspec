
Pod::Spec.new do |s|
  s.name         = "DKNetworkCache"    #存储库名称
  s.version      = "0.0.1"      #版本号，与tag值一致
  s.summary      = "An AFN and FMDB encapsulation with cache"  #简介
  s.description  = "An AFN and FMDB encapsulation with cache"  #描述
  s.homepage     = "https://github.com/duyu321/DKNetworkCache"   #项目主页，不是git地址
  s.license      = { :type => "MIT", :file => "LICENSE" }   #开源协议
  s.author             = { "duyu321" => "291168744@qq.com" }  #作者
  s.platform     = :ios, "8.0"                  #支持的平台和版本号
  s.source       = { :git => "https://github.com/duyu321/DKNetworkCache.git", :tag => "0.0.1" }         #存储库的git地址，以及tag值
  s.source_files  =  "DKNetworkCache/*.{h,m}" #需要托管的源代码路径
  s.requires_arc = true #是否支持ARC
  s.library = "sqlite3" #指定导入的库，比如sqlite3
  s.dependency "AFNetworking"    #所依赖的第三方库，没有就不用写
  s.dependency "FMDB"
  s.dependency "MJExtension"

end
