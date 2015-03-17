#!/usr/bin/env ruby

class Procedure
  attr_accessor :parameters, :body, :environment

  def initialize(parameters, body, environment)
    self.parameters = parameters
    self.body = body
    self.environment = environment
  end

  def call(*arguments)
    env = Environment.new(self.environment)
    self.parameters.each_with_index { |p, i| env[p] = arguments[i] }
    self.body.map {|expression| evaluate(expression, env) }.last
  end
end

class Environment < Hash
  attr_accessor :enclosing_environment
  def initialize(enclosing_environment)
    self.enclosing_environment = enclosing_environment
  end

  def [](key)
    self.fetch(key) { self.enclosing_environment[key] }
  end
end

def tokenize(str)
  str.gsub(/\(/, ' ( ').gsub(/\)/, ' ) ').split
end

def self_evaluating?(expression)
  expression.is_a?(Integer) || expression.is_a?(String)
end

def definition?(expression)
  expression.is_a?(Array) && expression.first == :define
end

def variable?(expression)
  expression.is_a?(Symbol)
end

def make_definition(expression, environment)
  definition_variable = expression[1]
  definition_value = expression[2]
  environment[definition_variable] = evaluate(definition_value, environment)
  nil
end

def lambda_definition?(expression)
  expression.is_a?(Array) && expression.first == :lambda
end

def if_expression?(expression)
  expression.is_a?(Array) && expression.first == :if
end

def make_lambda(expression, environment)
  Procedure.new(expression[1], expression[2..-1], environment)
end

def evaluate_if(expression, environment)
  predicate = expression[1]
  consequence = expression[2]

  if evaluate(predicate, environment)
    evaluate(consequence, environment)
  else
    if alternative = expression[3]
      evaluate(alternative, environment)
    end
  end
end

def begin_expression?(expression)
  expression.is_a?(Array) && expression.first == :begin
end

def evaluate_begin_expression(expression, environment)
  expression[1..-1].map {|exp| evaluate(exp, environment) }.last
end

def evaluate(expression, environment)
  if self_evaluating?(expression)
    expression
  elsif variable?(expression)
    environment[expression]
  elsif definition?(expression)
    make_definition(expression, environment)
  elsif lambda_definition?(expression)
    make_lambda(expression, environment)
  elsif if_expression?(expression)
    evaluate_if(expression, environment)
  elsif begin_expression?(expression)
    evaluate_begin_expression(expression, environment)
  else
    operator = evaluate(expression.first, environment)
    operands = expression[1..-1].map {|arg| evaluate(arg, environment) }

    if operator.respond_to?(:call)
      operator.call(*operands)
    else
      raise "error: '#{expression.first}' not a procedure"
    end
  end
end

def quoted_string?(token)
  token[0] == '"' && token[token.length-1] == '"'
end

def unquote_string(token)
  token.split('"')[1]
end

def convert_to_atom(token)
  Integer(token)
rescue ArgumentError
  quoted_string?(token) ? unquote_string(token) : token.to_sym
end

def parse(tokens)
  token = tokens.shift
  if token == '('
    sub_list = []
    while tokens.first != ')'
      sub_list.push(parse(tokens))
    end
    tokens.shift
    sub_list
  else
    convert_to_atom(token)
  end
end

def format_result(result)
  if result.is_a?(Array)
    "(" + result.map {|r| format_result(r) }.join(' ') + ")"
  else
    result.inspect
  end
end

def eval_print_line(line)
  return if line.strip.empty? || line.match(/\A;;/)

  tokens = tokenize(line)
  parsed = parse(tokens)
  result = evaluate(parsed, GLOBAL_ENVIRONMENT)
  puts format_result(result) if result
end


GLOBAL_ENVIRONMENT = Environment.new({
  :+       => lambda {|*args| args.inject(:+) },
  :-       => lambda {|*args| args.inject(:-) },
  :*       => lambda {|*args| args.inject(:*) },
  :/       => lambda {|*args| args.inject(:/) },
  :println => lambda {|*args| puts args.join(' ') },
  :eq?     => lambda {|a, b| a == b },
  :cons    => lambda {|a, b| [a, b] },
  :car     => lambda {|pair| pair[0] },
  :cdr     => lambda {|pair| pair[1].nil? ? nil : pair[1..-1].flatten },
  :nil?    => lambda {|arg| arg.nil? }
})


PROMPT = 'sceem> '

if $0 == __FILE__
  if !ARGV.empty? && File.exists?(ARGV.first)
    File.read(ARGV.first).lines.each { |line| eval_print_line(line) }
  end

  puts 'Welcome to sceem!'
  print PROMPT

  while line = STDIN.gets
    eval_print_line(line)
    print PROMPT
  end
end
