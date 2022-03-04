if(VCPKG_USE_HEAD_VERSION)
    vcpkg_from_gitlab(
        GITLAB_URL "https://gitlab.xiph.org"
        OUT_SOURCE_PATH SOURCE_PATH
        REPO xiph/speexdsp
        HEAD_REF master
    )
else()
    # Since the github repo is out-dated, use official download URL for release builds to reduce traffic to the Gitlab host
    vcpkg_download_distfile(ARCHIVE
        URLS "http://downloads.xiph.org/releases/speex/speexdsp-1.2.0.tar.gz"
        FILENAME "speexdsp-1.2.0.tar.gz"
        SHA512 e357cd5377415ea66c862302c7cf8bf6a10063cacd903f0846478975b87974cf5bdf00e2c6759d8f4f453c4c869cf284e9dc948a84a83d7b2ab96bd5405c05ec
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
        REF "1.2.0"
        PATCHES
            jitter_ctl.patch
    )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(USE_SSE OFF)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(USE_SSE ON)
endif()
set(USE_NEON OFF)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(USE_NEON ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DUSE_SSE=${USE_SSE}
    -DUSE_NEON=${USE_NEON}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
