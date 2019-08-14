include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF Xerces-C_3_2_2
    SHA512 66f60fe9194376ac0ca99d13ea5bce23ada86e0261dde30686c21ceb5499e754dab8eb0a98adadd83522bda62709377715501f6dac49763e3a686f9171cc63ea
    HEAD_REF trunk
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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()
