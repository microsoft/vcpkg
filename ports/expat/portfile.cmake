string(REPLACE "." "_" REF "R_${VERSION}")

vcpkg_download_distfile(CVE-2024-28757
    URLS "https://github.com/libexpat/libexpat/commit/5026213864ba1a11ef03ba2e8111af8654e9404d.diff?full_index=1"
    FILENAME libexpat-CVE-2024-28757.patch
    SHA512 0d697b26116c89dd72d946ad04eb8f02ace970a435bbd67ba31841a13309d6a43e2cfa2dea8f6e7d53b478a508f7642dd9ff8c8f367d0d0205e982041f62f849
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF "${REF}"
    SHA512 cf6c64fc0ca55dd172ca8a6ca10d1fb2c915d0f941b0068f42cb90488022dea73e04119c49a1bd4ab9a5d425ddc132ae5f22260ff6d2e25204637a1169e7bd4f
    HEAD_REF master
    PATCHES
        ${CVE-2024-28757}
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" EXPAT_LINKAGE)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" EXPAT_CRT_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/expat"
    OPTIONS
        -DEXPAT_BUILD_EXAMPLES=OFF
        -DEXPAT_BUILD_TESTS=OFF
        -DEXPAT_BUILD_TOOLS=OFF
        -DEXPAT_BUILD_DOCS=OFF
        -DEXPAT_SHARED_LIBS=${EXPAT_LINKAGE}
        -DEXPAT_MSVC_STATIC_CRT=${EXPAT_CRT_LINKAGE}
        -DEXPAT_BUILD_PKGCONFIG=ON
    MAYBE_UNUSED_VARIABLES
        EXPAT_MSVC_STATIC_CRT
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/expat-${VERSION}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/expat_external.h" "! defined(XML_STATIC)" "0")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/expat/COPYING")
