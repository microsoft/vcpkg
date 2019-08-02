include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevent/libevent
    REF release-2.1.11-stable
    SHA512 a34ca4ad4d55a989a4f485f929d0ed2438d070d0e12a19d90c2b12783a562419c64db6a2603b093d958a75246d14ffefc8730c69c90b1b2f48339bde947f0e02
    PATCHES
        fix-file_path.patch
        fix-arm_build.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBEVENT_LIB_TYPE SHARED)
else()
    set(LIBEVENT_LIB_TYPE STATIC)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEVENT_INSTALL_CMAKE_DIR:PATH=share/libevent
        -DEVENT__LIBRARY_TYPE=${LIBEVENT_LIB_TYPE}
        -DEVENT__DISABLE_BENCHMARK=ON
        -DEVENT__DISABLE_TESTS=ON
        -DEVENT__DISABLE_REGRESS=ON
        -DEVENT__DISABLE_SAMPLES=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "windows" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/libevent)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
endif()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libevent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libevent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libevent/copyright)
