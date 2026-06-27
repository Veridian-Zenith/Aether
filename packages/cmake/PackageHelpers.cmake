# Package definition macro
macro(define_package)
    set(options "")
    set(oneValueArgs NAME VERSION URL SHA256 STAGE BUILD_SYSTEM)
    set(multiValueArgs DEPENDS TOOLS)
    cmake_parse_arguments(PKG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set("${PKG_NAME}_VERSION" "${PKG_VERSION}" CACHE INTERNAL "")
    set("${PKG_NAME}_URL" "${PKG_URL}" CACHE INTERNAL "")
    set("${PKG_NAME}_STAGE" "${PKG_STAGE}" CACHE INTERNAL "")
    set("${PKG_NAME}_BUILD_SYSTEM" "${PKG_BUILD_SYSTEM}" CACHE INTERNAL "")
    set("${PKG_NAME}_DEPENDS" "${PKG_DEPENDS}" CACHE INTERNAL "")
    set("${PKG_NAME}_TOOLS" "${PKG_TOOLS}" CACHE INTERNAL "")

    message(STATUS "Package [${PKG_STAGE}]: ${PKG_NAME} v${PKG_VERSION} (${PKG_BUILD_SYSTEM})")
endmacro()
