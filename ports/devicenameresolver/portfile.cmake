include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrexodia/devicenameresolver
    REF 0850d88fa6a759d79b3c859933870d9aa602aa79
    SHA512 9161411d3c8c17f49f5ff9482a007a6608872c948ef856aa7076a45c246e8d777e4cd6b54169d9c1b9e99e7b383436e1a084e168fafff1ca5f2b28260bac1452
    HEAD_REF master
    PATCHES add-string-headfile.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/DeviceNameResolver.h _contents)
string(REPLACE "__declspec(dllexport)" "" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/DeviceNameResolver.h "${_contents}")

file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/devicenameresolver RENAME copyright)
