#header-only library
# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF 0.9.8.4 
    SHA512 ff0e0651a695caebe9235882d14e09546d52b3cdf66cca8e2078f15b02a3fca4e47bd97d2807aa329f76aa633af3b4999501bd4d0b22ad44b00558d4917f39ed
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/glm")

# changes target search path
file(READ ${CURRENT_PACKAGES_DIR}/share/glm/glmTargets.cmake GLM_TARGETS)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
               "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)" GLM_TARGETS ${GLM_TARGETS})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glm/glmTargets.cmake "${GLM_TARGETS}")

file(READ ${CURRENT_PACKAGES_DIR}/share/glm/glmConfig.cmake GLM_CONFIG)
string(REPLACE "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../../\" ABSOLUTE)"
               "get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)" GLM_CONFIG ${GLM_CONFIG})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/glm/glmConfig.cmake "${GLM_CONFIG}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glm/copying.txt ${CURRENT_PACKAGES_DIR}/share/glm/copyright)
