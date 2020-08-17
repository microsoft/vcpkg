vcpkg_fail_port_install(
    ON_ARCH "arm"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GamedevFramework/gf
    HEAD_REF master
    REF v0.17.4
    SHA512 b35e0fef3c9dc397ec43132dcd6ca87f78217c55d72fc1117b1f530d568ad3537a0f682e285840471faa4e06eb7f396b784da767e83686519d0694b198a86379
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
