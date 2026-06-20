# Aether Core API Reference

## Overview
This document provides technical documentation for the core headers in the Aether microkernel. These headers define the fundamental building blocks of the Aether architecture.

## 1. Capability System (`capability.hpp`)

### Purpose
The Sigil Registry (Capability Store) safeguards the realms by managing access rights for spheres of execution. Capabilities are represented as Sigils that grant specific permissions to processes.

### Key Components

#### `enum class Sigil : uint32_t`
Represents fundamental rights granted to processes:
- `Read = 1 << 0` - Read access capability
- `Write = 1 << 1` - Write access capability
- `Execute = 1 << 2` - Execute access capability
- `Network = 1 << 3` - Network access capability
- `SysAdmin = 1 << 4` - System administration capability

#### `class SigilRegistry`
Manages capability grants for processes.

**Methods:**
- `void ordain(ProcessId pid, Sigil power) noexcept` - Grants a specific sigil power to a Process
- `bool isWorthy(ProcessId pid, Sigil power) const noexcept` - Checks if a Process is worthy of a specific sigil power
- `void revoke(ProcessId pid, Sigil power) noexcept` - Revokes a sigil power from a Process
- `void banish(ProcessId pid) noexcept` - Resets all sigils for a Process (strips it of power)

**Internal Structure:**
- `std::unordered_map<ProcessId, std::unordered_set<Sigil>> m_table` - Stores capabilities per process

**Usage Example:**
```cpp
Aether::SigilRegistry sigils;
sigils.ordain(process_id, Aether::Sigil::Read);
if (sigils.isWorthy(process_id, Aether::Sigil::Write)) {
    // Perform write operation
}
```

**Notes:**
- Capabilities are process-specific and revocable
- `banish()` removes all capabilities from a process
- The registry is thread-safe by design but external synchronization may be required in concurrent contexts

---

## 2. Aether Gateway/HAL (`gateway.hpp`)

### Purpose
The Aether Gateway (Linux Syscall Translator) translates host Linux system calls into internal Aether IPC messages. It serves as the primary interface between external requests and internal kernel services.

### Key Components

#### `class AetherGateway`
Handles syscall translation and routing.

**Constructor:**
```cpp
AetherGateway(SigilRegistry& sigils, IpcBroker& ipc, ArcaneMemoryPool& vmm, WeaverOfTime& scheduler)
```

**Dependencies:**
- `SigilRegistry` - For capability validation
- `IpcBroker` - For IPC communication
- `ArcaneMemoryPool` - For memory management
- `WeaverOfTime` - For task scheduling

**Methods:**
- `std::expected<uint64_t, ErrorCode> handleSyscall(ProcessId pid, uint64_t syscall_nr, uint64_t arg1) noexcept` - Intercepts a Linux syscall and translates/routes it

**Usage Example:**
```cpp
Aether::AetherGateway gateway(sigils, ipc, vmm, scheduler);
auto result = gateway.handleSyscall(pid, syscall_number, arg1);
if (result) {
    // Syscall handled successfully
} else {
    // Handle error
}
```

**Notes:**
- The Gateway validates capabilities before translating syscalls
- It acts as the primary security boundary for external requests
- All syscall translations are capability-checked

---

## 3. IPC Mechanism (`ipc.hpp`)

### Purpose
The Runic Nexus (Lock-Free IPC Broker) provides lock-free inter-process communication between processes in the Aether system.

### Key Components

#### `enum class MessageType : uint32_t`
- `Request` - IPC request message
- `Response` - IPC response message
- `Signal` - IPC signal message

#### `struct IPCMessage`
```cpp
struct IPCMessage {
    ProcessId sender;
    MessageType type;
    uint64_t payload;
};
```

#### `template<size_t Capacity> class LockFreeRingBuffer`
A lock-free ring buffer for IPC message passing.

**Methods:**
- `bool push(const IPCMessage& msg) noexcept` - Push a message to the buffer
- `std::optional<IPCMessage> pop() noexcept` - Pop a message from the buffer

**Internal Structure:**
- `std::array<IPCMessage, Capacity> m_buffer` - Fixed-size message buffer
- `std::atomic<size_t> m_head{0}` - Head pointer
- `std::atomic<size_t> m_tail{0}` - Tail pointer

#### `class IpcBroker`
Manages IPC message routing between processes.

**Methods:**
- `void sendMessage(ProcessId target, const IPCMessage& msg) noexcept` - Send a message to a target process
- `std::optional<IPCMessage> receiveMessage(ProcessId listener) noexcept` - Receive a message for a listener

**Internal Structure:**
- `LockFreeRingBuffer<1024> m_global_nexus` - Shared buffer for prototype; production would map per-process channels

**Usage Example:**
```cpp
Aether::IpcBroker broker;
Aether::IPCMessage msg;
msg.sender = current_pid;
msg.type = Aether::MessageType::Request;
msg.payload = some_value;

broker.sendMessage(target_pid, msg);
auto received = broker.receiveMessage(listener_pid);
```

**Notes:**
- The current implementation uses a shared buffer for prototype purposes
- Production implementations should use per-process channels
- The ring buffer is lock-free for performance

---

## 4. Scheduler Design (`scheduler.hpp`)

### Purpose
The Weaver of Time (Task Scheduler) manages task scheduling for spheres of execution.

### Key Components

#### `class WeaverOfTime`
Manages task scheduling and execution.

**Methods:**
- `void submitTask(ProcessId pid, std::function<void()> task) noexcept` - Adds a task to the ready queue
- `void tick() noexcept` - Executes the next task from the queue

**Internal Structure:**
- `struct Task` - Contains `ProcessId pid` and `std::function<void()> work`
- `std::queue<Task> m_ready_queue` - Ready task queue
- `std::mutex m_mutex` - Mutex for thread safety

**Usage Example:**
```cpp
Aether::WeaverOfTime scheduler;
scheduler.submitTask(process_id, []() {
    // Task implementation
});
// Call scheduler.tick() periodically to execute tasks
```

**Notes:**
- Tasks are queued and executed in FIFO order
- The scheduler uses a mutex for thread safety
- The `tick()` method executes one task per call

---

## 5. Memory Management (`vmm.hpp`)

### Purpose
The Arcane Memory Pool (Virtual Memory Manager) manages virtual memory allocations for processes within the realm.

### Key Components

#### `class ArcaneMemoryPool`
Manages virtual memory allocations for processes.

**Methods:**
- `[[nodiscard]] std::expected<Address, ErrorCode> allocatePage(ProcessId pid) noexcept` - Allocates a page of memory for a process
- `void freePage(ProcessId pid, Address addr) noexcept` - Frees a page of memory from a process

**Internal Structure:**
- `std::unordered_map<ProcessId, std::vector<Address>> m_allocations` - Maps PIDs to allocated addresses
- `Address m_next_free_addr = 0x10000000` - Base address for allocations

**Usage Example:**
```cpp
Aether::ArcaneMemoryPool vmm;
auto addr_result = vmm.allocatePage(process_id);
if (addr_result) {
    Address addr = *addr_result;
    // Use allocated memory
    vmm.freePage(process_id, addr);
} else {
    // Handle allocation failure
}
```

**Notes:**
- Memory allocations are process-specific
- The allocator uses a simple bump pointer starting at `0x10000000`
- The `[[nodiscard]]` attribute on `allocatePage` ensures allocation results are handled

---

## Error Codes

The following error codes are defined in `kernel.hpp`:

- `Success = 0` - Operation completed successfully
- `SigilDenied = 1` - Permission denied (no required sigil)
- `RealmNotFound = 2` - Process/Thread or target not found
- `NexusBlocked = 3` - IPC blocked or target not receptive
- `PoolExhausted = 4` - Out of memory / paging failure
- `LoomOverflow = 5` - Scheduler capacity exceeded
- `GatewayMalformed = 6` - Invalid Linux system call translation
- `InvalidSpell = 7` - General invalid argument or operation

## Integration Notes

These core components work together to provide:
1. **Capability-based security** through the SigilRegistry
2. **Hardware abstraction** through the Gateway
3. **Inter-process communication** through the IPC broker
4. **Task scheduling** through the Weaver of Time
5. **Memory management** through the Arcane Memory Pool

The system is designed for high performance with lock-free IPC, minimal trusted computing base, and hardware-enforced isolation through IOMMU domains.
