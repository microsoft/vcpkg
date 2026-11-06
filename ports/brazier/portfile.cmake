vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF de7737277a28499b6eb911227ad1996c35d318bc
    SHA512 895ba754e2ab740d6e38b3ccd710eec3873c8c4c86154dd01d92fc996a6046579ff6d6f2e528b170cff841eae8e64b9bd6670d8f9a32c95ef12c1c5a2c2e89f2
    HEAD_REF master
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/brazierConfig.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/brazier")

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON BRAZIER_VERSION GET "${_vcpkg_json}" "version")

file(READ "${CMAKE_CURRENT_LIST_DIR}/brazierConfigVersion.cmake.in" _ver_template)
string(REPLACE "@VERSION@" "${BRAZIER_VERSION}" _ver_content "${_ver_template}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/brazier/brazierConfigVersion.cmake"
     "${_ver_content}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")
