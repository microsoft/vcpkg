include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO biotrump/SOIL
     # repo from 2016; matches http://web.archive.org/web/20200104042737/http://www.lonesock.net/files/soil.zip (which is now down) via git diff -w
    REF d8c9aa735c80f0de9f732235a910990b1838d010
    SHA512 7c655195235e2a44a897e944dbc923411f117013623de6af8f4df6a189c3666cc0472dfc1d467af060fddb140b1ea0b68970f8cbec9a3d955df3a5b404795be6
    HEAD_REF master
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfig.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfigVersion.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
