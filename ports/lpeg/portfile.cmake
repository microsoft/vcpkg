set(LPEG_VER 1.0.2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-${LPEG_VER}.tar.gz"
    FILENAME "lpeg-${LPEG_VER}.tar.gz"
    SHA512 110527ddf9f8e5e8a80ef0ae8847c8ba8cd2597dba3bfe2865cba9af60daafbb885f21e74231952f5ab793d021e050b482066a821c6954d52090a5eae77e9814
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/lpeg.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Remove debug share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/lpeg.html" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
