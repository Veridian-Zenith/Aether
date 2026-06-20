# Aether Native Driver Model

## 1. Purpose
Aether uses a native-only driver model. Drivers are written against Aether's HAL, IPC, memory, and capability interfaces. The Linux Compatibility Layer is not part of the architecture; legacy Linux driver source compatibility is a non-goal.

## 2. Architecture
- **Driver context**: Each driver runs in its own execution context with its own virtual address space and explicit resource grants.
- **HAL and Gateway**: The HAL owns hardware discovery, interrupt routing, MMIO access, DMA mapping, and device registration. Drivers request operations through capability-checked HAL/Gateway interfaces rather than touching device registers directly.
- **IOMMU domains**: Each device, or tightly coupled device group, is assigned to an IOMMU domain. The kernel programs the IOMMU so the device can only access IOVA ranges granted by the kernel.
- **Capability registry**: A driver receives capabilities for the device resources it owns: MMIO windows, interrupt lines, DMA buffers, and shared-memory endpoints. Capabilities are revocable and scoped to a driver instance.
- **Fault containment**: CPU memory faults, DMA faults, interrupt storms, and driver hangs are contained to the driver context and its device domain.

## 3. Memory Management
### Driver Code and Data
- Driver code and ordinary data use normal virtual memory.
- Kernel-owned page tables isolate driver memory from the kernel and other drivers.
- Shared buffers between drivers and services are exchanged by explicit grants, not by implicit global mappings.

### DMA and IOMMU-Backed Buffers
- Drivers request DMA buffers through the HAL.
- The kernel pins or otherwise stabilizes physical pages as required by the platform.
- The HAL creates device-visible IOVA mappings in the device's IOMMU domain.
- The driver receives handles to IOVA ranges, not raw physical addresses.
- The kernel owns IOMMU page-table updates; drivers cannot reprogram translation tables directly.

### Shared Memory
- Zero-copy IPC uses shared-memory grants with explicit ownership, lifetime, and access mode.
- The HAL maps grant pages into the relevant IOMMU domain only while the grant is active.
- Revoking a grant removes the device-visible mapping before the memory is reused.

## 4. Security Guarantees
- A device cannot DMA outside the IOVA ranges programmed for its IOMMU domain.
- A driver cannot access MMIO, interrupts, or DMA buffers without a matching capability.
- A compromised driver cannot corrupt the kernel or another driver through ordinary memory access because it runs in its own address space.
- A compromised device cannot overwrite kernel or unrelated driver memory because the IOMMU denies unauthorized DMA.
- Revoking capabilities removes the corresponding CPU and IOMMU access paths.
- The TCB remains small because Aether exposes native interfaces only and does not include Linux ABI compatibility code.

## 5. Non-Goals
- Binary compatibility with Linux drivers.
- Source compatibility with Linux kernel internal APIs.
- Emulating Linux driver semantics for legacy hardware.
