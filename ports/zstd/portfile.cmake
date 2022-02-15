vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/zstd
    REF f4a552a3fa24d9078f84157bd40e4f1bad49c488 #v1.5.2
    SHA512 5e0343cfc06d756c3f09647df39f1c15b39707c0b9b6d343b1be8f1e99d567b52f5b9228925c2190d1600a5b54822c2a4546b2443b13f43eb9a75f97e7fa41f5
    HEAD_REF dev
    PATCHES
        install_pkgpc.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZSTD_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZSTD_BUILD_SHARED)

if(VCPKG_TARGET_IS_WINDOWS)
    # Enable multithreaded mode. CMake build doesn't provide a multithreaded
    # library target, but it is the default in Makefile and VS projects.
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -DZSTD_MULTITHREAD")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build/cmake"
    OPTIONS
        -DZSTD_BUILD_SHARED=${ZSTD_BUILD_SHARED}
        -DZSTD_BUILD_STATIC=${ZSTD_BUILD_STATIC}
        -DZSTD_LEGACY_SUPPORT=1
        -DZSTD_BUILD_PROGRAMS=0
        -DZSTD_BUILD_TESTS=0
        -DZSTD_BUILD_CONTRIB=0
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d) # this is against the maintainer guidelines. 
        # Removing it probably requires a vcpkg-cmake-wrapper.cmake to correct downstreams FindZSTD.cmake

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zstd)

# This enables find_package(ZSTD) and find_package(zstd) to find zstd on Linux(case sensitive filesystems)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstdConfig.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstd-config.cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstdConfigVersion.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstd-config-version.cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(static_suffix "_static")
else()
    set(static_suffix "")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzstd.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzstd.pc" "-lzstd" "-lzstd${static_suffix}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc" "-lzstd" "-lzstd${static_suffix}d")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(HEADER zdict.h zstd.h zstd_errors.h)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${HEADER}" "defined(ZSTD_DLL_IMPORT) && (ZSTD_DLL_IMPORT==1)" "1" )
    endforeach()
endif()

file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "ZSTD is dual licensed - see LICENSE and COPYING files\n")
