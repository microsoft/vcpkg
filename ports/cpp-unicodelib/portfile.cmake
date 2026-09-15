vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-unicodelib
    REF 222005f50ef08e8562088b91fc7b912446bffc95 # committed on 2026-09-05
    SHA512 adace76ba0a7b75f3d1f4db78b86b939737a7088d9d628df925420ff9a78f79c95766a997f77269a34076dd0fe61d4431b465435381ce0caf6c9a937f477e5f2
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/unicodelib.h"
    "${SOURCE_PATH}/unicodelib_encodings.h"
    "${SOURCE_PATH}/unicodelib_names.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
