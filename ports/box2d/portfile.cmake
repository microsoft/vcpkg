
# Get output directory
set(PROJECT_ARCH_BITS "x64")
if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(PROJECT_ARCH_BITS "x32")
elseif(TRIPLET_SYSTEM_ARCH MATCHES "arm")
    message(FATAL_ERROR "ARM not supported")
endif(TRIPLET_SYSTEM_ARCH MATCHES "x86")

include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/erincatto/Box2D.git")
set(GIT_REF "374664b")

if(NOT EXISTS "${DOWNLOADS}/box2d.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/box2d.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif(NOT EXISTS "${DOWNLOADS}/box2d.git")
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/box2d.git
        LOGNAME worktree
    )
endif(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

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
