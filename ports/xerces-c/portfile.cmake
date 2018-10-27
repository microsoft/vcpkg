include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF Xerces-C_3_2_2
    SHA512 66f60fe9194376ac0ca99d13ea5bce23ada86e0261dde30686c21ceb5499e754dab8eb0a98adadd83522bda62709377715501f6dac49763e3a686f9171cc63ea
    HEAD_REF trunk
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/xercesc)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/XercesC TARGET_PATH share/xercesc)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB release_exe "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    file(GLOB debug_exe "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    if(release_exe OR debug_exe)
        file(REMOVE ${release_exe} ${debug_exe})
    endif()
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfigInternal.cmake _contents)
string(REPLACE
    "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents
    "${_contents}"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/xercesc/XercesCConfigInternal.cmake "${_contents}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xerces-c)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xerces-c/LICENSE ${CURRENT_PACKAGES_DIR}/share/xerces-c/copyright)

vcpkg_copy_pdbs()
