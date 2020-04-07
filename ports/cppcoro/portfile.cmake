#
# the repo is fork of https://github.com/lewissbaker/cppcoro to support CMake / VcPkg
#
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/cppcoro
    REF             2020.04
    SHA512          bd60a97911f4ee6c692e99817e9691cc5063be816c3a09a6100bc8f590f5b1e7b13a372a87e1710993b1bc177bbd99d779b2ebf16a367851b256e396bfd038da
    HEAD_REF        master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=False
)
vcpkg_install_cmake()

file(INSTALL     ${SOURCE_PATH}/LICENSE.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME      copyright
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
