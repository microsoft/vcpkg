include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effolkronium/random
    REF v1.2.0
    SHA512 92c5447196601d7dfb0320b517494f4e75cb55011c800cd2f18655cd4ab867672ad39830a3dbb3fc5f39a41c8ae03b6a6910f1eac4a2f131cffca896554be561
    HEAD_REF master
)

vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt "effolkronium_random" "effolkronium-random")
vcpkg_replace_string(${SOURCE_PATH}/cmake/config.cmake.in "effolkronium_random" "effolkronium-random")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DRandom_BuildTests=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/ TARGET_PATH /share/effolkronium-random)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/effolkronium-random RENAME copyright)
