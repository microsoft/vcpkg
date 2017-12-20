if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
  message(FATAL_ERROR "Google benchmark only supports dynamic crt linkage.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF v1.3.0
    SHA512 272775e4dbd0ecc65a2a3a64f24e79682b630929dea3af47349329ac8b796341f1197458a67c9aac0e514857ebe7cbc191d18f6fd2c0aea3242562e69d8a6849
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/benchmark)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/benchmark/LICENSE ${CURRENT_PACKAGES_DIR}/share/benchmark/copyright)
