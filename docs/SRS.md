# Software Requirements Specification: Mini OS Simulator

Version 0.1 (baseline) | October 27, 2026 Author: Pranjal Yadav | Operating Systems Lab, ZHCET, AMU

## 1. Introduction

### 1.1 Purpose

This document defines the baseline requirements for the Mini OS Simulator, an Operating Systems lab mini project. It is the reference for design, implementation and testing, and is revised as the open issues in Section 8 are settled.

### 1.2 Scope

The Mini OS Simulator is a C++17 console program that simulates processes competing for one CPU, a fixed pool of memory frames and one disk. It combines the topics covered in the lab:

- CPU scheduling: FCFS, SJF, Round Robin, Priority
- Paging: FIFO, LRU, Optimal page replacement
- Disk scheduling: FCFS, SSTF, SCAN, C-SCAN, LOOK
- Synchronization: mutexes, condition variables, shared queues

Out of scope: interaction with real hardware or device drivers, a graphical interface, multi-core simulation, and a file system.

### 1.3 Definitions

| Term | Meaning |
| --- | --- |
| Tick | One unit of simulated time. The simulator clock advances by one tick per step |
| PCB | Process Control Block: the record holding a process's state and bookkeeping |
| Burst | Number of CPU ticks a process needs |
| Frame | One slot of simulated physical memory that holds one page |
| Page fault | A memory reference to a page that is not in any frame |
| Cylinder | A track position on the simulated disk, numbered from 0 |
| Seek distance | Number of cylinders the disk head moves |
| Waiting time | Time a process spends in the READY queue |
| Turnaround time | Completion time minus arrival time |
| Response time | Time from arrival to first dispatch |

### 1.4 References

- Operating Systems lab syllabus, ZHCET, AMU
- ISO/IEC/IEEE 29148:2018, requirements engineering (structure guideline for this document)
- Silberschatz, Galvin, Gagne: Operating System Concepts (source of the standard worked examples used in Section 6)

## 2. Overall Description

### 2.1 Product Perspective

The simulator is a standalone program. Its modules connect as follows: a process arrives and enters the ready queue, the CPU scheduler dispatches it, and each running tick makes one page reference. A hit continues execution. A miss is a page fault: the process blocks, a disk request is created, the disk scheduler orders pending requests, and when the I/O completes the process returns to the ready queue while the CPU runs another process.

Each module can also run standalone (scheduler only, paging only, disk only) so it can be tested in isolation.

### 2.2 Product Functions

- Load a workload and configuration from text files
- Simulate CPU scheduling with a Gantt chart
- Simulate paging with page replacement and fault counting
- Simulate disk scheduling with head movement tracing
- Run all three together in one time-stepped simulation
- Use threads and synchronization primitives for shared queues
- Report performance metrics for each run

### 2.3 User Classes

- Student or developer: runs simulations and compares algorithms
- Evaluator or instructor: reads the output to verify correct behaviour

### 2.4 Operating Environment

- Language standard: C++17, standard library only (no third-party libraries)
- Compiler: g++ on Windows with MSYS2/MinGW-w64 (posix thread model) or on Linux/WSL2
- Build: Makefile
- Interface: command line, text output

### 2.5 Constraints

- Time-stepped simulation (fixed one-tick loop), not event-driven
- Every algorithm sits behind a common interface for its category
- Output must be deterministic (see NFR-2)

### 2.6 Modelling Assumptions

- One CPU, one disk with one head, one disk request serviced at a time
- One page reference consumes one CPU tick
- Page size equals frame size; one page fits in one frame
- Lower priority number means higher priority
- Ties in any scheduler are broken by arrival time, then by process id

## 3. Functional Requirements

Priority: M = must, S = should, C = could.

### 3.1 Workload Input (FR-WL)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-WL-1 | The system shall read a workload from a text file given on the command line | M |
| FR-WL-2 | Each process record shall hold a process id, arrival tick, priority and either a CPU burst or a page reference list | M |
| FR-WL-3 | The system shall accept configuration for time quantum, frame count, replacement policy, cylinder count, initial head position and initial head direction | M |
| FR-WL-4 | The system shall reject invalid input (negative values, duplicate ids, missing fields, cylinder out of range) with a message naming the line, and exit with a non-zero code | M |

### 3.2 CPU Scheduling (FR-CPU)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-CPU-1 | The system shall implement FCFS, non-preemptive SJF, Round Robin and non-preemptive Priority scheduling | M |
| FR-CPU-2 | Round Robin shall use a configurable quantum of at least 1 tick | M |
| FR-CPU-3 | The system shall print a text Gantt chart that shows idle periods | M |
| FR-CPU-4 | The system shall compute waiting, turnaround and response time per process, and their averages | M |
| FR-CPU-5 | The system should support SRTF and preemptive Priority | C |

### 3.3 Memory Management and Paging (FR-MEM)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-MEM-1 | The system shall simulate a configurable number of frames (at least 1) | M |
| FR-MEM-2 | The system shall implement FIFO, LRU and Optimal page replacement | M |
| FR-MEM-3 | On each reference the system shall record a hit or a fault; on a fault with no free frame it shall ask the selected policy for a victim | M |
| FR-MEM-4 | The system shall report page faults per process, in total, and the fault rate (faults divided by references) | M |
| FR-MEM-5 | In standalone paging mode the system shall print each reference with hit or fault, the victim page and the frame contents | M |
| FR-MEM-6 | Optimal replacement shall be available in standalone mode, where the whole reference string is known. Integrated-mode support is open (OI-1) | M |
| FR-MEM-7 | The system should support Second-Chance (Clock) replacement | C |

### 3.4 Disk Scheduling (FR-DSK)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-DSK-1 | The system shall implement FCFS, SSTF, SCAN, C-SCAN and LOOK | M |
| FR-DSK-2 | The system shall take cylinder count, initial head position and initial direction as configuration | M |
| FR-DSK-3 | The system shall print the service order, each head movement (from, to, distance) and the total seek distance | M |
| FR-DSK-4 | SCAN and C-SCAN shall travel to the physical end of the disk; LOOK shall reverse at the last pending request | M |
| FR-DSK-5 | The C-SCAN return jump shall be included in the total seek distance and also reported separately | M |
| FR-DSK-6 | In standalone mode the system shall read a static request list; in integrated mode requests arrive over time | M |
| FR-DSK-7 | The system should support C-LOOK | S |

### 3.5 Integrated Simulation (FR-INT)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-INT-1 | The simulator shall keep one global tick clock that advances by 1 per step | M |
| FR-INT-2 | Each process shall be in exactly one state: NEW, READY, RUNNING, BLOCKED or TERMINATED | M |
| FR-INT-3 | Allowed transitions: NEW to READY (arrival), READY to RUNNING (dispatch), RUNNING to READY (quantum expiry), RUNNING to BLOCKED (page fault), BLOCKED to READY (I/O complete), RUNNING to TERMINATED (all references done) | M |
| FR-INT-4 | A process shall never be in more than one queue at the same tick | M |
| FR-INT-5 | On a page fault the simulator shall create a disk request for the faulting page, block the process, and dispatch another READY process or idle | M |
| FR-INT-6 | The disk shall service one request at a time, chosen by the selected disk scheduler; service time is the seek ticks plus a configurable transfer time | M |
| FR-INT-7 | A frame reserved for an in-flight page load shall not be chosen as a victim until that I/O completes | M |
| FR-INT-8 | When a blocked process resumes, the reference that faulted shall hit and shall not be counted as a second fault | M |
| FR-INT-9 | The simulation shall end when all processes are TERMINATED | M |
| FR-INT-10 | A --trace option shall print a tick-by-tick event log | S |

### 3.6 Synchronization (FR-SYN)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-SYN-1 | In threaded mode, the ready queue and disk request queue shall be protected by a mutex and condition variable | M |
| FR-SYN-2 | Threaded mode shall produce output identical to single-threaded mode for the same input | M |
| FR-SYN-3 | Threads shall advance in lock-step per tick using a barrier built from a mutex and condition variable (C++17 has no std::barrier) | M |
| FR-SYN-4 | The program shall be free of data races and deadlock, checked with ThreadSanitizer where available | S |
| FR-SYN-5 | The system should include a standalone producer-consumer demo that uses the same primitives | C |

### 3.7 Metrics and Reporting (FR-MET)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-MET-1 | The final report shall include per-process and average waiting, turnaround and response time | M |
| FR-MET-2 | The final report shall include CPU utilization (busy ticks divided by total ticks) and throughput (processes completed per tick) | M |
| FR-MET-3 | The final report shall include total page faults, fault rate, number of disk requests and total seek distance | M |
| FR-MET-4 | The system should offer an option to write the report to a file | S |

### 3.8 Extended Features (FR-EXT)

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-EXT-1 | Banker's algorithm safety check (standalone, matrices from a file) | C |
| FR-EXT-2 | Thrashing demonstration: fault rate table for varying frame counts and process counts | C |
| FR-EXT-3 | Compare mode: run one workload under every algorithm of a category and print a side-by-side table | C |
| FR-EXT-4 | A simple TLB model with hit ratio reporting | C |

## 4. External Interfaces

The command syntax and file formats below are the proposed baseline and may change during design.

### 4.1 Command Line

```
mini_os_simulator <mode> [options]

modes: scheduler | paging | disk | full

Example:
mini_os_simulator full --workload tests/sample_workload.txt --cpu rr --quantum 4 --frames 3 --replace lru --disk scan --cylinders 200 --head 53
```

### 4.2 Workload File Format

Lines starting with # are comments.

```
# scheduler mode
process 1 arrival=0 priority=2 burst=24
process 2 arrival=0 priority=1 burst=3

# full mode (burst = number of pages)
process 1 arrival=0 priority=2 pages=7,0,1,2,0,3
```

### 4.3 Paging and Disk Input

```
# paging mode
frames 3
references 7 0 1 2 0 3 0 4 2 3 0 3 2 1 2 0 1 7 0 1

# disk mode
cylinders 200
head 53
direction down
requests 98 183 37 122 14 124 65 67
```

### 4.4 Output

All output goes to standard output as plain text: Gantt chart, reference trace, head movement trace and final report. Errors go to standard error.

## 5. Non-Functional Requirements

| ID | Requirement |
| --- | --- |
| NFR-1 Correctness | Results shall match the reference values in Section 6 |
| NFR-2 Determinism | The same input and configuration shall give byte-identical output. Any random workload generation shall use a user-supplied seed |
| NFR-3 Portability | The code shall build with g++ using -std=c++17 on MSYS2/MinGW-w64 and on Linux/WSL2 without source changes |
| NFR-4 Extensibility | Adding an algorithm shall require one new source file and one registration line, without editing other algorithms |
| NFR-5 Performance | Target: a workload of 1,000 processes and 100,000 total page references completes within 10 seconds on a typical laptop. To be confirmed by measurement |
| NFR-6 Readability | Descriptive names, one header and source pair per module, no global mutable state outside the simulator object |
| NFR-7 Testability | Each module shall have assert-based tests under tests/, all runnable with one make test command |
| NFR-8 Robustness | Invalid input shall produce a clear error message, never a crash |

## 6. Verification and Acceptance

Cylinder range is 0 to 199 for all disk cases. Head starts at 53 with requests 98, 183, 37, 122, 14, 124, 65, 67.

| ID | Case | Expected |
| --- | --- | --- |
| AT-01 | FCFS, bursts 24, 3, 3, all arrive at tick 0 | Average wait 17 |
| AT-02 | SJF, same workload | Average wait 3 |
| AT-03 | Round Robin, quantum 4, same workload | Average wait about 5.67 |
| AT-04 | FIFO, reference string 7 0 1 2 0 3 0 4 2 3 0 3 2 1 2 0 1 7 0 1, 3 frames | 15 faults |
| AT-05 | LRU, same string and frames | 12 faults |
| AT-06 | Optimal, same string and frames | 9 faults |
| AT-07 | FIFO, string 1 2 3 4 1 2 5 1 2 3 4 5 | 9 faults with 3 frames, 10 with 4 frames (Belady's anomaly) |
| AT-08 | Disk FCFS | Total seek distance 640 |
| AT-09 | Disk SSTF | Total seek distance 236 |
| AT-10 | Disk SCAN, direction toward cylinder 0 first | Total seek distance 236 |
| AT-11 | Disk LOOK, direction toward cylinder 0 first | Total seek distance 208 |
| AT-12 | Disk C-SCAN, direction toward higher cylinders, return jump counted | Total seek distance 382 |
| AT-13 | Invariants on any workload: Optimal faults never exceed FIFO or LRU faults; faults never exceed references; every process terminates; no process in two queues | All hold |
| AT-14 | Run the same workload 100 times in threaded mode | Output identical every run and identical to single-threaded |
| AT-15 | Feed invalid input (duplicate id, negative burst, cylinder 250) | Error naming the line, non-zero exit |

## 7. Milestones

| Milestone | Deliverable | Requirements | Acceptance |
| --- | --- | --- | --- |
| M1 | Process struct and workload loader | FR-WL | AT-15 |
| M2 | CPU schedulers and Gantt chart | FR-CPU | AT-01 to AT-03 |
| M3 | Memory manager and page replacement | FR-MEM | AT-04 to AT-07 |
| M4 | Disk schedulers | FR-DSK | AT-08 to AT-12 |
| M5 | Integrated clock loop | FR-INT | AT-13 |
| M6 | Threads and synchronization | FR-SYN | AT-14 |
| M7 | Metrics report and extended features | FR-MET, FR-EXT | Review against Section 3 |

## 8. Open Issues

| ID | Issue | Baseline position |
| --- | --- | --- |
| OI-1 | Optimal replacement has no defined future when processes interleave in integrated mode | Standalone mode only; integrated mode supports FIFO and LRU |
| OI-2 | How a page maps to a disk cylinder | Page number modulo cylinder count |
| OI-3 | Global frame pool versus per-process frame allocation | Global pool |
| OI-4 | Disk service time model | Seek ticks plus a fixed transfer time |
| OI-5 | Preemptive algorithms (SRTF, preemptive Priority) | Not required |
| OI-6 | Interface type | Console only |
| OI-7 | Lab submission requirements (report format, viva or demo, required algorithm list) | Unconfirmed with the instructor |
