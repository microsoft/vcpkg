set(VERSION 1.1.332)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/E57RefImpl_src-${VERSION})

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO e57-3d-imgfmt
    FILENAME "E57RefImpl_src-${VERSION}.zip"
    SHA512 86adb88cff32d72905e923b1205d609a2bce2eabd78995c59a7957395b233766a5ce31481db08977117abc1a70bbed90d2ce0cdb9897704a8c63d992e91a3907
    PATCHES 
        "0001_cmake.patch"
        "0002_replace_tr1_with_cpp11.patch"
        "0003_fix_osx_support.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/libe57)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES e57fields e57unpack e57validate e57xmldump las2e57
    AUTO_CLEAN
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
