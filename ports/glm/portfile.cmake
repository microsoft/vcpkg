vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF bf71a834948186f4097caa076cd2663c69a10e1e #v0.9.9.8
    SHA512 226266c02af616a96fb19ee32cf3f98347daa43a4fde5d618d36b38709dce1280de126c542524d40725ecf70359edcc5b60660554c65ce246514501fb4c9c87c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Put the license file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)