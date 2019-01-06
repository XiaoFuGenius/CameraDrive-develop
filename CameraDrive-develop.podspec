# 常用命令：pod
# 本地 验证 podspec 文件：$ pod lib lint
# 本地&远程 验证 podspec 文件：$ pod spec lint
# 获取验证 podspec 文件时产生的详细信息：$ pod lib lint --verbose
# 移除验证 podspec 文件时产生的一般警告：$ pod lib lint --allow-warnings
# 第三方库的依赖中包含.a文件：$ pod lib lint --use-libraries
# 第三方库是私有库，需要添加源：$ pod lib lint --sources=https://github.com/CocoaPods/Specs.git,[第三方库源]
# 当前 podspec 文件验证：$ pod lib lint --sources=https://github.com/CocoaPods/Specs.git,https://github.com/aliyun/aliyun-specs.git,https://github.com/sinaweibosdk/weibo_ios_sdk.git --use-libraries --allow-warnings --verbose
# 添加&更新 私有repo 中的 podspec 文件：pod repo push [私有repo] [.podspec文件路径]

Pod::Spec.new do |s|
  s.name         = "CameraDrive-develop" 		# 项目名称
  s.version      = "1.0.9" 		# 版本号 与 你仓库的 标签号 对应
  s.license      = "MIT" 	 # 开源证书
  s.summary      = "iOS 快捷开发工具包 CameraDrive.framework Develop." 	# 项目简介
  s.deprecated = false

  s.homepage     = "https://github.com/XiaoFuGenius/CameraDrive-develop" 	# 你的主页
  s.source       = { :git => "https://github.com/XiaoFuGenius/CameraDrive-develop.git", :tag => "#{s.version}" } 	# 你的仓库地址
  s.requires_arc = true 	# 是否启用ARC
  s.platform     = :ios, "8.0" 		#平台及支持的最低版本
  s.vendored_frameworks = "Frameworks/CameraDrive.framework" 	#第三方库依赖
  s.frameworks   = "UIKit", "Foundation" 	#支持的框架
  
  # User
  s.author             = { "XIAOFU" => "https://github.com/XiaoFuGenius" } 	# 作者信息
  s.social_media_url   = "https://github.com/XiaoFuGenius" 	# 个人主页

end