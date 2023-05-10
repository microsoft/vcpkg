SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/blas")

# Make sure BLAS can be found
vcpkg_list(SET CMAKE_IGNORE_PATH)
if(NOT DEFINED ENV{MKLROOT})
    list(APPEND CMAKE_IGNORE_PATH "${CURRENT_INSTALLED_DIR}/lib/intel64")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS
        "-DCMAKE_PREFIX_PATH=${CURRENT_PACKAGES_DIR}"
        "-DCMAKE_IGNORE_PATH=${CMAKE_IGNORE_PATH}"
)
