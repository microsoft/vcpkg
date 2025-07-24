vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF 93d0e8397b444217c8ed4e034a1d64de112c6246
    SHA512 18d6413500a8a1eba0611dbecb792963115242ba2ed295fadd93b2c74b49fe53c15d9be417c73b6bd8fc046568236b655606e423ca1dc126e3dfa74d857c80d6
    HEAD_REF c89-vcpkg
    PATCHES
        fix-name-conflict.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_TESTING=ON
        "-DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include/${PORT}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zip" PACKAGE_NAME "${PORT}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/kubazip/zip/zip.h" "#ifndef ZIP_SHARED" "#if 0")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
