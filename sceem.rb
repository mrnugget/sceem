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

def evaluate(expression, environment)
  if self_evaluating?(expression)
    expression
  elsif variable?(expression)
    environment[expression]
  elsif definition?(expression)
    make_definition(expression, environment)
  else
    procedure = environment[expression.first]
    args = expression[1..-1].map {|arg| evaluate(arg, environment) }
    if procedure.respond_to?(:call)
      procedure.call(*args)
    else
      puts "error: not a procedure"
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
    sub_list
  else
    convert_to_atom(token)
  end
end

GLOBAL_ENVIRONMENT = {
  :+ => lambda {|*args| args.inject(:+) },
  :- => lambda {|*args| args.inject(:-) },
  :* => lambda {|*args| args.inject(:*) },
  :/ => lambda {|*args| args.inject(:/) }
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
