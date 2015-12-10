# coding: utf-8
lib = File.expand_path('../lib/plan_out/version', __FILE__)
require lib

Gem::Specification.new do |spec|
  spec.name          = "planout"
  spec.version       = PlanOut::VERSION
  spec.authors       = ["Eytan Bakshy", "Mohnish Thallavajhula"]
  spec.email         = ["ebakshy@gmail.com", "i@mohni.sh"]
  spec.summary       = %q{PlanOut is a framework and programming language for online field experimentation.}
  spec.description   = %q{PlanOut is a framework and programming language for online field experimentation. PlanOut was created to make it easy to run and iterate on sophisticated experiments, while satisfying the constraints of deployed Internet services with many users.}
  spec.homepage      = "https://facebook.github.io/planout"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency "rake", "~> 10.0"
end
