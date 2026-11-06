vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF "${VERSION}"
    SHA512 6614314b96efe983647f3bd21870165e9c26ecf555bea0916f993f93221a491d997a16e847b34bc6db097599667917e71f570f591899e650a510a82297f7b6ad
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" EFSW_BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EFSW_BUILD_STATIC_LIB)

# efsw CMakeLists sets up two targets "efsw" and "efsw-static" where the former is static or shared depending on BUILD_SHARED_LIBS and the latter is always static
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DVERBOSE=OFF
        -DBUILD_TEST_APP=OFF
        -DBUILD_SHARED_LIBS=${EFSW_BUILD_SHARED_LIB}
        -DBUILD_STATIC_LIBS=0
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/efsw)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/src/efsw/String.hpp"
)
