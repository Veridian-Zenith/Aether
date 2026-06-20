# Aether - The Weaver of Realms

## The Prophecy

Born from the desire for absolute control and security, Aether is a modern, User-Mode Microkernel designed to govern the ascension of tasks within your digital realm. As a hardened successor to traditional monoliths, it utilizes the pact of Sigils (Capabilities) and Runic Nexus (IPC) to ensure only the worthy are granted the power to execute higher-order incantations.

"Where monoliths scatter chaos, Aether binds it with structure."

## The Arcane Arts (Core Components)

- **The Sigil Registry (Capability Store)**: Guards the gates, ensuring only the worthy are granted rights (`READ`, `WRITE`, `EXECUTE`) to memory and operations.
- **The Runic Nexus (IPC Broker)**: The central artery for communication between spheres of execution, ensuring safe and synchronized transmission of Runes (messages).
- **Arcane Memory Pool (VM Manager)**: A guardian of the virtual memory, allocating and safeguarding pages of wisdom (memory) for processes.
- **Weaver of Time (Task Scheduler)**: Orchestrates the execution of threads across the digital loom, managing the passage of time for each sphere.
- **Aether Gateway (Linux Compatibility Layer)**: Interprets the mortal incantations (Linux Syscalls) and translates them into divine Aether IPC messages, allowing for seamless integration.

## Forging the Artifact

Aether commands strict adherence to modern crafting:

- **LLVM Clang Toolchain**
- **C++26** compliant arcane environment
- **CMake** (v3.18+) and **Ninja**

### Bringing Forth the Binary

1. **Obtain the Scrolls**:
   ```bash
   git clone [Aether Repository URL] && cd Aether
   ```

2. **Forge the Release Artifact**:
   ```bash
   cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
   cmake --build build
   ```

3. **Verify the Integrity (The Trial of Truth)**:
   ```bash
   cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
   cmake --build build
   ./build/tests/run_tests
   ```

## The Final Vow (License)

Aether is sealed and distributed under the Open Software License v3.0 (OSL-3.0).
