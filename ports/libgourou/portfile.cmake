vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             fe5af58cd2d90dcdffcfac380a761cbc2c73379a
    SHA512          eda7ac209ee1e9ac523a585ad95c927e73774be5c5f62ddafc6785329dffd3ee3489fc97ee334ac61cc6a0a7456893041dc146301231550dec8cb5bb7f35554d
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cmake/License.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
