include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF 857c6a1395ac0c1cf531addb5bfdfbb9052eaa6c
    SHA512 e118f2083887d1b5d613d793e87ec23a570a8a749ef7f4de65582998b735979b4c389a939169a893d735bdf110dc84a4cca5ee38146e4009be715902f6323bb9
    HEAD_REF master
)
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/8236bd7424-79789c62ed
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/kd-saop.patch"
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/kd-soap RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/kdwsdl2cpp.exe ${CURRENT_PACKAGES_DIR}/tools/kdwsdl2cpp.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kdwsdl2cpp.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
