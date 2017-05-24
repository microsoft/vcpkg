include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-0.4.0
    SHA512 cdd67a884528b088688d88c0627b9c13077215e234dd0772797f0bf63319ffc18533276d52110a37a0938d32f006023b74dce93e71d34b1e0003a86761cea6ee
    HEAD_REF master
)


set(CPP_SOURCE_PATH "${SOURCE_PATH}/cpp")

vcpkg_configure_cmake(
    SOURCE_PATH ${CPP_SOURCE_PATH}
    OPTIONS -DARROW_BUILD_TESTS=off
)


vcpkg_install_cmake()


file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrow RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
