include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevent/libevent
    REF release-2.1.10-stable
    SHA512 8c336df258f7a12164da739b0ea68bebcc8b2ea4f4a839300aa1c5edfb673ac5d6517f882ba04ab35d406489ddd682a319e39fa6784ac0cab73227d42e503a55
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
