#pragma once

#include "kernel.hpp"
#include <unordered_map>
#include <vector>
#include <mutex>
#include <cstdint>

namespace Aether {

    class ArcaneMemoryPool {
    public:
        ArcaneMemoryPool();

        ~ArcaneMemoryPool();

        [[nodiscard]] std::expected<Address, ErrorCode> allocatePage(ProcessId pid) noexcept;

        [[nodiscard]] std::expected<Address, ErrorCode> allocatePages(ProcessId pid, size_t count) noexcept;

        void freePage(ProcessId pid, Address addr) noexcept;

        void freePages(ProcessId pid, Address addr, size_t count) noexcept;

        [[nodiscard]] size_t totalFreePages() const noexcept;
        [[nodiscard]] size_t totalAllocatedPages() const noexcept;

    private:
        struct FreeBlock {
            FreeBlock* next;
            size_t page_count;
        };

        static constexpr size_t k_total_pool_pages = 65536;
        static constexpr size_t k_pool_size = k_total_pool_pages * k_page_size;

        FreeBlock* m_free_list{nullptr};
        std::unordered_map<ProcessId, std::vector<std::pair<Address, size_t>>> m_allocations;
        mutable std::mutex m_mutex;
        size_t m_allocated_count{0};
        void* m_pool{nullptr};
        Address m_pool_base{0};

        void insertFreeBlock(Address addr, size_t page_count) noexcept;
    };

} // namespace Aether
