vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://gn.googlesource.com/gn
    REF b2afae122eeb6ce09c52d63f67dc53fc517dbdc8 # Tue Jun 11 05:22:10 2024 +0000
)

# Configuration
vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/simple_build"
    OPTIONS
        # none
)

# Default install
vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}/examples/simple_build"
    TARGETS
        # none
)
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools")
    message(SEND_ERROR "Unexpected installation of tools")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib")
    message(SEND_ERROR "Unexpected installation of lib")
endif()


# Install with library targets
vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}/examples/simple_build"
    TARGETS
        :hello_static
        :hello_shared
)
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools")
    message(SEND_ERROR "Unexpected installation of tools")
endif()
find_library(HELLO_STATIC hello_static PATHS "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH)
if(NOT HELLO_STATIC)
    message(SEND_ERROR "Missing installation of lib hello_static")
endif()
find_library(HELLO_SHARED hello_shared PATHS "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH)
if(NOT HELLO_SHARED)
    message(SEND_ERROR "Missing installation of lib hello_shared")
endif()


# Install with executable targets
vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}/examples/simple_build"
    TARGETS
        :hello
)
# Legacy install: not using "${PORT}" subdir
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/tools/hello${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    message(SEND_ERROR "Missing installation of tools")
endif()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools")


# Portfile responsibility: copying relevant headers
if(EXISTS "${CURRENT_PACKAGES_DIR}/include")
    message(SEND_ERROR "Unexpected installation of include")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(TOUCH "${CURRENT_PACKAGES_DIR}/include/vcpkg-ci-vcpkg-gn")


vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
