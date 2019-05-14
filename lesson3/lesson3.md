---
theme: "white"
transition: "slide"
highlightTheme: "darkula"
---

## Ruby Performance
### from the ground down

Part 3: Ruby Bytecode & Parsing

---

## What is bytecode?

---

A stream of bytes that encode instructions for a machine.

---

There is no one standardized "bytecode" format.

(Yes, wordcode is a thing too)

---

There are many different bytecode formats targetting specific machines.

---

It is more common to have a well-documented bytecode format in hardware projects.

e.g. x86_64, amd64, mips

---

*Virtual* Machines have bytecode too, but it's less frequently documented.

Standouts: LLVM

---

Ruby, Python, Javascript, Java, Erlang, Elixir (to name a few) use bytecode internally.

---

But even within a language, it is different in each implementation.

MRI vs JRuby, SpiderMonkey vs V8, PyPy vs CPython, etc.

---

How is this different from what we built for Befunge?

---

Bytecode is typically *not* the same as the source text.

---

Ruby Example:
```
code = "(x + y) / 2"
iseq = RubyVM::InstructionSequence.compile(code)
```

---

```
irb(main):006:0> RubyVM::InstructionSequence.compile(code).disassemble.lines.map { |l| puts l }
== disasm: #<ISeq:<compiled>@<compiled>:1 (1,0)-(1,11)>=================
0000 putself                                                          (   1)[Li]
0001 opt_send_without_block <callinfo!mid:x, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0004 putself
0005 opt_send_without_block <callinfo!mid:y, argc:0, FCALL|VCALL|ARGS_SIMPLE>, <callcache>
0008 opt_plus         <callinfo!mid:+, argc:1, ARGS_SIMPLE>, <callcache>
0011 putobject        2
0013 opt_div          <callinfo!mid:/, argc:1, ARGS_SIMPLE>, <callcache>
0016 leave
```

---

Wait, Ruby has a compiler?

---

Yerp

---

It compiles from Ruby code to RubyVM instructions; *not* to x86/x64/arm.

e.g. not to a "real" machine, to a Virtual Machine custom to MRI.

---

How do we get from code to bytecode?

---

## Parsing

---

Code is simultaneously very high level and very low level.

---

```
code = "(a + b) / 2"
```

In memory this is:

```
00000000  28 61 20 2b 20 62 29 20  2f 20 32 0a              |(a + b) / 2.|
0000000c
```

---

Our goal is to take "61 2b 62" and turn it into the concept of "a" "plus" "b"

---

## Tokenization

---

Not magic, just an optimization

---

Allows us to deal with concepts instead of raw strings

---

e.g. turn "a+b" into:

 `[Symbol(:a), Plus, Symbol(:b)]`

---

A bit easier to work with at the language level

---

Allows you to use the CPU's integer comparitor instead of doing a full string comparison when parsing

---

### Tokenizing

---

Need a table of "matchers" that can pull one "symbol" off the front of a string

---

Can be regexes or just some code

---

Tricky because of prefixes:

\+ vs ++ vs +=

= vs == vs ===

/ vs //

e1 vs 0e1

---

Process:
Remove the *best* matching symbol from the front of the string. Repeat until empty.

---

"Best" is generally achieved by trying longer matches first. e.g. having === in the table before ==, before =.

---

Can be done eagerly or as a co-routine with parsing. Not always clear where the line is.

---

Trivial to implement

---

Except in C

---

Tools to "help out" in C: Lex and Flex

---

## Parsing

---

Turn a list of symbols into computation

---

Syntax: the arragement of symbols to create a well formed program in a language

---

A language defines what syntax is "valid" vs "invalid"

---

e.g.: a / " + b*#^

All valid symbols.

**NOT** a valid program.

---

Syntax defines the order in which symbols can occur in a valid program

---

That sounds like a Regex?

---

It is!

---

But we want to know more than if the program has valid syntax.

---

Semantics: the meaning of a string of symbols

---

The map from "+" to `opt_add`

---

Too fuzzy to work with directly

---

Grammar: syntax + semantics

The glue that makes this all workable

---

EBNF: Extended Backus-Naur Form

A grammar for representing grammars

---

Easier to explain with an example:

https://github.com/antlr/grammars-v4

---

Process: match a syntax rule to the start of the token list, repeat until empty.

---

Trivial to implement

---

Even in C

---

But somewhat repetitive and error prone.

---

So of course there are tools to "help": yacc and bison

---

`<Admiral Ackbar>It's a trap!</Admiral Ackbar>`

---

Always a complete and utter disaster.

---

Parsing Capabilities

LL(1), LALR, GLR, etc.

---

Nobody actually working on a language cares

---

Only a meaningful distinction if you've already bought into the idea of parsing frameworks

---

In practice, all professionally made languages use a "recursive descent" parser

e.g. Just write it. It's actually faster and cleaner.

---
