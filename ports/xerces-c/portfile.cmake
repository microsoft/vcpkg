vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF "v${VERSION}"
    SHA512 0da61e000e871c045fb6e546cabba244eb6470a7a972c1d1b817ba5ce91c0d1d12dfb3ff1479d8b57ab06c49deefd1c16c36dc2541055e41a1cdb15dbd769fcf
    HEAD_REF master
    PATCHES
        disable-tests.patch
        remove-dll-export-macro.patch
)

set(DISABLE_ICU ON)
if("icu" IN_LIST FEATURES)
    set(DISABLE_ICU OFF)
endif()
if ("xmlch-wchar" IN_LIST FEATURES)
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

vcpkg_fixup_pkgconfig()
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(pc_file_release "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xerces-c.pc")
    set(pc_file_debug "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xerces-c.pc")
    if(EXISTS "${pc_file_release}")
        vcpkg_replace_string("${pc_file_release}" "-lxerces-c" "-lxerces-c_3")
    endif()
    if(EXISTS "${pc_file_debug}")
        vcpkg_replace_string("${pc_file_debug}" "-lxerces-c" "-lxerces-c_3D")
    endif()
endif()