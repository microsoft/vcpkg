# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF v2.15.5
    SHA512 a4972901db8ed89302e6ba15fd104543b5e36a41bc83daf8f6f6fb29ce73b0dbd8596de801d099a33df413b26eec1b3a6f4f0d669936ecc6d25f88d783468a59
)
set(BOOST_ROOT ${CURRENT_INSTALLED_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
