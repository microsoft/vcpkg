vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/zstd
    REF 10f0e6993f9d2f682da6d04aa2385b7d53cbb4ee # v1.4.4
    SHA512 869eb031d2f8cfd9d93502835a373f6f2ec39dc1f41dd5fd0463d3d442c153915987d00bc862ae66bded5c5697e1803a1e68491803bd1a7b358397e6eba58f64
    HEAD_REF dev
    PATCHES
      0001-export-zstd-config.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(ZSTD_STATIC 1)
    set(ZSTD_SHARED 0)
else()
    set(ZSTD_STATIC 0)
    set(ZSTD_SHARED 1)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # Enable multithreaded mode. CMake build doesn't provide a multithreaded
    # library target, but it is the default in Makefile and VS projects.
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -DZSTD_MULTITHREAD")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
    PREFER_NINJA
    OPTIONS
        -DZSTD_BUILD_SHARED=${ZSTD_SHARED}
        -DZSTD_BUILD_STATIC=${ZSTD_STATIC}
        -DZSTD_LEGACY_SUPPORT=1
        -DZSTD_BUILD_PROGRAMS=0
        -DZSTD_BUILD_TESTS=0
        -DZSTD_BUILD_CONTRIB=0
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/zstd)
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc" "-lzstd" "-lzstdd")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(HEADER zdict.h zstd.h zstd_errors.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(ZSTD_DLL_IMPORT) && (ZSTD_DLL_IMPORT==1)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "ZSTD is dual licensed - see LICENSE and COPYING files\n")
