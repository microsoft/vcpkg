vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF "v${VERSION}"
    SHA512 ee9f07ebbeda537fbcf92a0e047bb72c5b9190b69b59e583f99b734f2fd145d1dca89013c1e2f8ff3b237345a6b1a3905524543644ddea4cf70a7b08962f22fb
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
