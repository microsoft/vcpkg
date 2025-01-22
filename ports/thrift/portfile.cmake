# We currently insist on static only because:
# - Thrift doesn't yet support building as a DLL on Windows,
# - x64-linux only builds static anyway.
# From https://github.com/apache/thrift/blob/master/CHANGES.md
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/thrift
    REF "v${VERSION}"
    SHA512 5e4ee9870b30fe5ba484d39781c435716f7f3903793dc8aae96594ca813b1a5a73363b84719038ca8fa3ab8ef0a419a28410d936ff7b3bbadf36fc085a6883ae
    HEAD_REF master
    PATCHES
      "correct-paths.patch"
      "pc-suffix.patch"
)

if (VCPKG_TARGET_IS_OSX)
    message(WARNING "${PORT} requires bison version greater than 2.5,\n\
please use command \`brew install bison\` to install bison")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" shared_lib)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" static_lib)

# note we specify values for WITH_STATIC_LIB and WITH_SHARED_LIB because even though
# they're marked as deprecated, Thrift incorrectly hard-codes a value for BUILD_SHARED_LIBS.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_CHARSET_FLAG
    OPTIONS
        --trace-expand
        -DLIB_INSTALL_DIR:PATH=lib
        -DWITH_SHARED_LIB=${shared_lib}
        -DWITH_STATIC_LIB=${static_lib}
        -DBUILD_TESTING=OFF
        -DBUILD_JAVA=OFF
        -DWITH_C_GLIB=OFF
        -DBUILD_C_GLIB=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_GLIB=TRUE
        -DBUILD_PYTHON=OFF
        -DBUILD_CPP=ON
        -DWITH_CPP=ON
        -DWITH_ZLIB=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=TRUE
        -DWITH_LIBEVENT=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Libevent=TRUE
        -DWITH_OPENSSL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=TRUE
        -DBUILD_TUTORIALS=OFF
        -DFLEX_EXECUTABLE=${FLEX}
        -DWITH_QT5=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Gradle=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Java=TRUE
        -DBUILD_JAVASCRIPT=OFF
        -DBUILD_NODEJS=OFF
        -DBISON_EXECUTABLE=${BISON}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_GLIB
        CMAKE_DISABLE_FIND_PACKAGE_Gradle
        CMAKE_REQUIRE_FIND_PACKAGE_Libevent
        CMAKE_REQUIRE_FIND_PACKAGE_OpenSSL
        CMAKE_REQUIRE_FIND_PACKAGE_ZLIB
    
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Move CMake config files to the right place
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(GLOB COMPILER "${CURRENT_PACKAGES_DIR}/bin/thrift" "${CURRENT_PACKAGES_DIR}/bin/thrift.exe")
if(COMPILER)
    vcpkg_copy_tools(TOOL_NAMES thrift AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if ("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
