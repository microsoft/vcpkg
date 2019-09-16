
# Allow use of vcpkg functions
include(vcpkg_common_functions)

# For now, io2d is always a static library.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-io2d/P0267_RefImpl
    REF add3c9792dcd3f08c497ae3adafb2a3b5b5fc338
    SHA512 2727342fbb31523583374ab6df6ff7542e80b4f94319cf0f293e8c085711fa10ed312b4fc4b91391112b5e27eaaae519cb4141ea9d4108ffb5b7383a043b38b8
    HEAD_REF master
    PATCHES find-package.patch
)

# Configure the library, using CMake
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
    set(IO2D_DEFAULT_OPTION "-DIO2D_DEFAULT=COREGRAPHICS_MAC")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DIO2D_WITHOUT_SAMPLES=1
        -DIO2D_WITHOUT_TESTS=1
        -DCMAKE_INSTALL_INCLUDEDIR:STRING=include
        ${IO2D_DEFAULT_OPTION}
)

# Build + install the library, using CMake
vcpkg_install_cmake()

# Don't have duplicate header files in both include/ and debug/include/ folders
# (within <vcpkg-root>/installed/io2d_*/, as installed by vcpkg_install_cmake()):
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/io2d)

if (NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake ${CURRENT_PACKAGES_DIR}/share/io2d/io2dTargets.cmake)
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake "
    include(CMakeFindDependencyMacro)
    find_dependency(unofficial-cairo CONFIG)
    find_dependency(unofficial-graphicsmagick CONFIG)

    include(\${CMAKE_CURRENT_LIST_DIR}/io2dTargets.cmake)
    ")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/io2d RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME io2d)
