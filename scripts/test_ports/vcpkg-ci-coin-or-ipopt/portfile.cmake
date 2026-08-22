set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Ipopt
    REF ec43e37a06054246764fb116e50e3e30c9ada089
    SHA512 f5b30e81b4a1a178e9a0e2b51b4832f07441b2c3e9a2aa61a6f07807f94185998e985fcf3c34d96fbfde78f07b69f2e0a0675e1e478a4e668da6da60521e0fd6
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DIPOPT_PATH=${SOURCE_PATH}"
)
vcpkg_cmake_build()
