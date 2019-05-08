---
theme: "white"
transition: "slide"
highlightTheme: "darkula"
---

## Ruby Performance
### from the ground down

Part 1: Context

---

How do we measure performance?
```
COUNT = 100000
start_time = Time.now
(1..COUNT).each { |_| short_operation() }
elapsed_time = Time.now - start_time
puts "short_operation() takes: #{elapsed_time / COUNT * 1000000} us per iteration"
```

---

## Exercise 1
### cost of a method call

note: make sure everyone can run Ruby code

---

Useful, but what does it mean?

---

Qustions we'd actually like to answer:
* *Why* did it take that long and not longer, or shorter?
* Is that a reasonable amount of time for $OP to take?
* Is there an equivalent $OP that takes less time?

---

## Exercise 2
### cost of a variable reference

---

The equivalent code not using methods is faster.

Abstractions in Ruby are not zero cost.

---

Why?

Where does the cost come from?

---

Unless we know *why* one is faster that the other, we can't reason about it.

---

note: goal time 15 minutes

note: If we want to understand why Ruby acts like it does, we have to go way back.

### A Brief History of Computation

---

Pop Quiz: Who invented computing?

---

It's a trick question.

---

Humans have been computing things for longer than we have a written history.

---

The First formally defined algorithm (that still exists from antiquity) is Hero's method for computing square roots.

---

Who formalized our existing understanding of computing?

---

A bunch of people. But mostly,

Turing and Church

Around 1935-1939

---

Before the 1950's, Computer was a job title. For Humans.

---

There was an open debate around whether a mere machine can do math at all.

---

Proof by counter-example: Turing Machine

---

The Turing Machine is a virtual machine.

It executes its instructions on top of the only computing strata available at the time: Computers.

---

What is the difference between a virtual machine and a "real" machine?

---

Some gears

---

It doesn't matter to the guest machine whether it is implemented by Physics or some other Machine.

---

Version 1 of anything is a bit rough.

---

Focused at a mathematics audience, not a computer science audience.

---

Doesn't emphasize quite the same concepts that later machines found to be the most useful.

---

Doesn't label concepts quite the same as later machines.

---

Let's look at something similar, but more modern, and programmer friendly instead.

---

Befunge '93

---

Also designed to settle a bet: is it possible to build a language that's impossible to compile.

---

Most Befunge '93 implementations can fit on a T-Shirt.

---

Ideal for studying VM's.

---

We will be using an online implementation at:

https://www.bedroomlan.org/tools/befunge-playground/#prog=hello,mode=edit

---

note: Goal Time: 45m

Let's Learn Befunge!

---

