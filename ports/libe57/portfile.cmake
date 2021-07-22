set(VERSION 1.1.312)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/E57RefImpl_src-${VERSION})

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO e57-3d-imgfmt
    FILENAME "E57RefImpl_src-${VERSION}.zip"
    SHA512 c729cc3094131f115ddf9b8c24a9420c4ab9d16a4343acfefb42f997f4bf25247cd5563126271df2af95f103093b7f6b360dbade52c9e66ec39dd2f06e041eb7
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
