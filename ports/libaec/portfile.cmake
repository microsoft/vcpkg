vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.dkrz.de
    REPO k202009/libaec
    REF v1.1.3
    SHA512 6f317d08ad7d003bc6664da147321eb87c924978f32bd28780a8ebf015e251019046b0cb16b78e776cd1957a7701215667f64686efb8e5c6bae7c08528cede56
    PATCHES
        cmake-config.patch
        static-shared.patch)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" AEC_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" AEC_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAEC_BUILD_SHARED=${AEC_BUILD_SHARED}
        -DAEC_BUILD_STATIC=${AEC_BUILD_STATIC}
        -DBUILD_TESTING=OFF)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "cmake")
