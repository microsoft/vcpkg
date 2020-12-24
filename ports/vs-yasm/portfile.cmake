set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ShiftMediaProject/VSYASM
    REF deb50d9f18e8461538468339d508cdf240e64897 #v0.5
    SHA512 04627546020d33e5ea91f74b09c5ce3b817dce5f6ae4548c3b4148daa82fbd837c81675ac8730d3ca1cdf91fefa8bb23eec76d1bcd02c03dda1203d0c261178d
    HEAD_REF master
    PATCHES
        fix_paths.patch
)

set(_files yasm.props yasm.targets yasm.xml)
foreach(_file ${_files})
    file(INSTALL "${SOURCE_PATH}/${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endforeach()

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
