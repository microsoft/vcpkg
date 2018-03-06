include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shogun-toolbox/shogun
    REF shogun_6.1.3
    SHA512 11aeed456b13720099ca820ab9742c90ce4af2dc049602a425f8c44d2fa155327c7f1d3af2ec840666f600a91e75902d914ffe784d76ed35810da4f3a5815673
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    	-DBUILD_META_EXAMPLES=OFF
    	-DBUILD_EXAMPLES=OFF
    	-DUSE_SVMLIGHT=OFF
    	-DENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shogun)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/shogun)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shogun/COPYING ${CURRENT_PACKAGES_DIR}/share/shogun/copyright)
