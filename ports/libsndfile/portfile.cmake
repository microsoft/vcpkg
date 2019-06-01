include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikd/libsndfile
    REF 6830c421899e32f8d413a903a21a9b6cf384d369
    SHA512 b13c5d7bc27218eff8a8c4ce89a964b4920b1d3946e4843e60be965d77ec205845750a82bf654a7c2c772bf3a24f6ff5706881b24ff12115f2525c8134b6d0b9
    HEAD_REF master
    PATCHES
        uwp-createfile-getfilesize.patch
        uwp-createfile-getfilesize-addendum.patch
        fix-install-path.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" CRT_LIB_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

option(BUILD_EXECUTABLES "Build sndfile tools and install to folder tools" OFF)

if("external-libs" IN_LIST FEATURES)
    set(SNDFILE_WITHOUT_EXTERNAL_LIBS OFF)
else()
    set(SNDFILE_WITHOUT_EXTERNAL_LIBS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_REGTEST=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_BOW_DOCS=OFF
        -DENABLE_STATIC_RUNTIME=${CRT_LIB_STATIC}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -DDISABLE_EXTERNAL_LIBS=${SNDFILE_WITHOUT_EXTERNAL_LIBS}
    OPTIONS_RELEASE
        -DBUILD_PROGRAMS=${BUILD_EXECUTABLES}
    OPTIONS_DEBUG
        -DBUILD_PROGRAMS=0
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

# Fix applied for 6830c421899e32f8d413a903a21a9b6cf384d369
file(READ "${CURRENT_PACKAGES_DIR}/share/libsndfile/LibSndFileTargets.cmake" _contents)
string(REPLACE "INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/lib\"" "INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/include\"" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libsndfile/LibSndFileTargets.cmake" "${_contents}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
    set(SHARED_LIB_SUFFIX ".dll")
else()
    set(EXECUTABLE_SUFFIX)
    set(SHARED_LIB_SUFFIX)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libsndfile-1${SHARED_LIB_SUFFIX})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/libnsdfile-1${SHARED_LIB_SUFFIX})
endif()

if(BUILD_EXECUTABLES)
    file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/*${EXECUTABLE_SUFFIX})
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${TOOLS})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif(BUILD_EXECUTABLES)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
