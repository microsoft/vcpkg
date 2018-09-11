
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
    # TODO: point at cpp-io2d/(whatever), if and as needed
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-io2d/P0267_RefImpl
        REF 21ae92c8be6916034e6e18f08aa57899a975dfb0
        SHA512 5b674f98ca7705d6901af339a4189d5ce4f2c3118bfb99430734f355159602f177bc8d1b345c3a2f17947a62547553f7b91747a1f16da063707a4da7f990391d
        HEAD_REF master
        PATCHES find-package.patch
    )
endif()

# Configure the library, using CMake
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DIO2D_WITHOUT_SAMPLES=1
        -DIO2D_WITHOUT_TESTS=1
        -DCMAKE_INSTALL_INCLUDEDIR:STRING=include
)

# Build + install the library, using CMake
vcpkg_install_cmake()

# Don't have duplicate header files in both include/ and debug/include/ folders
# (within <vcpkg-root>/installed/io2d_*/, as installed by vcpkg_install_cmake()):
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/io2d)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake ${CURRENT_PACKAGES_DIR}/share/io2d/io2dTargets.cmake)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-cairo CONFIG)
find_dependency(unofficial-graphicsmagick CONFIG)

include(\${CMAKE_CURRENT_LIST_DIR}/io2dTargets.cmake)
")

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/io2d RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME io2d)
