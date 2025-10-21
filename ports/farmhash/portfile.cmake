#Requires a compiler which understands '__builtin_unreachable': 
vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_download_distfile(WIN_PR_PATCH
    URLS "https://github.com/google/farmhash/pull/40.diff?full_index=1"
    FILENAME farmhash-pr-40.patch
    SHA512 a479450e3e2c4810ef67bb0704c30c2779e12a8768524f179235fae8687d064e62ee225b4b167a30fda59c39de40587629813804f452841badf308e1e76607a7
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/farmhash
    REF 0d859a811870d10f53a594927d0d0b97573ad06d
    SHA512 7bc14931e488464c1cedbc17551fb90a8cec494d0e0860db9df8efff09000fd8d91e01060dd5c5149b1104ac4ac8bf7eb57e5b156b05ef42636938edad1518f1
    HEAD_REF master
    PATCHES ${WIN_PR_PATCH}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND (VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) AND NOT ENV{CXX_FLAGS})
    set(ENV{CXXFLAGS} "-maes -msse4.2")
endif()
file(REMOVE_RECURSE "${SOURCE_PATH}/configure")
vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_install_make()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/share" # eliminate unused files
)
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/farmhashConfig.cmake" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
