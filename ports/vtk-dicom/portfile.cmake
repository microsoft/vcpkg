vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dgobbi/vtk-dicom
    REF cfeceadfa68d2cc3172632bd1fd3ea8a38b6c609 # v0.8.16
    SHA512 0715ef91a1c585c9c819efd2bd6e2b73d3bff73a626b89f4877812fa6587e8379fb55ad99a376fb4d8dfa46c438e7a7052ba02ae61feb950cafb00c95df09b3f
    HEAD_REF master
)

if ("gdcm" IN_LIST FEATURES)
    set(USE_GDCM                      ON )
else()
    set(USE_GDCM                      OFF )
endif()

if(USE_GDCM)
    list(APPEND ADDITIONAL_OPTIONS
        -DUSE_GDCM=ON
        -DUSE_DCMTK=OFF
    )
endif()

set(python_ver "")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _py3_include_path "${CURRENT_HOST_INSTALLED_DIR}/include/python3*")
    string(REGEX MATCH "python3\\.([0-9]+)" _python_version_tmp ${_py3_include_path})
    set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_1}")
    set(python_ver "3.${PYTHON_VERSION_MINOR}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        "-DPython3_EXECUTABLE:PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${python_ver}${VCPKG_EXECUTABLE_SUFFIX}"
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dicom-0.8 PACKAGE_NAME dicom)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")

