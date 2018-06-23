#!/usr/bin/env ruby

$: << '.'
$: << '../lib'
$: << '../ext'

require 'tracer'
require 'oj'
require 'sample'

class Foo
  def initialize()
    @x = 'abc'
    @y = 123
    @a = [{}]
  end

  def to_json()
    '{"x":33}'
  end

  def as_json(options={})
    { z: @a, y: @y, x: @x }
  end
end

Tracer.display_c_call = true
Tracer.on

obj = Foo.new

j = Oj.dump(obj, mode: :custom, trace: true, use_as_json: true)

#puts j

#Oj.load(j, mode: :rails, trace: true)
