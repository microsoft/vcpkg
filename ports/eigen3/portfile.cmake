#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/eigen-eigen-5a0156e40feb)
vcpkg_download_distfile(ARCHIVE
    URLS "http://bitbucket.org/eigen/eigen/get/3.3.4.tar.bz2"
    FILENAME "eigen-3.3.4.tar.bz2"
    SHA512 d67a3fd8f7ce811af65fc1d43ec347dadf9c643a49135f7e455fc303773bad09e80a125282c7dfca7a1993b79e1f66576ac92418119fbb0fa50c1a581b957c0d
)
vcpkg_extract_source_archive(${ARCHIVE})

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

file(GLOB INCLUDES ${CURRENT_PACKAGES_DIR}/include/eigen3/*)
# Copy the eigen header files to conventional location for user-wide MSBuild integration
file(COPY ${INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/eigen3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/eigen3/COPYING.README ${CURRENT_PACKAGES_DIR}/share/eigen3/copyright)
