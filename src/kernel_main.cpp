/*
 * @file kernel_main.cpp
 * @brief Bare-metal kernel entry point
 */

#include "../include/kernel.hpp"

// No standard library allowed!
extern "C" void kernel_main() {
    // 1. Initialize Framebuffer (for basic output)
    // 2. Initialize GDT/IDT (Interrupts)
    // 3. Initialize Memory Manager
    // 4. Start Scheduler
    
    while (true) {
        // Kernel loop
    }
}
