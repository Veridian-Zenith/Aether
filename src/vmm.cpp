#include "vmm.hpp"
#include <algorithm>
#include <cstdlib>
#include <cstring>

namespace Aether {

    ArcaneMemoryPool::ArcaneMemoryPool() {
        m_pool = std::aligned_alloc(k_page_size, k_pool_size);
        if (!m_pool) {
            std::abort();
        }
        std::memset(m_pool, 0, k_pool_size);
        m_pool_base = reinterpret_cast<Address>(m_pool);

        m_free_list = reinterpret_cast<FreeBlock*>(m_pool_base);
        m_free_list->next = nullptr;
        m_free_list->page_count = k_total_pool_pages;

        m_allocations.reserve(64);
    }

    ArcaneMemoryPool::~ArcaneMemoryPool() {
        std::free(m_pool);
    }

    void ArcaneMemoryPool::insertFreeBlock(Address addr, size_t page_count) noexcept {
        auto* block = reinterpret_cast<FreeBlock*>(addr);
        block->page_count = page_count;

        if (!m_free_list || addr < reinterpret_cast<Address>(m_free_list)) {
            block->next = m_free_list;
            m_free_list = block;
            return;
        }

        FreeBlock* prev = m_free_list;
        FreeBlock* curr = m_free_list->next;
        while (curr && reinterpret_cast<Address>(curr) < addr) {
            prev = curr;
            curr = curr->next;
        }

        block->next = curr;
        prev->next = block;

        Address prev_end = reinterpret_cast<Address>(prev) + prev->page_count * k_page_size;
        if (prev_end == addr) {
            prev->page_count += page_count;
            prev->next = block->next;
            block = prev;
        }

        if (block->next) {
            Address block_end = addr + page_count * k_page_size;
            if (block_end == reinterpret_cast<Address>(block->next)) {
                block->page_count += block->next->page_count;
                block->next = block->next->next;
            }
        }
    }

    std::expected<Address, ErrorCode> ArcaneMemoryPool::allocatePage(ProcessId pid) noexcept {
        return allocatePages(pid, 1);
    }

    std::expected<Address, ErrorCode> ArcaneMemoryPool::allocatePages(ProcessId pid, size_t count) noexcept {
        if (count == 0) {
            return std::unexpected(ErrorCode::InvalidSpell);
        }

        std::lock_guard<std::mutex> lock(m_mutex);

        FreeBlock* prev = nullptr;
        FreeBlock* curr = m_free_list;

        while (curr) {
            if (curr->page_count >= count) {
                Address addr = reinterpret_cast<Address>(curr);

                if (curr->page_count > count) {
                    Address remaining_addr = addr + count * k_page_size;
                    auto* remaining = reinterpret_cast<FreeBlock*>(remaining_addr);
                    remaining->page_count = curr->page_count - count;
                    remaining->next = curr->next;
                    if (prev) {
                        prev->next = remaining;
                    } else {
                        m_free_list = remaining;
                    }
                } else {
                    if (prev) {
                        prev->next = curr->next;
                    } else {
                        m_free_list = curr->next;
                    }
                }

                m_allocations[pid].emplace_back(addr, count);
                m_allocated_count += count;
                return addr;
            }
            prev = curr;
            curr = curr->next;
        }

        return std::unexpected(ErrorCode::PoolExhausted);
    }

    void ArcaneMemoryPool::freePage(ProcessId pid, Address addr) noexcept {
        freePages(pid, addr, 1);
    }

    void ArcaneMemoryPool::freePages(ProcessId pid, Address addr, size_t count) noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);

        auto it = m_allocations.find(pid);
        if (it == m_allocations.end()) return;

        auto& pages = it->second;
        auto vec_it = std::find_if(pages.begin(), pages.end(),
            [addr, count](const std::pair<Address, size_t>& p) {
                return p.first == addr && p.second == count;
            });

        if (vec_it != pages.end()) {
            pages.erase(vec_it);
            if (pages.empty()) {
                m_allocations.erase(it);
            }
            m_allocated_count -= count;
            insertFreeBlock(addr, count);
        }
    }

    size_t ArcaneMemoryPool::totalFreePages() const noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        size_t count = 0;
        FreeBlock* curr = m_free_list;
        while (curr) {
            count += curr->page_count;
            curr = curr->next;
        }
        return count;
    }

    size_t ArcaneMemoryPool::totalAllocatedPages() const noexcept {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_allocated_count;
    }

} // namespace Aether
