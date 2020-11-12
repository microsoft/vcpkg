vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/zstd
    REF b706286adbba780006a47ef92df0ad7a785666b6 # v1.4.5
    SHA512 1be43e8cc1dad9dd59036f86a7dd579b8fcbf16b3ebae62f38aa0397f45ab0eab2e97e924cede40428fa9125a2e5e567694bb04a0c9ec0c4275a79cd2ef8eb11
    HEAD_REF dev
    PATCHES
      0002-crosscompile-windows.patch
      fix_assert.patch
      install_pkgpc.patch
      install_dll.patch
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
        -DCMAKE_DEBUG_POSTFIX=d) # this is against the maintainer guidelines. 
        # Removing it probably requires a vcpkg-cmake-wrapper.cmake to correct downstreams FindZSTD.cmake

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/zstd)

# This enables find_package(ZSTD) and find_package(zstd) to find zstd on Linux(case sensitive filesystems)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstdConfig.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstd-config.cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstdConfigVersion.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/zstd-configVersion.cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS)
    set(static_suffix "_static")
else()
    set(static_suffix )
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzstd.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzstd.pc" "-lzstd" "-lzstd${static_suffix}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc" "-lzstd" "-lzstd${static_suffix}d")
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


