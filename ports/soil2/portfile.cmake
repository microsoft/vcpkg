vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/soil2
    REF 7dc42acee2302780c1e100bf864aa2bdb2221a2b #release-1.11
    SHA512 13f1716a3766cb4fa8d5b90eae5f3795ed3c86fc4463ca1cd68f4fa6b7fd96c24ec5098673c1d7253c94bdd491854b9359f8ccb8bd5b5640eeff3605f52e17a5
    HEAD_REF master
)

file(
    COPY 
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    ${CMAKE_CURRENT_LIST_DIR}/soil2Config.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/soil2ConfigVersion.cmake.in
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
