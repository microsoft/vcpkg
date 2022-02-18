vcpkg_find_acquire_program(FLEX)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO finos/OpenMAMA
    REF c4925ee103add1a51c1d27be45b46d97af347f36 # https://github.com/finos/OpenMAMA/releases/tag/OpenMAMA-6.3.1-release
    SHA512 e2773d082dd28e073fe81223fc113b1a5db7cd0d95e150e9f3f02c8c9483b9219b5d10682a125dd792c3a7877e15b90fd908084a4c89af4ec8d8c0389c282de2
    HEAD_REF next
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPROTON_ROOT=${CURRENT_INSTALLED_DIR}
        -DAPR_ROOT=${CURRENT_INSTALLED_DIR}
        -DINSTALL_RUNTIME_DEPENDENCIES=OFF
        -DFLEX_EXECUTABLE=${FLEX}
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTTOOLS=OFF
)

vcpkg_install_cmake()

# Copy across license files and copyright
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/LICENSE-3RD-PARTY.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Clean up LICENSE file - vcpkg doesn't expect it to be there
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE.MD ${CURRENT_PACKAGES_DIR}/debug/LICENSE.MD)

# Temporary workaround until upstream project puts dll in right place
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libmamaplugindqstrategymd.dll")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libmamaplugindqstrategymd.dll ${CURRENT_PACKAGES_DIR}/bin/libmamaplugindqstrategymd.dll)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libmamaplugindqstrategymd.dll")
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmamaplugindqstrategymd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libmamaplugindqstrategymd.dll)
endif()

# Vcpkg does not expect include files to be in the debug directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

foreach(OPENMAMA_ROOT_HEADER destroyhandle.h platform.h list.h lookup2.h property.h timers.h wlock.h windows)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/include/${OPENMAMA_ROOT_HEADER}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/include/${OPENMAMA_ROOT_HEADER}" "${CURRENT_PACKAGES_DIR}/include/wombat/${OPENMAMA_ROOT_HEADER}")
    endif()
endforeach()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mama/integration/transport.h" "list.h" "wombat/list.h")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mama/integration/types.h" "list.h" "wombat/list.h")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mama/integration/mama.h" "property.h" "wombat/property.h")

vcpkg_copy_pdbs()
