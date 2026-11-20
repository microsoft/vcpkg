vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-pinyin
    REF  "v${VERSION}"
    SHA512 e406b11601455e761eaf060ef064fba6310de33224e0f13751bd8a2557e0693680a9cfc221251bba9cfadd1e8fa02e87c0e733790833956e8217ae183deda5ee
    HEAD_REF v2
    PATCHES
        fix-mac-static-build.patch # https://github.com/wolfgitpr/cpp-pinyin/pull/14
        vcpkg-dict-layout.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cpp-pinyin2" PACKAGE_NAME cpp-pinyin2)
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/cpp-pinyin2d.lib")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cpp-pinyin2.pc"
        "-lcpp-pinyin2" "-lcpp-pinyin2d")
endif()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpp-pinyin2/core/PinyinGlobal.h"
        "#ifdef CPP_PINYIN2_STATIC" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cpp-pinyin2/core/PinyinGlobal.h"
        "#ifdef CPP_PINYIN2_STATIC" "#if 0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
    "${SOURCE_PATH}/data/dialects/mandarin/License.txt"
    "${SOURCE_PATH}/data/dialects/cantonese/License.txt"
)
