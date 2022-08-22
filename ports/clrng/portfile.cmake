vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clMathLibraries/clRNG
    REF 4a16519ddf52ee0a5f0b7e6288b0803b9019c13b
    SHA512 28bda5d2a156e7394917f8c40bd1e8e7b52cf680abc0ef50c2650b1d546c0a1d0bd47ceeccce3cd7c79c90a15494c3d27829e153613a7d8e18267ce7262eeb6e
    HEAD_REF master
    PATCHES
        001-build-fixup.patch
)

file(REMOVE ${SOURCE_PATH}/src/FindOpenCL.cmake)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(R123_SSE_FLAG [[-DCMAKE_C_FLAGS="/DR123_USE_SSE=0"]])
endif()

# We only have x64 and x86 as valid archs, as arm64 fails fast
string(COMPARE EQUAL "${VCPKG_TARGET_ARCHITECTURE}" "x64" BUILD64)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        -DBUILD_SHARED_LIBRARY=${BUILD_SHARED_LIBRARY}
        -DBUILD64=${BUILD64}
        -DBUILD_TEST=OFF
        -DBUILD_CLIENT=OFF
        ${R123_SSE_FLAG}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(
        REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/clRNG)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
