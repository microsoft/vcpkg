if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF eb0ef062cb4be64f3a152c740ed3d32e468c13fe
        SHA512 0dafe5637c78bfa8d415ef54d9ac91f6a6f525a5876ec54c321a533d05b010c1f94829107808348bbf2ffe58914547930abf2fc4b0b07c2990a55c44bb9fd2e3
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF 7689fdf2137e7d34f0a9f02eae0fc878acf483a2
        SHA512 721f7e1fa666031b552a58c9bd6525afb7113c23022016bfe0713053b535bdc972b6bc81baceb91929216fdc2ecb3150eb693b75fcf27ba991d5df11f88670cd
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/workflow RENAME copyright)
