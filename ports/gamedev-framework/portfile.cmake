vcpkg_fail_port_install(
    ON_ARCH "arm"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GamedevFramework/gf
    HEAD_REF master
    REF v0.18.0
    SHA512 3a09939715d9e225df0e3ef1e7d1e74a7f84c1926657fc55be6c77e7869d0cb3e3f4bd9ee97c21e0920947d05837736a1cd2d6aa02aa09e6f294c8b6fdb6ece5
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
