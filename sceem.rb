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

class Procedure
  attr_accessor :parameters, :body, :environment

  def initialize(parameters, body, environment)
    self.parameters = parameters
    self.body = body
    self.environment = environment
  end

  def apply(arguments)
    procedure_environment = self.environment.dup

    self.parameters.each_with_index do |param, idx|
      procedure_environment[param] = arguments[idx]
    end

    evaluate(self.body, procedure_environment)
  end
end

def make_lambda(expression, environment)
  Procedure.new(expression[1], expression[2], environment)
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
  else
    operator = evaluate(expression.first, environment)
    operands = expression[1..-1].map {|arg| evaluate(arg, environment) }

    if operator.is_a?(Procedure)
      operator.apply(operands)
    else
      procedure = environment[expression.first]
      if procedure.respond_to?(:call)
        procedure.call(*operands)
      elsif procedure.is_a?(Procedure)
        procedure.apply(operands)
      else
        puts "error: not a procedure"
      end
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

GLOBAL_ENVIRONMENT = {
  :+       => lambda {|*args| args.inject(:+) },
  :-       => lambda {|*args| args.inject(:-) },
  :*       => lambda {|*args| args.inject(:*) },
  :/       => lambda {|*args| args.inject(:/) },
  :println => lambda {|*args| puts args.join(' ') }
}

PROMPT = 'sceems> '

puts 'Welcome to sceems!'
print PROMPT

while line = STDIN.gets
  tokens = tokenize(line)
  parsed = parse(tokens)
  result = evaluate(parsed, GLOBAL_ENVIRONMENT)
  puts result.inspect if result
  print PROMPT
end
