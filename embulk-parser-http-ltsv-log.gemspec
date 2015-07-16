
Gem::Specification.new do |spec|
  spec.name          = "embulk-parser-http-ltsv-log"
  spec.version       = "0.1.0"
  spec.authors       = ["Hirokazu Hata"]
  spec.summary       = "Http Ltsv Log parser plugin for Embulk"
  spec.description   = "Parses Http Ltsv Log files read by other file input plugins."
  spec.email         = ["h.hata.ai.t@gmail.com"]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com/h.hata.ai.t/embulk-parser-http-ltsv-log"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  #spec.add_dependency 'YOUR_GEM_DEPENDENCY', ['~> YOUR_GEM_DEPENDENCY_VERSION']
  spec.add_development_dependency 'bundler', ['~> 1.0']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
