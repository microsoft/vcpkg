if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.10.5-win
        SHA512 4299b2c8bc545676b5437086c666a7b0955524aae758a8753719439697b3dd4d5b46c0a8eba9dba80c0daa9ee9c4188e46fd085f0d2f68f61b33fad1f903c4c2
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.10.5
        SHA512 696e82a1f6a7e6c339fbabb7b1f98ffe40f5f5ee7e77f4c947c0c1532817409e7a61f020c6238a32acd9eb3e06cf3e522e6d67beda32d5bbb08ea1080c20277d
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
