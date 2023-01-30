vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF bf71a834948186f4097caa076cd2663c69a10e1e #v0.9.9.8
    SHA512 65e0fa6056f2996687740e593a583d372c482ad59b160598903d8f53a2d99b2c1d72e0503cf3200d28d78e0223133cfb22394aafd494dfd92974d99042f39021
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Put the license file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)