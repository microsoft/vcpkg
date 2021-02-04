# Note: Should be maintained simultaneously with opencolorio-tools!
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_BUILD_SHARED OFF)
    set(_BUILD_STATIC ON)
else()
    set(_BUILD_SHARED ON)
    set(_BUILD_STATIC OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/OpenColorIO
    REF ebdec4111f449bea995d01ecd9693b7e704498fe # v1.1.1
    SHA512 b93796541f8b086f137eaebeef102e29a4aabac6dba5b1696c9ab23d62af39b233ca52ce97b04ea432d85ae0a1fe186939c52aab0cd2c4cd5d2775ac5c021eef
    HEAD_REF master
    PATCHES
        0001-lcms-dependency-search.patch
        0002-msvc-cpluscplus.patch
        0003-osx-self-assign-field.patch
        0004-yaml-dependency-search.patch
        0005-tinyxml-dependency-search.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON3_PATH})

# TODO(theblackunknown) build additional targets based on feature

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOCIO_BUILD_APPS=OFF
        -DOCIO_BUILD_SHARED:BOOL=${_BUILD_SHARED}
        -DOCIO_BUILD_STATIC:BOOL=${_BUILD_STATIC}
        -DOCIO_BUILD_TRUELIGHT:BOOL=OFF
        -DOCIO_BUILD_NUKE:BOOL=OFF
        -DOCIO_BUILD_DOCS:BOOL=OFF
        -DOCIO_BUILD_TESTS:BOOL=OFF
        -DOCIO_BUILD_PYGLUE:BOOL=OFF
        -DOCIO_BUILD_JNIGLUE:BOOL=OFF
        -DOCIO_STATIC_JNIGLUE:BOOL=OFF
        -DUSE_EXTERNAL_TINYXML:BOOL=ON
        -DUSE_EXTERNAL_YAML:BOOL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/OpenColorIOConfig.cmake" _contents)
string(REPLACE
    [=[get_filename_component(OpenColorIO_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)]=]
    [=[get_filename_component(OpenColorIO_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(OpenColorIO_DIR "${OpenColorIO_DIR}" PATH)
get_filename_component(OpenColorIO_DIR "${OpenColorIO_DIR}" PATH)]=]
    _contents
    "${_contents}")
string(REPLACE "/cmake/OpenColorIO.cmake" "/share/opencolorio/OpenColorIO.cmake" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/opencolorio/OpenColorIOConfig.cmake" "${_contents}")

# Clean redundant files
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/debug/OpenColorIOConfig.cmake
    ${CURRENT_PACKAGES_DIR}/OpenColorIOConfig.cmake
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)