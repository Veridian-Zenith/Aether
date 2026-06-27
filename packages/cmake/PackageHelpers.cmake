# ==== Package Definition Helpers ====
# Macro: define_package — register a buildable package with metadata
#
# Usage:
#   define_package(
#     NAME        binutils
#     VERSION     2.44
#     URL         https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz
#     SHA256      ...
#     DEPENDS     linux-headers glibc
#     STAGE       toolchain
#   )

macro(define_package)
    set(options "")
    set(oneValueArgs NAME VERSION URL SHA256 STAGE)
    set(multiValueArgs DEPENDS)
    cmake_parse_arguments(PKG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set("${PKG_NAME}_VERSION" "${PKG_VERSION}" CACHE INTERNAL "${PKG_NAME} version")
    set("${PKG_NAME}_URL" "${PKG_URL}" CACHE INTERNAL "${PKG_NAME} download URL")
    set("${PKG_NAME}_SHA256" "${PKG_SHA256}" CACHE INTERNAL "${PKG_NAME} checksum")
    set("${PKG_NAME}_STAGE" "${PKG_STAGE}" CACHE INTERNAL "${PKG_NAME} build stage")
    set("${PKG_NAME}_DEPENDS" "${PKG_DEPENDS}" CACHE INTERNAL "${PKG_NAME} dependencies")

    message(STATUS "Package [${PKG_STAGE}]: ${PKG_NAME} v${PKG_VERSION}")
endmacro()
