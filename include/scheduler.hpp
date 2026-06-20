/**
 * @file scheduler.hpp
 * @brief The Weaver of Time (Task Scheduler)
 * @copyright Copyright (C) 2026 Veridian Zenith
 * @author Dae Euhwa <daedaevibin@ik.me>
 *
 * All code in this repository is licensed under OSL v3.
 */

#pragma once

#include "kernel.hpp"
#include <functional>
#include <queue>
#include <mutex>
#include <condition_variable>

namespace Aether {

    /**
     * @brief Manages task scheduling for spheres of execution.
     */
    class WeaverOfTime {
    public:
        /**
         * @brief Adds a task to the ready queue.
         */
        void submitTask(ProcessId pid, std::function<void()> task) noexcept;

        /**
         * @brief Executes the next task from the queue.
         */
        void tick() noexcept;

    private:
        struct Task {
            ProcessId pid;
            std::function<void()> work;
        };
        std::queue<Task> m_ready_queue;
        std::mutex m_mutex;
    };

} // namespace Aether
