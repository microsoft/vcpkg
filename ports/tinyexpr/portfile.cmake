vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO codeplea/tinyexpr
    REF ffb0d41b13e5f8d318db95feb071c220c134fe70
    SHA512 fe4975f8b444a50d7ba8135450a42007a81f1545eebd7775f92307b87b72bc9abee4591e56ddeb76ec9e5aa41f0852ba98c99881d671f47a58caca8bd1ca9999
    HEAD_REF master
    PATCHES
        fix-issue-34.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
