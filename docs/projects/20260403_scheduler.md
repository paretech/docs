# Designing a "domain" Scheduler

- Provide more context between adaptive and fixed tick mechanisms so that I can understand the benefits and implementation complexity
- Does deadline scheduling use heap queue?
- Is it commons for schedulers to support more than one strategy concurrently?
- How to handle long-running tasks (e.g. tasks that take longer than a single tick)
- In going between description of task and scheduler I can see situations where the boundary between the two is less than clear, especially when comparing long running task strategies with schedulers. For example, in the "cooperative yielding" strategy for long running tasks it seems like the task would be wrapped in some periodic loop such that it can timeout or be interrupted. It almost seems like a scheduler that administers an individual task in addition to a mast scheduler that administers multiple tasks.
- What is difference between "circuit breaker pattern" and "backoff"?
- What parts of "task execution" are typically logged? Start, stop, and exception are top of mind.
- Latency is typically measured between two points, WRT observability metrics, what latency should be measured?
- How is scheduler lag measured?
- What is different between "dry-run" and "simulation" mode?
- instead of task state of "ready" is "pending" an acceptable and frequently used convention?
- Python is the likely system for implementing the scheduler, are there highly recommended off the shelf solutions (e.g. PIP installable) or is it common to implement scheduler from scratch as needed?

## Resources

- Several chats happened prior to 4/6/2026.
- There is a particularly productive [chat that started 4/6/2026](https://chatgpt.com/c/69d48749-aea8-83e8-a4aa-02caed623e2e)
  - Scheduler mechanics
  
## Scheduler Mechanics

"Ticks" can represent a fixed interval or, in more advanced cases, an adaptive interval.

Fixed interval ticks are easier to reason with, and in general, recommended for initial implementation. Fixed ticks can result in quantization issues but many problems are tolerant to this.

On the other hand, "adaptive tick" systems are an optimization that result in more complex scheduling logic at the benefit of efficient idel behavior and higher timing precision with less CPU overhead. Adaptive systems are a bit harder to reason about and debug.

As such, it is generally recommended to start scheduler implementation using a fixed interval mechanics and only expanding to more complex systems as needed.

## Task Types

- Periodic runs every N ticks, useful for polling sensors.
- One-shot runs once at a scheduled time.
- Conditional runs when a predicate (i.e. condition) true
- Dependent runs after another task completes

## Task Model

class

### Task States

- **READY** awaiting execution
- **RUNNING** execution in progress
- **WAITING** execution pending condition to be true
- **PAUSED** execution disabled
- **COMPLETED** execution finished
- **FAILED** execution failed with exception

## Scheduling Strategies

- **First come first serve (FCFS)** uses a simple queue
- **Priority** based uses a priority sorted heap queue
- **deadline scheduling** (TBR) good for time sensitive measurements
- **Rate monotonic scheduling (RMS)** gives higher priority to shorter interval tasks. Good for periodic sampling systems.
- **Earliest Deadline First (EDF)** assigns a dynamic priority based on deadline. Used when optimization needed over complexity.

## Time Sources

Time can be abstracted in a way that it becomes a controlled variable instead of an external dependency. This is a powerful concept.

In such abstractions, time can be paused and resumed such that it doesn't advance while the system is paused. This opens possibilities, like retaining (i.e. storing state) of scheduled offsets.

Such a strategy also allows time to be advanced manually during testing.

## Execution Model

- *Synchronous execution* is the simplist and runs tasks in the same thread as the scheduler. While this is the simplist model to implement it is risky since tasks can block the scheduling thread which is often undesirable.
- **Thread pool execution** offers parallelism WRT to scheduler and other tasks at the cost of needing to use thread safety (synchronization mechanisms or non-blocking strategies)
- Process Pool Execution is best for executing CPU heavy tasks like image processing
- Hybrid models afford a single-threaded scheduler and options for how to execute the scheduled task (e.g. thread pool).

## Data Flow

The system can be comprised of multiple queues. Try to think about "what is ready" to run versus "what should run".

- **Ready Queue** for tasks that are ready to execute
- **Delayed Queues** for tasks that are scheduled for future ticks
- **Event Queue** for tasks that are triggered by other events/tasks

## Handling "Long-Running" tasks

A task might be considered "long-running" if there is a strong probability that it takes longer than a single "tick". When this happens, there are few common strategies.

- **block** scheduler until task finishes
- **cooperative** by yielding control of task to scheduler periodically
- **external** by running tasks outside of scheduler (e.g., thread or process)

## Error Handling and Recovery

- Retry Policy
  - Immediate (abort, try again next tick)
  - Backoff (delay)
  - Max retry (N attempts)

## Logging

- Task execution (start, complete, error)

## Metrics and Debug

- task execution time
- latency
- queue depth
- Why didn't a task run (state instrospection)

## Determinism and Testing

- Dry run (as fast as possible?)
- Simulation mode (accelerated time?)
- Same inputs then expect same outputs

## Other Patterns to Research

- Event Loop
- Reactor
- Actor
- Producer-Consumer
- State Machine
- Strategy
- Command
- Work Queue/Pipeline

## Development Strategies

- Start simple
- Used fixed tick based clock instead of wall-clock
- use priority queue for task execution
- Single-threaded scheduler
- Thread pool executor for task execution.
- Custom clock abstraction (for control, flexibility, testing)
- Design fir pause/resume from day one
- Treat tasks as stateful objectsß
- avoid asyncio, unless IO Bound, and premature optimization. You will be impressed how far simple basics will take you.

## Objectives

- Use Python's internal `sched` module as an internal permeative to build out a fixed scheduler.

## State of the Art

There may not be a good existing off the shelf solution for scheduler for test applications. For specific hardware test applications, it is reportedly common to build custom schedulers to achieve what is needed. Recommendation is to build a small custom scheduler core and use standard Python primitives around it.

Try using

- `concurrent.futures` for worker threads/processes. It is pitched as a high-level interface for asynchronously executing callables via threads or processes
- `asyncio` for device interactions that are naturally asynce
- `heapq` for internal ready/due queues
- `sched` for interface inspiration, but not necessarily the module itself.

Think in layers

- **scheduler core** decides what is due, paused, and eligible for execution
- **executor** runs the work using thread/process works
- **clock** controls time
- **policy** handles prioritizing tasks, handling deadlines, retry/backoff logic, cancellation and fairness/contention.

Expect 200–600 lines of scheduler core, not a giant framework and not a pile of ad hoc timers.
