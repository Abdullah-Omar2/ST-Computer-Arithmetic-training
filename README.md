# ST-Computer-Arithmetic-training

This repository contains tasks I have worked on during my training in computer arithmetic.
It includes implementations of advanced adders and multipliers, which are fundamental components
in high-performance digital circuits.
These implementations focus on optimizing speed, area, and power consumption for efficient arithmetic operations.

![Certificate](Certificate.jpg)

## Table of Contents

1. [Adders](#Adders)
2. [Multipliers](#Multipliers)
3. [Floating Point Arithmetic](#Floating-Point-Arithmetic)

## Adders

1. **Carry Lookahead Adder**

The Carry Lookahead Adder is an optimized addition circuit that reduces propagation delay
by precomputing carry signals. Instead of waiting for carries to propagate sequentially,
it uses generate (G) and propagate (P) signals to determine carry values in parallel,
significantly improving speed compared to a ripple-carry adder.

2. **Ling Adder**

The Ling Adder is a modification of the Carry Lookahead Adder that further reduces logic complexity
by redefining carry signals. It enhances performance by minimizing the number of logic levels
required for carry computation, making it a preferred choice in high-speed arithmetic units.

3. **Ladner-Fischer Adder**

The Ladner-Fischer Adder is a parallel prefix adder that efficiently computes carries in
a logarithmic number of stages. It balances performance and hardware cost by organizing
the computation into prefix trees, making it suitable for applications requiring high-speed addition.

## Multipliers

1. **Right Shift Multiplier**

The Right Shift Multiplier is a sequential multiplication algorithm that shifts and adds
partial products iteratively. It is commonly used in hardware implementations where area
efficiency is a priority, as it reduces hardware complexity at the cost of increased latency.

2. **Carry-Save Array (CSA) Radix-8 Multiplier**

The CSA Radix-8 Multiplier improves multiplication speed by processing three bits per cycle,
reducing the number of required partial products. It utilizes a carry-save adder (CSA) structure
to efficiently manage intermediate carry values, making it well-suited for high-performance
computing applications.

## Floating Point Arithmetic

1. **Floating Point Division**

The Floating Point Division module performs single-precision division based on the IEEE-754 standard.
It handles key steps such as exponent bias subtraction, mantissa normalization, and restoring division.
This task enhances understanding of floating-point number representation and the hardware-level operations
that enable precise real-number computations in digital systems.

