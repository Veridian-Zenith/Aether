/**
 * @file scheduler.cpp
 * @brief Implementation of the Weaver of Time
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#include "scheduler.hpp"

namespace Aether {

    void WeaverOfTime::submitTask(ProcessId pid, std::function<void()> task) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_ready_queue.push({pid, std::move(task)});
    }

    void WeaverOfTime::tick() noexcept {
        Task task;
        {
            std::lock_guard<std::mutex> lock(m_mutex);
            if (m_ready_queue.empty()) return;
            task = std::move(m_ready_queue.front());
            m_ready_queue.pop();
        }
        
        // Execute the task
        task.work();
    }

} // namespace Aether
