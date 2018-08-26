
# Allow use of vcpkg functions
include(vcpkg_common_functions)

# For now, io2d is always a static library.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Optionally, uncomment and modify one of the 'set(...)' calls below
# to use io2d sources from a local directory, rather than Github.
# set(SOURCE_PATH "C:\\Path\\To\\P0267_RefImpl\\")
# set(SOURCE_PATH "/Path/To/P0267_RefImpl")

# Retrieve and validate io2d source code, as-needed
if ("${SOURCE_PATH}" STREQUAL "")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH

        ## TODO: point at cpp-io2d/(whatever), if and as needed
        # REPO cpp-io2d/P0267_RefImpl
        # REF a805fc8dfbbab29de171a45899b74e3af4889089
        # SHA512 99ca75d421d7375ec501a702360660e849bae4d728d08e6f93beded3c84944423a00f350d4234e71175d4e3d1426efa68dfae87c841e20eb23ccbabf9047c7b3
        # HEAD_REF master

        ## TODO: remove reference to 'DavidLudwig'-owned repo
        REPO DavidLudwig/P0267_Modified
        REF cc2aeef42d702a694f7dc8d27f9f6b2245b2c52d
        SHA512 f0f609d147a21c188a20c7dbb71ed36989683b6fba2dea5f8c8ac92b521504d49d29ecf13990a4502a75b1b451a6f3150226ae4369446fe85d06441107fded72
        HEAD_REF vcpkg

    )
endif()

# Configure the library, using CMake
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DIO2D_WITHOUT_SAMPLES=1
        -DIO2D_WITHOUT_TESTS=1
)

# Build + install the library, using CMake
vcpkg_install_cmake()

# Don't have duplicate header files in both include/ and debug/include/ folders
# (within <vcpkg-root>/installed/io2d_*/, as installed by vcpkg_install_cmake()):
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Don't have duplicate CMake files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Make sure CMake files are installed to the correct location
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/io2d)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/io2d/cmake)

# Remove separate io2d directory (dludwig@pobox.com: should this always be true?  Whither
# a single 'io2d.h' file, with sub-headers within a 'io2d' directory, lest we spam someone's
# 'include' directory?)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)

# [Re]install io2d headers, using a (currently) flat structure
file(
    GLOB IO2D_HEADERS
    "${SOURCE_PATH}/P0267_RefImpl/P0267_RefImpl/*.h"
    "${SOURCE_PATH}/P0267_RefImpl/P0267_RefImpl/cairo/*.h"
    "${SOURCE_PATH}/P0267_RefImpl/P0267_RefImpl/cairo/win32/*.h"
)
file(INSTALL ${IO2D_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Install a copyright file, as suggested by vcpkg itself
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/io2d RENAME copyright)
