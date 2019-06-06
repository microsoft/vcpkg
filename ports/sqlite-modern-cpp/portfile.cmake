# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminroosta/sqlite_modern_cpp
    REF e2248fae15c9e1a240f54d29a148e501f4ea2347
    SHA512 89f0ff234e5600ff5f51cb75934fa71d86b51f4e06f1cf4b7cffc0498985120877f8d58bbdbe02fc3cae212acc071a74cd5a3e44fdaf95c3aeaf79338f43fe9d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
