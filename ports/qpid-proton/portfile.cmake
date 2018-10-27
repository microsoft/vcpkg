if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("qpid-proton does not support static linkage. Building dynamically.")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "qpid-proton does not support static CRT linkage.")
endif()

include(vcpkg_common_functions)

# Use this throughout rather than literal string
set(QPID_PROTON_VERSION 0.24.0)
vcpkg_find_acquire_program(PYTHON2)

# Go grab the code. Set SHA512 to 1 to get correct sha from download
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/qpid-proton
    REF ${QPID_PROTON_VERSION}
    SHA512 a22154d5ea96330e22245a54233101256f02d10ee814a7f0f4b654e56128615acee0cfc0387cbec9b877dd20cc23a5b1635aa9e1d1b60a4b9aa985e449dcb62e
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
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt
            ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Remove extraneous unrequired-for-vcpkg files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
