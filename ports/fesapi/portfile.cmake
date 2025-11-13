vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO F2I-Consulting/fesapi
    REF "v${VERSION}"
    SHA512 83823e3ce3acfc1428f5d0fa8fd96dd49befce3e2f8827b4894403b215f9ef117bcd55af981c33fc019cc5bfeac76c62265fc052285307fbabe2630d91bba14d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Wno-dev
        -Wno-deprecated
        -DWITH_EXAMPLE:BOOL=OFF
        -DWITH_TEST:BOOL=OFF
        -DWITH_DOTNET_WRAPPING:BOOL=OFF
        -DWITH_JAVA_WRAPPING:BOOL=OFF
        -DWITH_PYTHON_WRAPPING:BOOL=OFF
        -DWITH_RESQML2_2:BOOL=ON
        "-DHDF5_PREFER_PARALLEL=${HDF5_WITH_PARALLEL}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/FesapiCpp"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
