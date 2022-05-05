if (VCPKG_HOST_IS_LINUX)
    message(WARNING "gamedev-framework requires gcc version 8.3 or later.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GamedevFramework/gf
    HEAD_REF master
    REF v0.20.0
    SHA512 57b0e87f8713268d7bd4e68fb65f57715af6617582e3ce342a10a66f2ebfeeacdd11e1df0abbd13a2d1d9e6222def94bcf7b522ef5411043668e4c6f0fea1dd7
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGF_VCPKG=ON
        -DGF_USE_EMBEDDED_LIBS=OFF
        -DGF_BUILD_GAMES=OFF
        -DGF_BUILD_EXAMPLES=OFF
        -DGF_BUILD_DOCUMENTATION=OFF
        -DGF_SINGLE_COMPILTATION_UNIT=ON
        -DBUILD_TESTING=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_RELEASE -DGF_DEBUG=OFF
    OPTIONS_DEBUG -DGF_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gf TARGET_PATH share/gf)
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
