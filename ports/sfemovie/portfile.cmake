include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Yalir/sfemovie
        REF master
        SHA512 1
        HEAD_REF master
		PATCHES sfemovie.patch install.patch
)

vcpkg_configure_cmake(
     SOURCE_PATH ${SOURCE_PATH}
     PREFER_NINJA
)

 vcpkg_install_cmake()
# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shiva)


 file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sfemovie) 
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sfemovie/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/sfemovie/copyright)
 
