/**
 * @file test_runner.cpp
 * @brief Verification of the Aether Microkernel components
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include <print>
#include <cassert>
#include "../include/kernel.hpp"
#include "../include/capability.hpp"
#include "../include/ipc.hpp"
#include "../include/vmm.hpp"
#include "../include/scheduler.hpp"
#include "../include/gateway.hpp"

using namespace Aether;

int main() {
    std::println("Starting Aether Kernel Verification...");

    // Setup Components
    SigilRegistry sigils;
    IpcBroker ipc;
    ArcaneMemoryPool vmm;
    WeaverOfTime scheduler;
    AetherGateway gateway(sigils, ipc, vmm, scheduler);

    // Test: Capability Store (Sigil Registry)
    ProcessId proc1 = 101;
    sigils.ordain(proc1, Sigil::Read);
    assert(sigils.isWorthy(proc1, Sigil::Read) == true);
    assert(sigils.isWorthy(proc1, Sigil::Write) == false);
    std::println("Capability Store verified.");

    // Test: IPC Broker (Runic Nexus)
    IPCMessage msg = {proc1, MessageType::Request, 42};
    ipc.sendMessage(proc1, msg);
    auto received_opt = ipc.receiveMessage(proc1);
    assert(received_opt.has_value());
    IPCMessage received = *received_opt;
    assert(received.payload == 42);
    std::println("IPC Broker verified.");

    // Test: VMM (Arcane Memory Pool)
    auto mem = vmm.allocatePage(proc1);
    assert(mem.has_value());
    std::println("VMM verified (Addr: {:#x})", *mem);

    // Test: Gateway (Linux Syscall Translator)
    auto syscall_res = gateway.handleSyscall(proc1, 9, 0); // Syscall 9 (mmap simulation)
    assert(syscall_res.has_value());
    std::println("Gateway verified.");

    std::println("All verification tests passed. Aether is stable.");
    return 0;
}
