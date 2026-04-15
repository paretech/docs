# Designing State

I was recently developing an application to conduct a specific long-running hardware test. While things were working, it got to a point where there was a very definite "smell". Changes were introducing bugs and there was too much surface area.

Here are some loose thoughts for approaching.

Try to divide the system into these four layers

1. Raw State (truths of the system)
   - is_display_on
   - is_faulted

2. Derived capabilities, conditions, GUI selectors, Clock/Task Guards (not stored)
   - can_start
   - can_stop
   - can_poll_meter
3. Actions/Tasks (requires...)
4. UI Actions (GUI selectors)
   - start button enabled (can_start)
   - stop button enabled (can_stop)

## Other Ideas

- Consider adding "guard" callable to task execution condition. Guard would prevent task from entering is_due if guard is false.
- Try to break down the system into a "store" or single state object
- Limit state changes through named events
- Selectors, pure functions that that derive condition from state (literally the state object)
- Effects as code that talks to hardware, thread, files, etc...
- Views as GUI elements triggered by or reflects selectors and dispatches events
- use "transition states" if operations are not instantaneous (starting, stopping, initializing...)
- It should be impossible to represent an invalid state
- handlers should have minimal defensive checks
- separate phase, cause, capabilities,
- Supervisors, controllers are good things. Make sure you have one!
- Don't create more runtime phases/states to represent why stopped/faulted. Instead change phase/state and provide structured reason.

## Define Lifecycle

1. Session Life Cycle (persistence and restoring state)
2. Runtime life cycle (idle, initializing, running, stopping, paused)
3. infrastructure/device life cycle (connecting, connected, initializing, initialized, operational, shutting down, closed)
4. Execution life cycle (clock advancement, advancing, halted)
5. Fault interruption (operator, device, task, unrecoverable/recoverable)

## Refactor Guide

1. inventory conditions of system
   - concern (thing being controlled), rule, rule location, future rule location, raw state or derived state
2. Reduce mode count, maybe split into axes
3. centralize guards/selectors/conditions
   - centralize first before rewriting anything else
4. Make tasks declare conditions (e.g., name, interval, guard, handler, other)
5. make GUI bind to selectors
6. Define transition events

For each thing, identify if it is a fact, a command, a capability or a policy

## Mental Models

- Operator Model
  - Can start/resume when stopped
  - Can stop while starting/running
  - Sees a clear reason if stopped due to fault
- Internal Model
  - Idle
  - Starting
  - Running
  - Stopping
  - Paused
  - Faulted
  - Completed/Aborted

## Project Structure

- model.py
  - Enums and persistent dataclasses.
- selectors.py contains Pure functions:
  - can_start
  - can_stop
  - show_fault_banner
  - execution_enabled
  - should_advance_clock
  - should_checkpoint_periodically
- controller.py Owns state and handles events:
  - create session
  - resume session
  - start requested
  - stop requested
  - device fault
  - task abort
  - startup complete
  - shutdown complete
- scheduler.py Generic task engine.
  - task specs
  - clock advancement
  - retry/abort/defer behavior
  - emits events upward
- persistence.py Save/load JSON snapshots and dataclass restore.
- gui_adapter.py Maps selectors to widgets and routes user actions to supervisor events.

## Examples

```python
def can_poll_meter(s: AppState) -> bool:
    return (
        s.meter_connected
        and not s.estop
        and (
            s.run_phase is RunPhase.RUNNING
            or s.calibration_active
        )
    )


from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional

class Event(Enum):
    CREATE_NEW_SESSION = auto()
    LOAD_EXISTING_SESSION = auto()
    START_REQUESTED = auto()
    STARTUP_SUCCEEDED = auto()
    STARTUP_FAILED = auto()
    STOP_REQUESTED = auto()
    DEVICE_FAULTED = auto()
    TASK_ABORTED = auto()
    SHUTDOWN_COMPLETE = auto()
    TEST_COMPLETED = auto()

class SessionOrigin(Enum):
    NEW = auto()
    RESUMED = auto()


class RuntimePhase(Enum):
    IDLE = auto()          # GUI open, session prepared, waiting for start
    STARTING = auto()      # connecting/init/orchestration in progress
    RUNNING = auto()       # clocks advancing
    STOPPING = auto()      # orderly shutdown in progress
    PAUSED = auto()        # stopped but resumable
    FAULTED = auto()       # stopped due to fault; may or may not be resumable
    COMPLETED = auto()     # terminal successful end
    ABORTED = auto()       # terminal failed/unrecoverable end


class StopReason(Enum):
    NONE = auto()
    OPERATOR = auto()
    DEVICE_FAULT = auto()
    TASK_ABORT = auto()
    STARTUP_FAILURE = auto()
    COMPLETION = auto()
    INTERNAL_ERROR = auto()


class InfraPhase(Enum):
    DISCONNECTED = auto()
    CONNECTING = auto()
    CONNECTED = auto()
    INITIALIZING = auto()
    READY = auto()
    SHUTTING_DOWN = auto()
    CLOSED = auto()


@dataclass
class FaultInfo:
    code: str
    message: str
    resumable: bool = True
    source: Optional[str] = None


@dataclass
class AppState:
    session_origin: Optional[SessionOrigin] = None
    runtime_phase: RuntimePhase = RuntimePhase.IDLE
    infra_phase: InfraPhase = InfraPhase.DISCONNECTED
    stop_reason: StopReason = StopReason.NONE
    active_fault: Optional[FaultInfo] = None

    # persisted test state
    test_state: dict = field(default_factory=dict)
    config: dict = field(default_factory=dict)

    # bookkeeping
    checkpoint_dirty: bool = False
    shutdown_requested: bool = False
```
