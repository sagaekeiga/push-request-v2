# -*- encoding: utf-8 -*-
# stub: bootstrap-material-design 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "bootstrap-material-design".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Paul King".freeze]
  s.date = "2015-08-29"
  s.email = "freedomlijinfa@gmail.com".freeze
  s.homepage = "https://github.com/Aufree/bootstrap-material-design".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.4".freeze
  s.summary = "Material Design for Bootstrap".freeze

  s.installed_by_version = "2.7.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bootstrap-sass>.freeze, ["~> 3.0"])
    else
      s.add_dependency(%q<bootstrap-sass>.freeze, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<bootstrap-sass>.freeze, ["~> 3.0"])
  end
end
