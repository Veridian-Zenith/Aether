# Aether Native Driver Development Guide

## 1. Driver Entry Points
- Drivers must be initialized through the Aether Gateway or HAL
- Entry point: `AetherGateway::handleSyscall` or HAL device registration callbacks
- Requires initial capability grant from kernel for driver context creation

## 2. Interacting with the Aether Gateway
- Request capabilities via `SigilRegistry::ordain(pid, Sigil::SysAdmin)`
- Use `Gateway::handleSyscall(pid, syscall_nr, arg1)` for kernel resource access
- Gateway validates capabilities before translating syscalls to IPC or hardware operations

## 3. IOMMU Memory Allocation
- Allocate memory via `VMM::allocatePage(pid)` to get physical address
- HAL maps physical pages to device-visible IOVA ranges
- Drivers receive IOVA handles (not physical addresses)
- IOMMU domain must be configured for device's memory access rights

## 4. Capability/Sigil Registration
- Drivers must request Sigils for device resources:
  - `Sigil::Read/Write/Execute` for MMIO access
  - `Sigil::Network` for DMA operations
  - `Sigil::SysAdmin` for full device control
- Capabilities are revocable and scoped to driver instance
- Kernel enforces capability checks before resource access

## 5. Driver Lifecycle
- Drivers run in isolated address spaces
- Resources (MMIO, interrupts, DMA) are granted via capabilities
- On driver failure, capabilities are revoked and IOMMU mappings removed

## 6. Example Workflow
1. Request SysAdmin capability
2. Use Gateway to map IOMMU domain
3. Allocate memory via VMM
4. Register device with HAL using granted capabilities
5. Handle interrupts via capability-checked HAL callbacks
