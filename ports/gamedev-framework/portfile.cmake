if (VCPKG_HOST_IS_LINUX)
    message(WARNING "gamedev-framework requires gcc version 8.3 or later.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GamedevFramework/gf
    HEAD_REF master
    REF v1.2.0
    SHA512 2043d0b015af7127887df44a9e2e035000c93c20a713d7297736fb05e46923684e330c7a541a115c110ea8737f0ddbfb0c0ef13498102732cfb2a4b243fd22cd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGF_USE_EMBEDDED_LIBS=OFF
        -DGF_BUILD_GAMES=OFF
        -DGF_BUILD_EXAMPLES=OFF
        -DGF_BUILD_DOCUMENTATION=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_UNITY_BUILD=ON
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_RELEASE -DGF_DEBUG=OFF
    OPTIONS_DEBUG -DGF_DEBUG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME gf
    CONFIG_PATH lib/cmake/gf
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/bin/gf_info.exe"
    "${CURRENT_PACKAGES_DIR}/bin/gf_info.exe"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
