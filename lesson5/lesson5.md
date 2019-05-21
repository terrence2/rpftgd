---
theme: "white"
transition: "slide"
highlightTheme: "darkula"
---

## Ruby Performance
### from the ground down

Part 5: Where does the time go?

---

Procore has 150 web servers

16 threads per server

---

How much CPU is each box using?

---

Less than 50%

---

Let's try to understand why

---

# Where does the time go?
## Doing Nothing

---

Because we are waiting for something

---

Network, I/O, or Memory

---

## Memory

---

Cold lookups take 100's to 1000's CPU cycles to return

---

CPUs have 3 distinct caches (and lots of hidden ones)

---

x86_64

---

Registers: 1 cycle; ~8 user visible; 32-64 internal

---

L1: <10 cycles; a few KiB

---

L2: 10-20 cycles; a few dozen KiB

---

L3: 20-100 cycles; a few MiB

---

If you can avoid one cold memory lookup by doing 500 instructions of work, do so.

---

Pointer chasing is catastrophically slow on "modern" (last 20 years) of processors.

---

Espectially if it's random.

---

Or too large to fit in caches

---

What is pointer chasing?

---

Function calls

Random Array Accesses

Linked Lists

Binary Trees

Graphs

---

But aren't all VM's inherently a graph of objects linked by pointers?

---

https://benchmarksgame-team.pages.debian.net/benchmarksgame/which-programs-are-fast.html

---

## Network

---

A 4Ghz processor can run 4B+ operations in a second.

---

A 500us request represents ~2 million potential operations

---

Avoid communication.

---

Distributed systems design

...is it's own class

---

Mostly about how to avoid communication or minimize it if required.

---

## I/O

---

Postgres, mostly

---

Order of 0.5ms - 10ms per query, generally

---

2M - 40M instructions in that window

---

99.9% of what you need to know to make *Procore* go fast

---

Also it's own class

---

# Where did all the time go?
## Interpreter Overheads

---

### The loop

---

How many jumps are there here?
```
loop {
  case instr {
    ...
    when:
      break;
    ...
  }
}
```

---

1) case -> when (fully random)
2) break -> loop end (predictable but lots)
3) loop end -> loop start (predictable)

---

Threaded Interpretter Loops

---

Peek at the next instruction and break directly to it.

---

Avoids jump #3, but makes #2 unpredictable.

---

Generally worth 5-10% speedup on old processors.

---

Modern processors are tightly tuned for interpreter loops.

---

Can still be useful on low-power processors [citation needed]

---

## Interpreter Overheads

### Type Dispatch

---

`foo + bar`

---

Polymorphic dispatch

---

2 + 2

vs

"hello" + "world"

vs

Math.PI + Math.PI

---

All from the same call site: op_add

---

When running "normal" code, the processor can (usually) predict the target with high accuracy

---

e.g. The type of a specific virtual call is likely to be fairly stable.

---

With a VM all plus operators (generally) go through the same path.

---

# Where did all the time go?
## Memory Management Overheads

---

Quick review:

`a + b / 2`

---

Expands to:
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

5 instructions moving stuff around in memory

2 instructions doing the actual "work"

---

More allocations than you might think.

---

bytecode; blocks; lambdas; stack frames; upvars;
ropes; object slots; symbol registry; caches; ...

---

C uses manually `malloc` / `free`

---

How do we know when to free things?

---

Stop everything and look every now and then.

---

How do we know when it's a good time to stop everything?

---

Heuristics :shrug:

---

Main algorithm: Mark and Sweep

---

1) Walk over everything stored in the stack, marking anything we can see.

---

2) Walk directly through the Heap, collecting anything not marked

---

Remember how pointer walking is slow?

---

Let's do it to the *entire* heap every time we run out of memory!

---

## Where did all the time go?

Summary So Far:
* Doing Nothing
* Interpreter Overheads
* Memory Management

---

Can we do better?

---

### Doing Nothing

Not really, although it informs any algorithm we devise to improve the others

---

### Memory Management

There's an entire sub-field of Computer Science

---

I'm going to summarize it quickly, then give some take-aways

---

1) What if we try not doing it all at once?

---

We get incremental GC

---

Problem what if something that is markable but hasn't been marked gets copied behind something that has been marked?

---

Solution: Just don't collect anything that gets touched while you are looking.

---

More overhead; Lower throughput

...but better Latency

---

2) What if we *don't* visit the full heap every time

---

Generational Collection

---

Common program property: most objects are temporary

(High infant mortality)

---

Need to track all references from the "Tenured" generation into the "Nursery"

---

Store Buffer

---

Okay, we need to keep something alive, now what.

---

Move it to Tenured heap and update *all* references to that object

---

Any failures are very likely exploitable

---

Much more runtime overhead

still pays for itself in reduced GC overheads

---

3) We've got lots of CPUs now, what if we mark the bit we're not using while we compute elsewhere?

---

We get Concurrent Collection

---

Turns out it doesn't really work great.

---

We compete for precious memory bandwidth *and* clobber the caches with useless data.

---

Only pays for itself if you have a big enough heap, lots of cores, and great heuristics about your usage.

---

4) We can move things in memory now; what if we fill in the gaps the freed things leave while collecting.

---

We get compacting collection.

---

Saves memory and makes OOM conditions less drastic.

---

Very difficult to make effective

---

Naive algorithms randomize the order of allocated objects, which tends to make linear accesses random.

---

Better to compact full pages at once, but that's more expensive.

---

Need to spread out compaction over many GC's.

---

5) What about &lt; list of fancy collectors here /&gt;?

---

It is *very* hard to beat Generational + Incremental with intermittent Compacting and occasional Concurrent.

---

e.g. people have been trying since the early 80's and have not managed to yet

---

The cost of tracking more information does not pay for itself except in very niche cases

---

Java tried to move to G1 and had to move back

---

V8 released a multi-generational scheme and eventually removed it

---

SpiderMonkey investigated multi-generational because of the one in V8

We could not find a performance benefit across multiple benchmarks and real-world loads

---

Summary:

GC's are incredibly slow.

Driven entirely by heuristics.

Some workloads will cause catastrophic memory or cpu usage

---

Take away:

Don't use a GC unless you have to.

---

## Interpreter Overheads

---

Translate high level code to low level code

---

But how and why?

---

CPU's execute at billions of instructions a second.

---

"Only" hundreds of millions of lines in a modern OS.

---

A few GiB of code at most.

---

We should be done in a couple of seconds, tops!

---

Whoops, forgot about loops!

---

If it takes more than a few ms to execute, there is a loop somewhere.

---

Upshot:

We can ignore everything that's not a loop.

---

But not all loops are long and we should ignore those too.

---

If compilation takes X ms, but the results run Y times faster, how long does the loop need to run in order to pay for compilation?

---

We don't know X or Y going in => more heuristics

---

Translating high level to low level code

---

Both are Turing complete, so it should be easy, right?

---

What does a high level language have that we can't do (easily) on a CPU?

---

Basically anything.

---

Stacks

Objects

Methods

Polymorphic Dispatch

---

Need to expose the internals of our VM primitives at a byte level

---

Craft assembly routines to work on them

---

Thread that together by walking over the bytecode

---

Can usually get 90% of the performance by handling 10% of the opcodes

---

Maybe less true in Ruby because of the prevalence of method_missing and such?

---

If the algorithm is just inherently slow there's not much translating it will do.

---

But what do we compile and when?

---

The obvious (and subtly wrong) approach:

Tracing JIT

---

Record all loop and branch heads and the types present there

If we see one repeat more than N times, compile everything in the last iteration

---

Compiles exactly what we used, so what's wrong?

---

Programmers use lots of if's

---

Need one path for each collection of choices

---

Code is bulky

---

End up stiching similar traces together to save space

---

Turns out programmers already group related actions!

---

We just re-discovered functions... very slowly.

---

Faster to just compile the whole method with the loop in it and inline aggressively

---

Method JITs

---

Track loop heads and every type that has been seen in each instruction

---

Compile it all in one go

---

Significantly less likely to need to re-enter the compiler

---

What if the types change after we compile!

---

Guards!

---

On method entry, call returns, etc.

---

Throw away the compilation result.

Wait for the heuristics to re-trigger.

---

Works... pretty great actually

---

100x+ faster

Easily pays for itself for any one instance.

---

Works out to much less than 100x, but plenty to be worth it.

---

What's missing?

---

As we start compiling sooner, we increase the likelyhood of types changing.

---

On short loops (just over the heuristic), we would have been good with less optimization.

---

On long loops, we would have been better served spending the time to micro-optimize.

---

The "Baseline" compiler

---

Just a pile of Polymorphic Inline Caches, defaulting to a generic C opcode body.

---

Any miss inserts the missing type into the cache.

---

We know it's a loop because we chose to compile it.

When we get back it will use the faster "inline cache"

---

Two birds with one stone.

---

If we cross the second threshold to invoke the Method Compiler, we can read out the caches to discover what types have been seen.

---

Still jumps back to the baseline compiler for things we haven't seen yet.

---

If we cross a third threshold to invoke the top-tier compiler, we should have a *really* good idea of what types and paths are used and can generate *extremely* fast code with that data.

---

Summary:

4-tier compilation model

Compiling removes the interpreter loop

PICs address typed dispatch efficiently

---

Takeaways:

Write monomorphic code to be JIT friendly

---

Summing Up

---

Ruby is super slow

---

And we don't really have any tools to work around that

---

But it mostly doesn't matter anyway for our purposes

