vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF v3.2.2
    SHA512 e4b2d3499fb4d1d1bcaf991ee858f352112683084b9cc7855c0e52e7fc8cc982a8e3cd548fa30718af6a6dee40e460d82ffcd3480a50f7e7516b462b2c2080c6
    HEAD_REF master
    PATCHES
        disable-tests.patch
        remove-dll-export-macro.patch
        no-symlinks-in-static-build.patch
)

set(DISABLE_ICU ON)
if("icu" IN_LIST FEATURES)
    set(DISABLE_ICU OFF)
endif()
if ("xmlch_wchar" IN_LIST FEATURES)
    set(XMLCHTYPE -Dxmlch-type=wchar_t)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_TESTS=ON
        -DDISABLE_DOC=ON
        -DDISABLE_SAMPLES=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ICU=${DISABLE_ICU}
        -DCMAKE_DISABLE_FIND_PACKAGE_CURL=ON
        ${XMLCHTYPE}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/xercesc)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/XercesC TARGET_PATH share/xercesc)
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfigInternal.cmake _contents)
string(REPLACE
    "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents
    "${_contents}"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfigInternal.cmake "${_contents}")

file(READ ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfig.cmake _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfig.cmake "include(CMakeFindDependencyMacro)\nfind_dependency(Threads)\n${_contents}")

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/xercesc
    @ONLY
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
