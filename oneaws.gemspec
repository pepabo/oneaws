require_relative 'lib/oneaws/version'

Gem::Specification.new do |spec|
  spec.name          = "oneaws"
  spec.version       = Oneaws::VERSION
  spec.authors       = ["Yuki Koya"]
  spec.email         = ["ykky@pepabo.com"]

  spec.summary       = %q{Issue temporary credentials using OneLogin and AWS STS.}
  spec.description   = %q{Issue temporary credentials using OneLogin and AWS STS.}
  spec.homepage      = "https://github.com/pepabo/oneaws"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pepabo/oneaws"
  spec.metadata["changelog_uri"] = "https://github.com/pepabo/oneaws"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'onelogin'
  spec.add_dependency 'aws-sdk-core'
  spec.add_dependency 'inifile'
end
