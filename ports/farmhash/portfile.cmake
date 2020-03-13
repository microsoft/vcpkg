vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO google/farmhash
        REF 0d859a811870d10f53a594927d0d0b97573ad06d
        SHA512 7bc14931e488464c1cedbc17551fb90a8cec494d0e0860db9df8efff09000fd8d91e01060dd5c5149b1104ac4ac8bf7eb57e5b156b05ef42636938edad1518f1
        HEAD_REF master
)

vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
)

vcpkg_install_make()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/farmhashConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})