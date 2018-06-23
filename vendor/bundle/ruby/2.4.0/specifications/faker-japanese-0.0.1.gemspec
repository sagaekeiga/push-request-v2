# -*- encoding: utf-8 -*-
# stub: faker-japanese 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "faker-japanese".freeze
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["tily".freeze]
  s.date = "2011-09-29"
  s.description = "Faker in Japanese".freeze
  s.email = "tily05@gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "LICENSE.naist-jdic".freeze, "README.md".freeze]
  s.files = ["LICENSE".freeze, "LICENSE.naist-jdic".freeze, "README.md".freeze]
  s.homepage = "http://github.com/tily/ruby-faker-japanese".freeze
  s.rubygems_version = "2.6.13".freeze
  s.summary = "Faker in Japanese".freeze

  s.installed_by_version = "2.6.13" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>.freeze, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, [">= 1.2.9"])
  end
end
