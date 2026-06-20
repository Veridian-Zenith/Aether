# Aether Linux Compatibility Layer (LCL) Design

## 1. Goal
Provide binary and source compatibility for Linux drivers without running the full Linux kernel.

## 2. The Shim Mechanism
The LCL acts as a "Fake Kernel" runtime. When a Linux driver is loaded, it does not link against `vmlinux`. Instead, it links against `libaether_lcl.so`.

### Key Translation Components
- **API Shim (`lcl_api.c`)**: Implements essential kernel symbols (e.g., `printk` -> `Aether::Log::record`, `kmalloc` -> `ArcaneMemoryPool::allocatePage`).
- **Interrupt Manager (`lcl_irq.c`)**: Maps Linux IRQ handling to Aether’s scheduler and IPC signals.
- **DMA Mapper (`lcl_dma.c`)**: Translates Linux DMA address requests into Aether-managed physical memory page grants.

## 3. Sandboxing Strategy
Every driver loaded via LCL runs in a dedicated **User-Mode Execution Realm**. 
- The driver cannot access memory outside its allocated realm.
- All hardware interaction occurs through the **Aether Gateway (HAL)**.
- If a driver attempts an unauthorized memory access, the Aether Microkernel (Ring 0) traps the exception, revokes the driver's Sigils, and restarts the sandbox.

## 4. Performance Optimization: Zero-Copy
To ensure performance exceeds native Linux, the LCL will provide shared memory pools to drivers for network packets and disk blocks. This eliminates the context-switch cost of moving data between the driver and the user-application consuming the data.
