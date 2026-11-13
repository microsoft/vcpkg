if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libkml/libkml
    REF  "${VERSION}"
    SHA512 aa48158103d3af764bf98c1fb4cf3e1356b9cc6c8e79d80b96850916f0a8ccb1dac3a46427735dd0bf20647daa047d10e722ac3da2a214d4c1559bf6d5d7c853
    HEAD_REF master
    PATCHES
        fix-cmake-min-version.patch
        patch_empty_literal_on_vc.patch
        fix-mingw.patch
        fix-minizip.patch
        add-target-include-directories.patch
        fix-cxx20-intrusive-ptr.patch # libkml/libkml#284
        fix-pkgconfig.patch
)

# The customized ZIP reader retains Info-ZIP-derived decryption code.
vcpkg_download_distfile(INFOZIP_ARCHIVE
    URLS "https://downloads.sourceforge.net/infozip/unzip60.tar.gz"
    FILENAME "infozip-unzip60.tar.gz"
    SHA512 0694e403ebc57b37218e00ec1a406cae5cc9c5b52b6798e0d4590840b6cdbf9ddc0d9471f67af783e960f8fa2e620394d51384257dca23d06bcd90224a80ce5d
)
vcpkg_extract_source_archive(INFOZIP_SOURCE_PATH
    ARCHIVE "${INFOZIP_ARCHIVE}"
)

file(REMOVE
    "${SOURCE_PATH}/cmake/External_boost.cmake"
    "${SOURCE_PATH}/cmake/External_expat.cmake"
    "${SOURCE_PATH}/cmake/External_minizip.cmake"
    "${SOURCE_PATH}/cmake/External_uriparser.cmake"
    "${SOURCE_PATH}/cmake/External_zlib.cmake"
    "${SOURCE_PATH}/src/kml/base/contrib/minizip/ioapi.h"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0022=NEW
        # libkml uses std::unary_function that was deprecated in C++11 and removed in C++17
        # compilers are starting to ship C++17 as the defualt so explicitly set C++11
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libkml)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/src/kml/base/contrib/minizip/unzip.h"
    "${SOURCE_PATH}/src/kml/base/contrib/minizip/iomem_simple.c"
    "${CURRENT_INSTALLED_DIR}/include/minizip/crypt.h"
    "${INFOZIP_SOURCE_PATH}/LICENSE"
)
