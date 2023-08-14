vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppIrlba
    REF d23a4c12b95563907cf8ca7584b7bb6625ff886b
    SHA512 1fdc9552ab00c7c541b4cd34326075f257a30ebcf73dd633dd088b20a20cb0dd704be0c3295ab96d5a573cb1a783c19f34a3e5d860c719e413c098fd9df4cb3a
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIRLBA_FETCH_EXTERN=OFF
        -DIRLBA_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_irlba
    CONFIG_PATH lib/cmake/ltla_irlba
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
