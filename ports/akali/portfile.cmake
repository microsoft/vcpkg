vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/akali
    REF 07d855dd2da7cddb374646465799734e48e0adb2
    SHA512 4298bc97c5b99494f517e46a86a30dcd61e9d4cfdfa5dbb4c17957c8e866de8ed5b41b2f9a17261f96fc3c7b25fbac2003af4ad8ca675d3f59ce6176e1112220
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/akali)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/akali)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/akali)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/akali RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
