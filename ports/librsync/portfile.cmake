vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF d1938c387e86ab5bbf7cb2e84244229c5bbd5ebf # commit 2020-06-04
    SHA512 2afb844f20e6d74d8874b2022db5c4c4befa09f2cfcf5360ffcdd4fd3ef56270d3ab8de6be76fc68f8648d871c28f3bbe15e4f6f417c0776b542f86ac6a910cb
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_RDIFF:BOOL=OFF 
        -DENABLE_COMPRESSION:BOOL=OFF
        -DENABLE_TRACE:BOOL=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/rsync.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rsync.dll ${CURRENT_PACKAGES_DIR}/bin/rsync.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll ${CURRENT_PACKAGES_DIR}/debug/bin/rsync.dll)
endif()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)

vcpkg_copy_pdbs()