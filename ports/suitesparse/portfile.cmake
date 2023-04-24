vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF 71e330ca2bc0a2f12f416c461d23dbca21db4d8f
    SHA512 06c75927c924cfd5511b07504e826714f504586243d6f3449d67408a33f3ecea824a7f2de7a165171791b9bda4fc09c0d7093125970895c2ed8d4d37ca1d5a3d
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH SUITESPARSEWIN_SOURCE_PATH
    REPO jlblancoc/suitesparse-metis-for-windows
    REF c11e8dd7a2ef7d0d93af4c16f75374dd8ca029e2
    SHA512 fbd2a9e6f7df47eeb5d890c7b286bef7fc4c8bcb22783ce800723bacaf2cfe902177828ce5b9e1c2ed9fb5c54591c5fb046a8667e7d354d452a4baac693e47d2
    HEAD_REF master
    PATCHES
        build_fixes.patch
)

# Copy suitesparse sources.
message(STATUS "Overwriting SuiteSparseWin source files with SuiteSparse source files...")
# Should probably remove everything but CMakeLists.txt files?
file(GLOB SUITESPARSE_SOURCE_FILES "${SOURCE_PATH}/*")
foreach(SOURCE_FILE ${SUITESPARSE_SOURCE_FILES})
    file(COPY "${SOURCE_FILE}" DESTINATION "${SUITESPARSEWIN_SOURCE_PATH}/SuiteSparse")
endforeach()
message(STATUS "Overwriting SuiteSparseWin source files with SuiteSparse source files... done")
message(STATUS "Removing integrated lapack and metis lib...")
file(REMOVE_RECURSE "${SUITESPARSEWIN_SOURCE_PATH}/lapack_windows")
file(REMOVE_RECURSE "${SUITESPARSEWIN_SOURCE_PATH}/SuiteSparse/metis-5.1.0")
message(STATUS "Removing integrated lapack and metis lib... done")

vcpkg_cmake_configure(
    SOURCE_PATH "${SUITESPARSEWIN_SOURCE_PATH}"
    OPTIONS
        -DBUILD_METIS=OFF
        -DUSE_VCPKG_METIS=ON
        "-DMETIS_SOURCE_DIR=${CURRENT_INSTALLED_DIR}"
     OPTIONS_DEBUG
        "-DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug"
     OPTIONS_RELEASE
        "-DSUITESPARSE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/suitesparse)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SUITESPARSEWIN_SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright_suitesparse-metis-for-windows)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/cxsparse")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper_cxsparse.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cxsparse" RENAME vcpkg-cmake-wrapper.cmake)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindCXSparse.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cxsparse")
