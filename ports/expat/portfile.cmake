string(REPLACE "." "_" REF "R_${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libexpat/libexpat
    REF "${REF}"
    SHA512 e60e6d6ae9d0115f41186f06f3854008054863f0b29a58d44142f5b30057a494337145d820b5e18270b8ca3e779e318a757fcc6bf64d6d204e5498df5eeb2195
    HEAD_REF master
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

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/expat_external.h" "defined(_MSC_VER)" "defined(_WIN32)")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/expat_external.h" "! defined(XML_STATIC)" "0")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/expat/COPYING")
