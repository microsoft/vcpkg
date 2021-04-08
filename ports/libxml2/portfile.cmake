vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF v2.9.10
    SHA512 de8d7c6c90f9d0441747deec320c4887faee1fd8aff9289115caf7ce51ab73b6e2c4628ae7eaad4a33a64561d23a92fd5e8a5afa7fa74183bdcd9a7b06bc67f1
    HEAD_REF master
    PATCHES
        RemoveIncludeFromWindowsRcFile.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if (VCPKG_TARGET_IS_UWP)
    message(WARNING "Feature network couldn't be enabled on UWP, disable http and ftp automatically.")
    set(ENABLE_NETWORK 0)
else()
    set(ENABLE_NETWORK 1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}
        -DWITH_HTTP=${ENABLE_NETWORK}
        -DWITH_FTP=${ENABLE_NETWORK}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libxml-2.0.pc" "-lxml2" "-llibxml2")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libxml-2.0.pc" "-lxml2" "-llibxml2")
endif ()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)