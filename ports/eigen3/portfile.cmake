include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eigenteam/eigen-git-mirror
    REF 167613fde929de8dafbbb6bf7fe4385c2ecd5b39
    SHA512 b932ca771dff21c4a0df6ff5b71e85df76b586265ce0127eb390dd2975f330a32cba8bc705edacc88f5efa972c7f34b94c3739c8b56d7319c0feaed2c666b14f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
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
