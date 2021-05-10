if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF b7580396701eda11491f8060e37d49d9e17bb5ad
        SHA512 789a15bebcfe5ebbf231814c5e5ac652e21bc02aa45e201fa8767adeae708e7ed201b44535513599f79ab215afb7273ba49c35f9806a9787dda074819728b9bc
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.9.4
        SHA512 9645fc8e76d28105ae03d55e8e53dcd3f82aaa003b46ac5b303682946036286bfaa64a90f2151eb8094f23d1715a9b3b1e745fe4c125d6d2ef39442dcfe005da
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
