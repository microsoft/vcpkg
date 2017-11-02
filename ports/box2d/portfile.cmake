
# Get output directory
set(PROJECT_ARCH_BITS "x64")
if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(PROJECT_ARCH_BITS "x32")
elseif(TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM not supported")
endif(TRIPLET_SYSTEM_ARCH MATCHES "x86")

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "Box2d only supports dynamic CRT linkage")
endif()

include(vcpkg_common_functions)

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF 374664b2a4ce2e7c24fbad6e1ed34bebcc9ab6bc
    SHA512 39074bab01b36104aa685bfe39b40eb903d9dfb54cc3ba8098125db5291f55a8a9e578fc59563b2e8743abbbb26f419be7ae1524e235e7bd759257f99ff96bda
    HEAD_REF master
)

# Put the licence and readme files where vcpkg expects it
message(STATUS "Packaging license")
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/box2d)
file(COPY ${SOURCE_PATH}/Box2D/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/box2d)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/box2d/License.txt ${CURRENT_PACKAGES_DIR}/share/box2d/copyright)
message(STATUS "Packaging license done")

# Building:
set(OUTPUTS_PATH "${SOURCE_PATH}/Box2D/Build/vs2015/bin/${PROJECT_ARCH_BITS}")

vcpkg_build_msbuild(PROJECT_PATH ${SOURCE_PATH}/Box2D/Build/vs2015/Box2D.vcxproj)

message(STATUS "Packaging ${TARGET_TRIPLET}-Release lib")
file(
    INSTALL ${OUTPUTS_PATH}/Release/
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    FILES_MATCHING PATTERN "*.lib"
)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Box2D.lib ${CURRENT_PACKAGES_DIR}/lib/box2d.lib)
message(STATUS "Packaging ${TARGET_TRIPLET}-Release lib done")

message(STATUS "Packaging ${TARGET_TRIPLET}-Debug lib")
file(
    INSTALL ${OUTPUTS_PATH}/Debug/
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    FILES_MATCHING PATTERN "*.lib"
)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Box2D.lib ${CURRENT_PACKAGES_DIR}/debug/lib/box2d.lib)
message(STATUS "Packaging ${TARGET_TRIPLET}-Debug lib done")

message(STATUS "Packaging headers")
file(
    COPY ${SOURCE_PATH}/Box2D/Box2D
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    PATTERN "*.h"
)
message(STATUS "Packaging headers done")

vcpkg_copy_pdbs()
