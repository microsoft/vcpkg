vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO digint/tinyfsm
    REF v${VERSION}
    SHA512 1a471ba9a62658211353fcebc5f824e14506870b70af34af324ff720c957457625d819caa2701088cfe48cc055780def2e88ebcc10744f44bb6870e3fc2129a3
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/tinyfsm.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
