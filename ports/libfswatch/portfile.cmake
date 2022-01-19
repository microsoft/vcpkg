vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/fswatch
    REF             ca7c03d8094d8ff99cdba60798c4c5a4b805b856
    SHA512          41b70ccf20b4daffb43af6bcaef147f055e983363fb8c43926575fe935471948140ab2a920cc0b8ea97e55c41091a838ef29874f337e0e4c9de82b2307ecbe2d
    HEAD_REF        multi-os-ci
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_FSWATCH=OFF"
        "-DBUILD_TESTS=ON"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/libfswatch"
     RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
