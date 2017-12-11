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
    REF v1.2.0
    SHA512 859063669fd84e847f04624013f0b2b734d75d90cada247682eaf345b86c88a9bc2320250e128f2361e37f402b3fb56a18c493ec6038973744a005a452d693ba
    HEAD_REF master
)

vcpkg_download_distfile(PATCH
    URLS "https://github.com/efcs/benchmark/commit/536b0b82b8ec12fc7e17e6d243633618f294a739.diff"
    FILENAME google-benchmark-1.2.0-536b0b82.patch
    SHA512 ed42cc0014741c8039c0fca5b4317b2ed09d06a25c91f49a48be6dce921e39469b002c088794c1ea73dc759166e20cb685b47f809ba28dddd95b5f3263be03cd
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${PATCH}"
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
