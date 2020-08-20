include(vcpkg_common_functions)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(SCONS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenMAMA/OpenMAMA
    REF abd490e1e1ffae4c643454102b57dc587a338737 # OpenMAMA-6.3.0-release
    SHA512 fd53c9a01075be414b13636b6f3bfbeeb43512d950625826fe133ba108972d71b170a20ce01175ca3e9ed263fd11e108f3902c6d404d43dd812e6a4748c032e1
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
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/openmama)
file(COPY ${SOURCE_PATH}/LICENSE.md
          ${SOURCE_PATH}/LICENSE-3RD-PARTY.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmama/)
file(COPY ${SOURCE_PATH}/LICENSE.md
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmama/copyright)

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

# Vcpkg does not like this header name and shouldn't be required anyway, so remove it
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/platform.h")

vcpkg_copy_pdbs()
