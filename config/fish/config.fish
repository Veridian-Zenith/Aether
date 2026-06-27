# Aether Linux — default fish configuration
# Mirrors host config (see ~/.config/fish/config.fish)

# Core environment
set -gx CLICOLOR 1
set -gx COLORTERM truecolor
set -gx MANPAGER "less -R"
set -gx EDITOR nano
set -gx VISUAL nano

# Amoled Warm Palette
set -g fish_color_command brmagenta
set -g fish_color_keyword brpurple
set -g fish_color_param yellow
set -g fish_color_error red
set -g fish_color_comment brblack

# LLVM toolchain (system default)
set -gx CC clang
set -gx CXX clang++
set -gx LD ld.lld
set -gx AS clang

set -gx AR llvm-ar
set -gx NM llvm-nm
set -gx STRIP llvm-strip
set -gx OBJCOPY llvm-objcopy
set -gx OBJDUMP llvm-objdump
set -gx READELF llvm-readelf
set -gx RANLIB llvm-ranlib

set -l COMMON_FLAGS "-march=native -O3 -pipe -fno-plt -rtlib=compiler-rt -unwindlib=libunwind"
set -l WARN_FLAGS "-Wno-unused-variable -Wno-unused-parameter -Wno-unused-function"

set -gx CFLAGS "$COMMON_FLAGS $WARN_FLAGS"
set -gx CXXFLAGS "$COMMON_FLAGS $WARN_FLAGS"
set -gx CPPFLAGS "-D_FORTIFY_SOURCE=3"
set -gx LDFLAGS "-fuse-ld=lld -Wl,-O1,--as-needed,-z,relro,-z,now -Wl,--icf=all -Wl,--gc-sections -rtlib=compiler-rt -unwindlib=libunwind"
set -gx MAKEFLAGS "-j"(nproc)

# Modern tools as defaults
alias ls "eza -lh --icons --group-directories-first"
alias ll "eza -lah --icons --group-directories-first --git"
alias tree "eza --tree --icons"
alias grep rg
alias cat bat
alias find fd
