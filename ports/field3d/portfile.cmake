vcpkg_fail_port_install(ON_TARGET "Windows" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imageworks/Field3D
    REF 0cf75ad982917e0919f59e5cb3d483517d06d7da
    SHA512 e6f137013dd7b64b51b2ec3cc3ed8f4dbfadb85858946f08393653d78136cf8f93ae124716db11358e325c5e64ba04802afd4b89ca36ad65a14dd3db17f3072c
    HEAD_REF master
    PATCHES
        0001_fix_build_errors.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/FindILMBase.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
