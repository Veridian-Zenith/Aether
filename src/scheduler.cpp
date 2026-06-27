#include "scheduler.hpp"
#include <algorithm>

namespace Aether {

    WeaverOfTime::WeaverOfTime() {
        for (auto& q : m_queues) {
            q.queue.reserve(64);
        }
        m_sleeping.reserve(32);
    }

    ThreadId WeaverOfTime::nextTid() noexcept {
        std::lock_guard<std::mutex> lock(m_tid_mutex);
        return m_next_tid++;
    }

    ThreadId WeaverOfTime::submitTask(ProcessId pid, std::function<void()> task,
                                      Priority priority) noexcept {
        ThreadId tid = nextTid();
        ThreadControlBlock tcb(pid, tid, std::move(task), priority);
        auto& pq = m_queues[static_cast<size_t>(priority)];
        {
            std::lock_guard<std::mutex> lock(pq.mutex);
            pq.queue.push_back(std::move(tcb));
        }
        return tid;
    }

    void WeaverOfTime::tick() noexcept {
        processSleepQueue();

        for (auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            size_t count = pq.queue.size();
            if (count == 0) continue;

            for (size_t attempt = 0; attempt < count; ++attempt) {
                auto& current = pq.queue[pq.current_index];
                if (current.state == ThreadState::Ready) {
                    current.state = ThreadState::Running;
                    if (current.work) {
                        current.work();
                    }
                    if (current.state == ThreadState::Running) {
                        current.quantum_remaining = default_quantum(current.priority);
                        current.state = ThreadState::Ready;
                        pq.current_index = (pq.current_index + 1) % pq.queue.size();
                    }
                    return;
                }
                pq.current_index = (pq.current_index + 1) % count;
            }
        }
    }

    void WeaverOfTime::yield() noexcept {
        for (size_t prio = 0; prio < m_queues.size(); ++prio) {
            auto& pq = m_queues[prio];
            std::lock_guard<std::mutex> lock(pq.mutex);
            if (pq.queue.empty()) continue;

            auto& current = pq.queue[pq.current_index];
            if (current.state == ThreadState::Running) {
                current.state = ThreadState::Ready;
                pq.current_index = (pq.current_index + 1) % pq.queue.size();
                return;
            }
        }
    }

    void WeaverOfTime::sleep(ProcessId pid, ThreadId tid,
                             std::chrono::milliseconds duration) noexcept {
        auto now = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch());

        for (auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            auto it = std::find_if(pq.queue.begin(), pq.queue.end(),
                [pid, tid](const ThreadControlBlock& t) {
                    return t.pid == pid && t.tid == tid;
                });
            if (it != pq.queue.end()) {
                it->state = ThreadState::Sleeping;
                it->wakeup_time = now + duration;
                {
                    std::lock_guard<std::mutex> s_lock(m_sleep_mutex);
                    m_sleeping.push_back(std::move(*it));
                }
                pq.queue.erase(it);
                return;
            }
        }
    }

    void WeaverOfTime::wake(ProcessId pid, ThreadId tid) noexcept {
        {
            std::lock_guard<std::mutex> s_lock(m_sleep_mutex);
            auto it = std::find_if(m_sleeping.begin(), m_sleeping.end(),
                [pid, tid](const ThreadControlBlock& t) {
                    return t.pid == pid && t.tid == tid;
                });
            if (it != m_sleeping.end()) {
                it->state = ThreadState::Ready;
                auto& pq = m_queues[static_cast<size_t>(it->priority)];
                {
                    std::lock_guard<std::mutex> lock(pq.mutex);
                    pq.queue.push_back(std::move(*it));
                }
                m_sleeping.erase(it);
            }
        }
    }

    void WeaverOfTime::block(ProcessId pid, ThreadId tid) noexcept {
        for (auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            auto it = std::find_if(pq.queue.begin(), pq.queue.end(),
                [pid, tid](const ThreadControlBlock& t) {
                    return t.pid == pid && t.tid == tid;
                });
            if (it != pq.queue.end()) {
                it->state = ThreadState::Blocked;
                return;
            }
        }
    }

    void WeaverOfTime::unblock(ProcessId pid, ThreadId tid) noexcept {
        for (auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            auto it = std::find_if(pq.queue.begin(), pq.queue.end(),
                [pid, tid](const ThreadControlBlock& t) {
                    return t.pid == pid && t.tid == tid;
                });
            if (it != pq.queue.end()) {
                it->state = ThreadState::Ready;
                return;
            }
        }
    }

    void WeaverOfTime::processSleepQueue() noexcept {
        auto now = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch());

        std::lock_guard<std::mutex> s_lock(m_sleep_mutex);
        auto it = m_sleeping.begin();
        while (it != m_sleeping.end()) {
            if (it->wakeup_time <= now) {
                it->state = ThreadState::Ready;
                auto& pq = m_queues[static_cast<size_t>(it->priority)];
                {
                    std::lock_guard<std::mutex> lock(pq.mutex);
                    pq.queue.push_back(std::move(*it));
                }
                it = m_sleeping.erase(it);
            } else {
                ++it;
            }
        }
    }

    size_t WeaverOfTime::readyCount() const noexcept {
        size_t count = 0;
        for (const auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            for (const auto& tcb : pq.queue) {
                if (tcb.state == ThreadState::Ready || tcb.state == ThreadState::Running) {
                    ++count;
                }
            }
        }
        return count;
    }

    size_t WeaverOfTime::totalCount() const noexcept {
        size_t count = 0;
        for (const auto& pq : m_queues) {
            std::lock_guard<std::mutex> lock(pq.mutex);
            count += pq.queue.size();
        }
        {
            std::lock_guard<std::mutex> s_lock(m_sleep_mutex);
            count += m_sleeping.size();
        }
        return count;
    }

} // namespace Aether
