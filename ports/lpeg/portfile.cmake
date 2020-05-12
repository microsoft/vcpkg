#cmake-only scripts
include(vcpkg_common_functions)

set(LPEG_VER 1.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-${LPEG_VER}.tar.gz"
    FILENAME "lpeg-${LPEG_VER}.tar.gz"
    SHA512 7b43fbee7eff443000986684bc56bba6d2796a31cf860740746c70e155bdea1b62a46b93f97e2747e3ef0f63e965148778ac2985d0f2d83e1e37ec4ebbabf4aa
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/lpeg.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Remove debug share
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/lpeg.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/lpeg RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
