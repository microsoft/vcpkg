vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF v2.9.10
    SHA512 de8d7c6c90f9d0441747deec320c4887faee1fd8aff9289115caf7ce51ab73b6e2c4628ae7eaad4a33a64561d23a92fd5e8a5afa7fa74183bdcd9a7b06bc67f1
    HEAD_REF master
    PATCHES
        RemoveIncludeFromWindowsRcFile.patch
        fix-version-define.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libxml2-config.cmake.cmake.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libxml2-config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools LIBXML2_WITH_PROGRAMS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DLIBXML2_WITH_LZMA=ON
        -DLIBXML2_WITH_ICONV=ON
        -DLIBXML2_WITH_ZLIB=ON
        -DLIBXML2_WITH_ICU=OFF
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_TESTS=OFF
    OPTIONS_RELEASE
        -DLIBXML2_WITH_DEBUG=OFF
        -DLIBXML2_WITH_MEM_DEBUG=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xmlcatalog xmllint AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)