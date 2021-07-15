if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF 268c873d20b5cddedcf1d36fe9c2af8338353a98
        SHA512 07b61657e34c1bce1f0fb8314e9d531e43dd9bf6004d6c67aaad9fcafa2073e05b835b85e87c82c26ca828edca08e9960a25578830657b9909b28bfa75cac6cc
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.9.5
        SHA512 3ce11817a7e7f5c168bfd8d4918d641e51c478b6e4137080530c6163c5c405b02edcf5fb675d6f582ae71450601a7c6e295d9664a69635d6925b0cf4c2283a16
        HEAD_REF master
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
