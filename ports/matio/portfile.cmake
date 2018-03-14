include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF v1.5.12
    SHA512 3bf6d2bf6460531dd2a740813bca3f3da6347b9fadb39803257f11bcceeaa7cf6657921c9ca9c8db02bf2020d5adf2ecf544b2455aa0ca897c0644493b1902a4
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/matio RENAME copyright)

vcpkg_copy_pdbs()
