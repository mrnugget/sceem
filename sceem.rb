require 'readline'

def tokenize(str)
  str.gsub(/\(/, ' ( ').gsub(/\)/, ' ) ').split
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
    begin
      Integer(token)
    rescue ArgumentError
      if token[0] == '"' && token[token.length-1] == '"'
        token.split('"')[1]
      else
        token.to_sym
      end
    end
  end
end

def evaluate(expression, environment)
  if expression.is_a?(Integer) || expression.is_a?(String)
    expression
  elsif expression.is_a?(Symbol)
    environment[expression]
  elsif expression.is_a?(Array) && expression.first == :define
    definition_variable = expression[1]
    definition_value = expression[2]
    environment[definition_variable] = evaluate(definition_value, environment)
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
