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
    REF v1.4.1
    SHA512 e9d71b4679cb4e4d755f7bb4101e131b37e209b6aebd0853e0c63eb11c42b75faa5da4ff8c265149808a475f3a1cfb140c5b49f877acfda908a4bb7add983aae
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/benchmark)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/benchmark/LICENSE ${CURRENT_PACKAGES_DIR}/share/benchmark/copyright)
