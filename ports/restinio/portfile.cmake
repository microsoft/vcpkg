vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 02507d2c18732045b69f9b6710767de6972f0179 # v.0.6.3
    SHA512 fc83fc3d378dd4b69900a9fe2f7ba1582c51db42d9171f2f0ca1a248afead7dadcda4aed0e3dcd529bbb6d3faf6d2fb30eeb0971776ffeadbb5d7ef4055985dd
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
