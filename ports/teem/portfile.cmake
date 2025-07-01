vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO teem
    REF teem/1.11.0
    FILENAME "teem-1.11.0-src.tar.gz"
    SHA512 48b171a12db0f02dcfdaa87aa84464c651d661fa66201dc966b3cd5a8134c5bad1dad8987ffcc5d7c21c5d14c2eb617d48200410a1bda19008ef743c093ed575
)

# Apply patches to CMakeLists.txt
file(READ "${SOURCE_PATH}/CMakeLists.txt" _contents)

# Patch 1: Fix cmake version
string(REGEX REPLACE "cmake_minimum_required\\(VERSION [^\\)]+\\)" "cmake_minimum_required(VERSION 3.5)" _contents "${_contents}")

# Patch 2: remove EXPORT_LIBRARY_DEPENDENCIES (deprecated)
string(REGEX REPLACE "[ \t]*EXPORT_LIBRARY_DEPENDENCIES\\(.*\\)[ \t]*\r?\n" "" _contents "${_contents}")

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${_contents}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0077=NEW
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

# Install headers - teem has many headers (>12), use recursive glob as recommended
file(GLOB_RECURSE TEEM_HEADERS "${SOURCE_PATH}/src/*.h")
file(INSTALL ${TEEM_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/teem")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")