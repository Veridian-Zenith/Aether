# Aether Architecture Blueprint: The Path to Production

## 1. Vision
Aether is an advanced, production-grade microkernel designed to replace Linux without preserving Linux's driver ABI or compatibility layer. The current architecture follows an Uncompromising model: devices are isolated with hardware-enforced IOMMU boundaries, the trusted codebase is kept minimal, and drivers are written against Aether-native interfaces only.

## 2. Design Principles
- **Hardware-first isolation**: Device DMA, MMIO, and interrupts are isolated by the IOMMU and capability-checked HAL. The IOMMU is the primary enforcement boundary for device access.
- **Minimal Trusted Computing Base (TCB)**: The kernel, HAL, and driver runtime are implemented in a small auditable C++26 codebase. Linux compatibility shims, legacy driver APIs, and compatibility daemons are outside the target design.
- **Native-only drivers**: Drivers use Aether's native driver ABI, HAL services, IPC, and capability model. Legacy Linux driver source or binary compatibility is not supported.
- **Explicit capabilities**: Access to device resources is granted through revocable capabilities. The kernel validates each request before mapping memory, routing interrupts, or exposing MMIO.
- **Containment by construction**: Driver faults, DMA faults, and device misbehavior are contained to the affected driver context and its device domain.

## 3. Core Architecture
- **Aether Microkernel (Ring 0)**: Minimal core responsible for scheduling, IPC, memory management, capabilities, and IOMMU domain programming.
- **Hardware Abstraction Layer (HAL)**: Uniform interface for device discovery, interrupt routing, MMIO/I/O-port access, DMA mapping, and device registration.
- **Gateway**: Capability-checked entry point for driver requests that need kernel or hardware resources.
- **Native driver contexts**: Drivers execute outside the kernel address space and receive only the resources required for their assigned device.
- **IOMMU domains**: Each device or tightly coupled device group is assigned to an IOMMU domain that limits device-visible memory to explicitly granted IOVA ranges.

## 4. Production Hardening
- **Zero-Copy IPC**: Shared-memory grants use explicit ownership and lifetime rules, with IOMMU mappings created only for active grants.
- **Security-First Validation**: Device requests are checked against capabilities before memory is pinned, IOMMU mappings are installed, or interrupts are delivered.
- **Minimal C++26 Surface**: Aether keeps the trusted codebase small and auditable by avoiding compatibility layers and legacy kernel API emulation.
- **Verification Path**: The kernel core and HAL are designed for static analysis (`clang-tidy`, `cppcheck`) and, eventually, formal verification to prove memory safety and absence of deadlocks.

## 5. Driver Integration Strategy
Drivers do not run in the kernel address space and are not adapted through a Linux compatibility layer. Each driver is built against Aether's native driver ABI and receives capabilities for the device resources it owns. The HAL maps only the required MMIO, interrupt, and DMA resources into the driver's execution context and programs the IOMMU so the device can access only its assigned IOVA ranges. If a driver faults, leaks memory, or misbehaves, containment is limited to that driver context and its device domain; the Aether core and unrelated drivers remain operational.

## 6. Reference Documents
- [Native Driver Model](NATIVE_DRIVER_MODEL.md)
