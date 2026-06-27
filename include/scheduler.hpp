#pragma once

#include "kernel.hpp"
#include <functional>
#include <array>
#include <vector>
#include <mutex>
#include <chrono>
#include <cstdint>

namespace Aether {

    enum class Priority : uint8_t {
        High = 0,
        Normal = 1,
        Low = 2,
        Count
    };

    enum class ThreadState : uint8_t {
        Ready,
        Running,
        Sleeping,
        Blocked,
        Terminated
    };

    constexpr size_t default_quantum(Priority p) noexcept {
        switch (p) {
            case Priority::High:   return 20;
            case Priority::Normal: return 10;
            case Priority::Low:    return 5;
            default:               return 10;
        }
    }

    struct ThreadControlBlock {
        ProcessId pid;
        ThreadId tid;
        std::function<void()> work;
        Priority priority;
        ThreadState state;
        size_t quantum_remaining;
        std::chrono::milliseconds wakeup_time{0};

        ThreadControlBlock() = default;

        ThreadControlBlock(ProcessId pid, ThreadId tid, std::function<void()> work, Priority priority)
            : pid(pid), tid(tid), work(std::move(work)), priority(priority),
              state(ThreadState::Ready), quantum_remaining(default_quantum(priority)) {}
    };

    class WeaverOfTime {
    public:
        WeaverOfTime();

        ThreadId submitTask(ProcessId pid, std::function<void()> task,
                            Priority priority = Priority::Normal) noexcept;

        void tick() noexcept;

        void yield() noexcept;

        void sleep(ProcessId pid, ThreadId tid, std::chrono::milliseconds duration) noexcept;

        void wake(ProcessId pid, ThreadId tid) noexcept;

        void block(ProcessId pid, ThreadId tid) noexcept;

        void unblock(ProcessId pid, ThreadId tid) noexcept;

        [[nodiscard]] size_t readyCount() const noexcept;
        [[nodiscard]] size_t totalCount() const noexcept;

    private:
        struct alignas(64) PriorityQueue {
            std::vector<ThreadControlBlock> queue;
            size_t current_index{0};
            mutable std::mutex mutex;
        };

        std::array<PriorityQueue, static_cast<size_t>(Priority::Count)> m_queues;
        std::vector<ThreadControlBlock> m_sleeping;
        mutable std::mutex m_sleep_mutex;
        ThreadId m_next_tid{1};
        std::mutex m_tid_mutex;

        ThreadId nextTid() noexcept;
        void processSleepQueue() noexcept;
    };

} // namespace Aether
