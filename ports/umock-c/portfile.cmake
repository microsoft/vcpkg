vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/umock-c
        REF 87d2214384c886a1e2406ac0756a0b3786add8da
        SHA512 230b6c79a8346727bbc124d1aefaa14da8ecd82b2a56d68b3d2511b8efa5931872da440137a5d266835ba8c5193b83b4bc5ee85abb5242d07904a0706727926c
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/umock-c
        REF 504193e65d1c2f6eb50c15357167600a296df7ff
        SHA512 68d5d986314dbd46d20de2a9b9454154c11675c25d1b5a5b1cfecdd0c0945d9dc68d0348ec1dbb00b5d1a6a1f0356121ba561d7c8fffb97ab37864edade5a85b
        HEAD_REF master
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Drun_unittests=OFF
        -Drun_int_tests=OFF
        -Duse_installed_dependencies=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/umock_c)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/readme.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
