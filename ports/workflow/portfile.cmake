if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF "v${VERSION}-win"
        SHA512 c34518ca35f19ab5539ea82cc73ecbc9828413530cec8dbbe56b17517ec6b7b0326a29e5b343b950afe128829c8e23e75d19494e17f7be4fce9edb524c44ee56
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF "v${VERSION}"
        SHA512 25258e9dc161c5b30395caa3525a4ba5de5763cad5761cbdc8bb23d2468eb624ec49455a5c9ab628c219d7436f707da0138229c5fa82bcfccc24a485649acb56
        HEAD_REF master
    )
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CONFIGURE_OPTIONS "-DWORKFLOW_BUILD_STATIC_RUNTIME=ON")
else()
    set(CONFIGURE_OPTIONS "-DWORKFLOW_BUILD_STATIC_RUNTIME=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${CONFIGURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
