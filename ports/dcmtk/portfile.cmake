include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("DCMTK only supports static library linkage")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DCMTK/dcmtk
    REF DCMTK-3.6.3
    SHA512 5863d0c05f046075b998bced7c8c71bf8e969dd366f26d48cdf26012ea744ae4a22784a5c3c12e12b0f188e997c93a6890ef0c3c336865ea93f13c45f70b258d
    HEAD_REF master
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/dcmtk.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDCMTK_WITH_DOXYGEN=OFF
        -DDCMTK_WITH_ZLIB=OFF
        -DDCMTK_WITH_OPENSSL=OFF
        -DDCMTK_WITH_PNG=OFF
        -DDCMTK_WITH_TIFF=OFF
        -DDCMTK_WITH_XML=OFF
        -DDCMTK_WITH_ICONV=OFF
        -DDCMTK_FORCE_FPIC_ON_UNIX=ON
        -DDCMTK_OVERWRITE_WIN32_COMPILER_FLAGS=OFF
        -DDCMTK_ENABLE_BUILTIN_DICTIONARY=ON
        -DDCMTK_ENABLE_PRIVATE_TAGS=ON
        -DBUILD_APPS=OFF
        -DDCMTK_ENABLE_CXX11=ON
        -DCMAKE_DEBUG_POSTFIX="d"
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/dcmtk RENAME copyright)
