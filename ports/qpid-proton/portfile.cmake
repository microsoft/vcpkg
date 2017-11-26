include(vcpkg_common_functions)

# Use this throughout rather than literal string
set(QPID_PROTON_VERSION 0.18.1)
vcpkg_find_acquire_program(PYTHON2)

# Go grab the code. Set SHA512 to 1 to get correct sha from download
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF ${QPID_PROTON_VERSION}
    SHA512 92cbd7f534e8b180fb72888999af2735541663c70dde1e4e1382f39c5057920df0fb72527db23008823d69a7ddac335217f16270c0bbdb4dfe26733feddf94cc
    HEAD_REF next
)

# Run cmake configure step
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
                      OPTIONS
                          -DPYTHON_EXECUTABLE=${PYTHON2})

# Run cmake install step
vcpkg_install_cmake()

# Copy across any pdbs generated
vcpkg_copy_pdbs()

# Rename share subdirectory
file(RENAME ${CURRENT_PACKAGES_DIR}/share/proton-${QPID_PROTON_VERSION}
            ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Vcpkg expects file with name "copyright"
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE
            ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Remove extraneous unrequired-for-vcpkg files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
