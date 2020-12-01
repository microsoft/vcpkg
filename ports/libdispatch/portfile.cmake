# This port needs to be updated at the same time as mongo-c-driver
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple/swift-corelibs-libdispatch
    REF swift-5.3.1-RELEASE
    SHA512 96ea68c41a3e5460efe612cdea2277f34df38ca2896d78c89fed0edd65376bcd2f543263775aeee2f8ac6922864bcae9dceaa49fcc8142a61a82ec69f7288057
    HEAD_REF master
)

vcpkg_find_acquire_program(CLANG)
vcpkg_find_acquire_program(CLANG++)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCMAKE_CXX_COMPILER=${CLANG++} -DCMAKE_C_COMPILER=${CLANG}
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
