include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdabah/distorm
    REF 16e6f43509616234b8478187c00569a65f15287c
    SHA512 2ecbacaaf07a07cf725adf25732807476fdaa1d3a44994a90c70ddbd2ec3db4c75c88b28188f8a48a0fb7b4fe79ae4f7b717cf72b3a0154232310ed56677a9a3
    HEAD_REF master
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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/distorm RENAME copyright)
