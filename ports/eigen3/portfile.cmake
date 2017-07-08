#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-67e894c6cd8f)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.3.3.tar.bz2"
    FILENAME "eigen-3.3.3.tar.bz2"
    SHA512 bb5a8b761371e516f0a344a7c9f6e369e21c2907c8548227933ca6010fc607a66c8d6ff7c41b1aec3dea7d482ce8c2a09e38ae5c7a2c5b16bdd8007e7a81ecc3
)

vcpkg_extract_source_archive(${ARCHIVE})
# check if required file exists
if((NOT EXISTS ${SOURCE_PATH}/Eigen/CMakeLists.txt) OR (NOT EXISTS ${SOURCE_PATH}/unsupported/Eigen/CMakeLists.txt))
    message(STATUS "Missing CMakeLists.txt in cache, remove ${CURRENT_BUILDTREES_DIR} and try again.")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}) 
    vcpkg_extract_source_archive(${ARCHIVE})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE
        -DCMAKEPACKAGE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/eigen3
    OPTIONS_DEBUG
        -DCMAKEPACKAGE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/share/eigen3
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(READ "${CURRENT_PACKAGES_DIR}/share/eigen3/Eigen3Targets.cmake" EIGEN_TARGETS)
string(REPLACE "set(_IMPORT_PREFIX " "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}/../..\" ABSOLUTE) #" EIGEN_TARGETS "${EIGEN_TARGETS}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/eigen3/Eigen3Targets.cmake" "${EIGEN_TARGETS}")

# Copy the eigen header files to conventional location for user-wide MSBuild integration
file(COPY ${SOURCE_PATH}/Eigen DESTINATION ${CURRENT_PACKAGES_DIR}/include)
# and no need to leave CMakeLists.txt there
if(EXISTS ${CURRENT_PACKAGES_DIR}/include/Eigen/CMakeLists.txt)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Eigen/CMakeLists.txt)
endif()

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen3/copyright)
