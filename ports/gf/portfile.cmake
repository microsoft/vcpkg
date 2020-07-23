vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GamedevFramework/gf
    HEAD_REF master
    REF v0.17.3
    SHA512 08ddd51cfc574bfa726ad776e32dcdde55640bf39d52219bad63222a6752721030e22cbbbf40eec56fe3d367942d958117be7c19c08952e2b07d8f4287d66f40
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGF_VCPKG=ON
        -DGF_USE_EMBEDDED_LIBS=OFF
        -DGF_BUILD_GAMES=OFF
        -DGF_BUILD_EXAMPLES=OFF
        -DGF_BUILD_TESTS=OFF
        -DGF_BUILD_DOCUMENTATION=OFF
        -DGF_SINGLE_COMPILTATION_UNIT=ON
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_RELEASE -DGF_DEBUG=OFF
    OPTIONS_DEBUG -DGF_DEBUG=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
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
