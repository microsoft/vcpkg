vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO digint/tinyfsm
    REF v${VERSION}
    SHA512 1a471ba9a62658211353fcebc5f824e14506870b70af34af324ff720c957457625d819caa2701088cfe48cc055780def2e88ebcc10744f44bb6870e3fc2129a3
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-tinyfsm)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
