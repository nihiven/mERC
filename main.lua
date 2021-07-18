-- mERK | mIRC Experimental Runtime Compiler
-- requires LUA 5.3

require 'class'
Inspect = require 'inspect'

--[[
    Token types
    EOF (end-of-file) token is used to indicate that
    there is no more input left for lexical analysis
]]
TYPES = {
 INTEGER = 'INTEGER',
 PLUS = 'PLUS',
 EOF = 'EOF',
}

---- Token Class
Token = class()

function Token:init(type, value)
  -- token type: INTEGER, PLUS, or EOF
  self._type = type
  -- token value: 0, 1, 2. 3, 4, 5, 6, 7, 8, 9, '+', or None
  self._value = value
end

function Token:__tostring()
  --[[
  String representation of the class instance.

  Examples:
    Token(INTEGER, 3)
    Token(PLUS '+')
  ]]
  return 'Token({'..self._type..'}, {'..self._value..'})'
end


---- mERC Interpreter class
Interpreter = class()

function Interpreter:init(text)
  -- client string input, e.g. "3+5"
  self._text = text
  -- self._pos is an index into self._text
  self._pos = 0
  -- current token instance (string)
  self._current_token = nil
end

function Interpreter:error(text)
  error('Error: ' .. text)
end

function Interpreter:get_next_token()
  --[[
    Lexical analyzer (also known as scanner or tokenizer)

    This method is responsible for breaking a sentence
    apart into tokens. One token at a time.
  ]]
  local text = self._text

  -- is self.pos index past the end of the self.text ?
  -- if so, then return EOF token because there is no more
  -- input left to convert into tokens
  if (self._pos > string.len(text)-1) then
    print('GNT > ','EOF')
    return Token(TYPES.EOF, nil)
  end

  -- get a character at the position self.pos and decide
  -- what token to create based on the single character
  local current_char = text:sub(self._pos+1, self._pos+1)
  print('Current char: ', current_char)

  -- if the character is a digit then convert it to
  -- integer, create an INTEGER token, increment self.pos
  -- index to point to the next character after the digit,
  -- and return the INTEGER token
  if (current_char == tostring(math.tointeger(current_char))) then
    print('GNT > ','INTEGER')
    self._pos = self._pos + 1
    return Token(TYPES.INTEGER, current_char)
  end

  if (current_char == '+') then
    print('GNT > ','PLUS')
    self._pos = self._pos + 1
    return Token(TYPES.PLUS, current_char)
  end

  self:error('getting next token: ' .. current_char)
end

function Interpreter:eat(token_type)
  -- compare the current token type with the passed token
  -- type and if they match then "eat" the current token
  -- and assign the next token to the self.current_token,
  -- otherwise raise an exception.
  if (self._current_token._type == token_type) then
    print('eating', self._current_token._value)
    self._current_token = self:get_next_token()
  else
    self:error('eating')
  end
end

function Interpreter:expr()
  -- expr -> INTEGER PLUS INTEGER
  -- set current token to the first token taken from the input
  self._current_token = self:get_next_token()

  -- we expect the current token to be a single-digit integer
  local left = self._current_token
  self:eat(TYPES.INTEGER)

  -- we expect the current token to be a '+' token
  local op = self._current_token
  self:eat(TYPES.PLUS)

  -- we expect the current token to be a single-digit integer
  local right = self._current_token
  self:eat(TYPES.INTEGER)
  -- after the above call the self.current_token is set to
  -- EOF token

  -- at this point INTEGER PLUS INTEGER sequence of tokens
  -- has been successfully found and the method can just
  -- return the result of adding two integers, thus
  -- effectively interpreting client input
  local result = left._value + right._value
  return result
end


---- MAIN
local input = io.read()
local interpreter = Interpreter(input)
local result = interpreter:expr()
print(input, '=', result)
