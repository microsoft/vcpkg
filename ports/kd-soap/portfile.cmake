include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF kdsoap-1.8.0
    SHA512 e118f2083887d1b5d613d793e87ec23a570a8a749ef7f4de65582998b735979b4c389a939169a893d735bdf110dc84a4cca5ee38146e4009be715902f6323bb9
    HEAD_REF master
    PATCHES kd-soap.patch
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
