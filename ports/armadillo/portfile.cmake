include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conradsnicta/armadillo-code
    REF 57f4c21280c4fad813062177477c88f26bb4d20d
    SHA512 1fcbbd59e99a57bf6dd939c1d01f9e84e19dd036e713511f6dd31bd583676db65cd33939cb7f6eea7ac6c0b9c24e7e8ea601c23c01f4e09b4bb8fa58822f361a
    HEAD_REF X.100.x
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDETECT_HDF5=false
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/Armadillo/CMake)

#file(COPY ${CMAKE_CURRENT_LIST_DIR}/ArmadilloConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/Armadillo)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt  DESTINATION ${CURRENT_PACKAGES_DIR}/share/Armadillo RENAME copyright)
