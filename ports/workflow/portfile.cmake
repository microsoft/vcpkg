if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.9.7-win
        SHA512 c23b8c1910c4ca5d57fa732e3084f56e17fdfead5561a8eab7be469d8f6081d830555365b2cf74e27956ffa88a6fb284dbde4654b23b130da9fbb4eb404686bd
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF v0.9.7
        SHA512 4866d9cfe2d9ba30f2f7866819ee8f425b91082d7f86994c1194a6b4406e8ee99e22ce6b0bafeb22c5f098f7da30029fb6b12895c2ac45810d33c28d4bfad006
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
