#include <print>
#include <cassert>
#include <atomic>
#include <thread>
#include <chrono>
#include "../include/kernel.hpp"
#include "../include/capability.hpp"
#include "../include/ipc.hpp"
#include "../include/vmm.hpp"
#include "../include/scheduler.hpp"
#include "../include/gateway.hpp"
#include "../include/hal.hpp"
#include "../include/iommu.hpp"
#include "../include/logger.hpp"

using namespace Aether;

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST(name) \
    do { \
        std::print("  Test: {} ... ", name); \
        try {

#define END_TEST(name) \
            std::println("PASSED"); \
            ++tests_passed; \
        } catch (...) { \
            std::println("FAILED"); \
            ++tests_failed; \
        } \
    } while(0)

// ============================================================================
// Capability Store (Sigil Registry)
// ============================================================================
static void test_capability_store() {
    std::println("\n[Capability Store]");

    TEST("Ordain and check Read sigil") {
        SigilRegistry sigils;
        ProcessId proc = 101;
        sigils.ordain(proc, Sigil::Read);
        assert(sigils.isWorthy(proc, Sigil::Read) == true);
        assert(sigils.isWorthy(proc, Sigil::Write) == false);
    } END_TEST("Ordain and check Read sigil");

    TEST("Kernel PID is always worthy") {
        SigilRegistry sigils;
        assert(sigils.isWorthy(k_kernel_pid, Sigil::SysAdmin) == true);
        assert(sigils.isWorthy(k_kernel_pid, Sigil::Execute) == true);
    } END_TEST("Kernel PID is always worthy");

    TEST("Revoke sigil") {
        SigilRegistry sigils;
        ProcessId proc = 202;
        sigils.ordain(proc, Sigil::Write);
        assert(sigils.isWorthy(proc, Sigil::Write) == true);
        sigils.revoke(proc, Sigil::Write);
        assert(sigils.isWorthy(proc, Sigil::Write) == false);
    } END_TEST("Revoke sigil");

    TEST("Banish process (revoke all)") {
        SigilRegistry sigils;
        ProcessId proc = 303;
        sigils.ordain(proc, Sigil::Read);
        sigils.ordain(proc, Sigil::Write);
        sigils.ordain(proc, Sigil::Execute);
        sigils.banish(proc);
        assert(sigils.isWorthy(proc, Sigil::Read) == false);
        assert(sigils.isWorthy(proc, Sigil::Write) == false);
        assert(sigils.isWorthy(proc, Sigil::Execute) == false);
    } END_TEST("Banish process (revoke all)");

    TEST("Unknown process has no sigils") {
        SigilRegistry sigils;
        assert(sigils.isWorthy(999, Sigil::Network) == false);
    } END_TEST("Unknown process has no sigils");
}

// ============================================================================
// IPC Broker (Runic Nexus)
// ============================================================================
static void test_ipc_broker() {
    std::println("\n[IPC Broker]");

    TEST("Create channel and send/receive message") {
        IpcBroker ipc;
        ProcessId sender = 1;
        ProcessId receiver = 2;
        assert(ipc.createChannel(receiver) == true);
        IPCMessage msg{sender, receiver, MessageType::Request, 42};
        assert(ipc.sendMessage(receiver, msg) == true);
        auto received_opt = ipc.receiveMessage(receiver);
        assert(received_opt.has_value());
        assert(received_opt->payload == 42);
        assert(received_opt->sender == sender);
        assert(received_opt->type == MessageType::Request);
    } END_TEST("Create channel and send/receive message");

    TEST("Send to non-existent channel fails") {
        IpcBroker ipc;
        IPCMessage msg{1, 999, MessageType::Request, 0};
        assert(ipc.sendMessage(999, msg) == false);
    } END_TEST("Send to non-existent channel fails");

    TEST("Receive from channel with no messages returns nullopt") {
        IpcBroker ipc;
        ProcessId pid = 10;
        ipc.createChannel(pid);
        auto result = ipc.receiveMessage(pid);
        assert(result.has_value() == false);
    } END_TEST("Receive from channel with no messages returns nullopt");

    TEST("Remove channel") {
        IpcBroker ipc;
        ProcessId pid = 20;
        ipc.createChannel(pid);
        assert(ipc.hasChannel(pid) == true);
        ipc.removeChannel(pid);
        assert(ipc.hasChannel(pid) == false);
    } END_TEST("Remove channel");

    TEST("Convenience send methods") {
        IpcBroker ipc;
        ProcessId sender = 30;
        ProcessId receiver = 31;
        ipc.createChannel(receiver);

        assert(ipc.sendRequest(receiver, sender, 100) == true);
        auto req = ipc.receiveMessage(receiver);
        assert(req.has_value() && req->type == MessageType::Request && req->payload == 100);

        assert(ipc.sendResponse(receiver, sender, 200) == true);
        auto rsp = ipc.receiveMessage(receiver);
        assert(rsp.has_value() && rsp->type == MessageType::Response && rsp->payload == 200);

        assert(ipc.sendSignal(receiver, sender, 300) == true);
        auto sig = ipc.receiveMessage(receiver);
        assert(sig.has_value() && sig->type == MessageType::Signal && sig->payload == 300);
    } END_TEST("Convenience send methods");
}

// ============================================================================
// Virtual Memory Manager (Arcane Memory Pool)
// ============================================================================
static void test_vmm() {
    std::println("\n[Virtual Memory Manager]");

    TEST("Allocate single page") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 100;
        auto mem = vmm.allocatePage(pid);
        assert(mem.has_value());
        assert(*mem % k_page_size == 0);
    } END_TEST("Allocate single page");

    TEST("Allocate multiple pages") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 200;
        auto mem = vmm.allocatePages(pid, 10);
        assert(mem.has_value());
        assert(vmm.totalAllocatedPages() == 10);
    } END_TEST("Allocate multiple pages");

    TEST("Allocate and free reuses memory") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 300;
        auto a1 = vmm.allocatePage(pid);
        assert(a1.has_value());
        vmm.freePage(pid, *a1);
        auto a2 = vmm.allocatePage(pid);
        assert(a2.has_value());
        assert(*a1 == *a2);
    } END_TEST("Allocate and free reuses memory");

    TEST("Free-list coalescing") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 400;
        auto p1 = vmm.allocatePages(pid, 5);
        auto p2 = vmm.allocatePages(pid, 5);
        auto p3 = vmm.allocatePages(pid, 5);
        assert(p1.has_value() && p2.has_value() && p3.has_value());
        vmm.freePages(pid, *p2, 5);
        vmm.freePages(pid, *p1, 5);
        vmm.freePages(pid, *p3, 5);
        // Should be able to allocate 15 contiguous pages now
        auto big = vmm.allocatePages(pid, 15);
        assert(big.has_value());
    } END_TEST("Free-list coalescing");

    TEST("Free unknown page does nothing") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 500;
        vmm.freePage(pid, 0xDEAD0000);
        // Should not crash
    } END_TEST("Free unknown page does nothing");

    TEST("Total free pages decreases after allocation") {
        ArcaneMemoryPool vmm;
        ProcessId pid = 600;
        size_t before = vmm.totalFreePages();
        auto mem = vmm.allocatePages(pid, 50);
        assert(mem.has_value());
        assert(vmm.totalFreePages() == before - 50);
    } END_TEST("Total free pages decreases after allocation");
}

// ============================================================================
// Scheduler (Weaver of Time)
// ============================================================================
static void test_scheduler() {
    std::println("\n[Scheduler]");

    TEST("Submit and run a task") {
        WeaverOfTime scheduler;
        std::atomic<bool> ran{false};
        scheduler.submitTask(1, [&]() { ran = true; });
        scheduler.tick();
        assert(ran == true);
    } END_TEST("Submit and run a task");

    TEST("Multiple tasks run in order") {
        WeaverOfTime scheduler;
        std::atomic<int> counter{0};
        scheduler.submitTask(1, [&]() { counter += 1; });
        scheduler.submitTask(1, [&]() { counter += 2; });
        scheduler.submitTask(1, [&]() { counter += 3; });
        scheduler.tick();
        assert(counter == 1);
        scheduler.tick();
        assert(counter == 3);
        scheduler.tick();
        assert(counter == 6);
    } END_TEST("Multiple tasks run in order");

    TEST("Priority ordering (High before Normal before Low)") {
        WeaverOfTime scheduler;
        std::atomic<int> last_priority{0};
        scheduler.submitTask(1, [&]() { last_priority = 3; }, Priority::Low);
        scheduler.submitTask(1, [&]() { last_priority = 1; }, Priority::High);
        scheduler.submitTask(1, [&]() { last_priority = 2; }, Priority::Normal);
        scheduler.tick();
        assert(last_priority == 1);
    } END_TEST("Priority ordering (High before Normal before Low)");

    TEST("Sleep and wake") {
        WeaverOfTime scheduler;
        std::atomic<bool> slept{false};
        auto tid = scheduler.submitTask(1, [&]() { slept = true; });
        scheduler.sleep(1, tid, std::chrono::milliseconds(1));
        scheduler.tick();
        assert(slept == false);
        std::this_thread::sleep_for(std::chrono::milliseconds(2));
        scheduler.tick();
        assert(slept == true);
    } END_TEST("Sleep and wake");

    TEST("Block and unblock") {
        WeaverOfTime scheduler;
        std::atomic<bool> blocked_task_ran{false};
        auto tid = scheduler.submitTask(1, [&]() { blocked_task_ran = true; });
        scheduler.block(1, tid);
        scheduler.tick();
        assert(blocked_task_ran == false);
        scheduler.unblock(1, tid);
        scheduler.tick();
        assert(blocked_task_ran == true);
    } END_TEST("Block and unblock");

    TEST("Ready count") {
        WeaverOfTime scheduler;
        assert(scheduler.readyCount() == 0);
        scheduler.submitTask(1, []{});
        scheduler.submitTask(1, []{});
        assert(scheduler.readyCount() == 2);
    } END_TEST("Ready count");

    TEST("Total count includes sleeping") {
        WeaverOfTime scheduler;
        auto t1 = scheduler.submitTask(1, []{});
        auto t2 = scheduler.submitTask(1, []{});
        assert(scheduler.totalCount() == 2);
        scheduler.sleep(1, t1, std::chrono::milliseconds(100));
        assert(scheduler.totalCount() == 2);
    } END_TEST("Total count includes sleeping");

    TEST("Yielding advances to next task") {
        WeaverOfTime scheduler;
        std::atomic<int> val{0};
        scheduler.submitTask(1, [&]() {
            val = 1;
        }, Priority::High);
        scheduler.submitTask(1, [&]() {
            val = 2;
        }, Priority::High);
        scheduler.tick(); // runs task 1, sets val=1
        assert(val == 1);
        scheduler.yield();
        scheduler.tick(); // runs task 2, sets val=2
        assert(val == 2);
    } END_TEST("Yielding advances to next task");
}

// ============================================================================
// Gateway (Linux Syscall Translator)
// ============================================================================
static void test_gateway() {
    std::println("\n[Gateway]");

    TEST("sys_mmap (syscall 9) requires Read sigil") {
        SigilRegistry sigils;
        IpcBroker ipc;
        ArcaneMemoryPool vmm;
        WeaverOfTime scheduler;
        AetherGateway gateway(sigils, ipc, vmm, scheduler);
        ProcessId pid = 101;
        sigils.ordain(pid, Sigil::Read);
        auto res = gateway.handleSyscall(pid, 9, 0);
        assert(res.has_value());
    } END_TEST("sys_mmap (syscall 9) requires Read sigil");

    TEST("sys_mmap denied without Read sigil") {
        SigilRegistry sigils;
        IpcBroker ipc;
        ArcaneMemoryPool vmm;
        WeaverOfTime scheduler;
        AetherGateway gateway(sigils, ipc, vmm, scheduler);
        ProcessId pid = 202;
        auto res = gateway.handleSyscall(pid, 9, 0);
        assert(res.has_value() == false);
        assert(res.error() == ErrorCode::SigilDenied);
    } END_TEST("sys_mmap denied without Read sigil");

    TEST("sys_write (syscall 1) requires Write sigil") {
        SigilRegistry sigils;
        IpcBroker ipc;
        ArcaneMemoryPool vmm;
        WeaverOfTime scheduler;
        AetherGateway gateway(sigils, ipc, vmm, scheduler);
        ProcessId pid = 303;
        sigils.ordain(pid, Sigil::Write);
        auto res = gateway.handleSyscall(pid, 1, 0);
        assert(res.has_value());
    } END_TEST("sys_write (syscall 1) requires Write sigil");

    TEST("Unknown syscall returns GatewayMalformed") {
        SigilRegistry sigils;
        IpcBroker ipc;
        ArcaneMemoryPool vmm;
        WeaverOfTime scheduler;
        AetherGateway gateway(sigils, ipc, vmm, scheduler);
        auto res = gateway.handleSyscall(k_kernel_pid, 999, 0);
        assert(res.has_value() == false);
        assert(res.error() == ErrorCode::GatewayMalformed);
    } END_TEST("Unknown syscall returns GatewayMalformed");
}

// ============================================================================
// Hardware Abstraction Layer
// ============================================================================
static void test_hal() {
    std::println("\n[HAL]");

    TEST("Register, dispatch, and unregister IRQ") {
        std::atomic<bool> irq_fired{false};
        HAL::registerIrq(7, [&]() { irq_fired = true; });
        assert(HAL::isIrqEnabled(7) == true);
        HAL::dispatchIrq(7);
        assert(irq_fired == true);
        HAL::unregisterIrq(7);
        assert(HAL::isIrqEnabled(7) == false);
        irq_fired = false;
        HAL::dispatchIrq(7);
        assert(irq_fired == false);
    } END_TEST("Register, dispatch, and unregister IRQ");

    TEST("Enable and disable IRQ") {
        std::atomic<int> count{0};
        HAL::registerIrq(3, [&]() { ++count; });
        HAL::disableIrq(3);
        HAL::dispatchIrq(3);
        assert(count == 0);
        HAL::enableIrq(3);
        HAL::dispatchIrq(3);
        assert(count == 1);
        HAL::unregisterIrq(3);
    } END_TEST("Enable and disable IRQ");

    TEST("DMA mapping") {
        auto dma = HAL::mapDma(0x1000, 4096);
        assert(dma.has_value());
        assert(dma->physical == 0x1000);
        assert(dma->size == 4096);
    } END_TEST("DMA mapping");

    TEST("MMIO read/write") {
        // Allocate some memory to test MMIO
        static uint32_t test_mem[4] = {10, 20, 30, 40};
        Address addr = reinterpret_cast<Address>(test_mem);
        assert(HAL::read32(addr) == 10);
        HAL::write32(addr, 99);
        assert(HAL::read32(addr) == 99);
    } END_TEST("MMIO read/write");
}

// ============================================================================
// IOMMU Manager
// ============================================================================
static void test_iommu() {
    std::println("\n[IOMMU]");

    TEST("Map and unmap page") {
        auto& iommu = IommuManager::instance();
        ProcessId pid = 42;

        auto res = iommu.map_page(pid, 0x1000, 0xBEEF0000);
        assert(res.has_value());

        auto res2 = iommu.unmap_page(pid, 0x1000);
        assert(res2.has_value());
    } END_TEST("Map and unmap page");

    TEST("Double map returns error") {
        auto& iommu = IommuManager::instance();
        ProcessId pid = 43;

        auto res = iommu.map_page(pid, 0x2000, 0xCAFE0000);
        assert(res.has_value());

        auto res2 = iommu.map_page(pid, 0x2000, 0xDEAD0000);
        assert(res2.has_value() == false);
        assert(res2.error() == ErrorCode::InvalidSpell);

        iommu.unmap_page(pid, 0x2000);
    } END_TEST("Double map returns error");

    TEST("Unmap nonexistent mapping returns error") {
        auto& iommu = IommuManager::instance();
        auto res = iommu.unmap_page(9999, 0x3000);
        assert(res.has_value() == false);
    } END_TEST("Unmap nonexistent mapping returns error");

    TEST("Attach device") {
        auto& iommu = IommuManager::instance();
        auto res = iommu.attach_device(1, 0x1234);
        assert(res.has_value());
    } END_TEST("Attach device");
}

// ============================================================================
// Logger
// ============================================================================
static void test_logger() {
    std::println("\n[Logger]");

    TEST("Log at all levels without crashing") {
        Aether::Log::record(Aether::Log::Level::Info, "Test info message");
        Aether::Log::record(Aether::Log::Level::Warning, "Test warning message");
        Aether::Log::record(Aether::Log::Level::Error, "Test error message");
    } END_TEST("Log at all levels without crashing");
}

// ============================================================================
// Error Code String Conversion
// ============================================================================
static void test_error_codes() {
    std::println("\n[Error Codes]");

    TEST("strerror returns known strings for all codes") {
        assert(strerror(ErrorCode::Success) == "Success");
        assert(strerror(ErrorCode::SigilDenied).starts_with("SigilDenied"));
        assert(strerror(ErrorCode::PoolExhausted).starts_with("PoolExhausted"));
        assert(strerror(ErrorCode::RealmNotFound).starts_with("RealmNotFound"));
        assert(strerror(ErrorCode::NexusBlocked).starts_with("NexusBlocked"));
        assert(strerror(ErrorCode::LoomOverflow).starts_with("LoomOverflow"));
        assert(strerror(ErrorCode::GatewayMalformed).starts_with("GatewayMalformed"));
        assert(strerror(ErrorCode::InvalidSpell).starts_with("InvalidSpell"));
    } END_TEST("strerror returns known strings for all codes");

    TEST("strerror handles unknown code") {
        auto unknown = static_cast<ErrorCode>(0xFF);
        assert(strerror(unknown) == "Unknown Chaos");
    } END_TEST("strerror handles unknown code");
}

int main() {
    std::println("============================================");
    std::println("  Aether Microkernel - Comprehensive Tests");
    std::println("============================================");

    test_capability_store();
    test_ipc_broker();
    test_vmm();
    test_scheduler();
    test_gateway();
    test_hal();
    test_iommu();
    test_logger();
    test_error_codes();

    std::println("\n============================================");
    std::println("  Results: {} passed, {} failed", tests_passed, tests_failed);
    std::println("============================================");

    return tests_failed > 0 ? 1 : 0;
}
