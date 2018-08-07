include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 3b4a3d57f3a0231cfb70ad649099c3aed0499555
    SHA512 3ff7ece9fafd595d5016d0ad1942dfc1747610cd93e505512179307f7abba2e16d1c830712f9b4a04278ad8bcdc182dc883bcdabad340f2d08264d34d8f08f92
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
