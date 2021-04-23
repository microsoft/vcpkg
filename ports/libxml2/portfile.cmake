set(LIBXML2_VER 2.9.10)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF v${LIBXML2_VER}
    SHA512 de8d7c6c90f9d0441747deec320c4887faee1fd8aff9289115caf7ce51ab73b6e2c4628ae7eaad4a33a64561d23a92fd5e8a5afa7fa74183bdcd9a7b06bc67f1
    HEAD_REF master
    PATCHES
        RemoveIncludeFromWindowsRcFile.patch
        fix-version-define.patch
)

# Official configure files
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libxml2-config.cmake.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    tools LIBXML2_WITH_PROGRAMS
)

if (VCPKG_TARGET_IS_UWP)
    message(WARNING "Feature network couldn't be enabled on UWP, disable http and ftp automatically.")
    set(ENABLE_NETWORK 0)
else()
    set(ENABLE_NETWORK 1)
endif()

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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libxml2-${LIBXML2_VER})

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libxml-2.0.pc" "-lxml2" "-llibxml2")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxml-2.0.pc" "-lxml2" "-llibxml2")
endif ()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xmlcatalog xmllint AUTO_CLEAN)
endif()

if (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/xml2-config ${CURRENT_PACKAGES_DIR}/share/${PORT}/xml2-config)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)