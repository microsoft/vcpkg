vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanogui
    REF e9ec8a1a9861cf578d9c6e85a6420080aa715c03 #Commits on Sep 23, 2019
    SHA512 36c93bf977862ced2df4030211e2b83625e60a11fc9fdb6c1f2996bb234758331d3f41a7fbafd25a5bca0239ed9bac9c93446a4a7fac4c5e6d7943af2be3e14a
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNANOGUI_EIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
        -DEIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
