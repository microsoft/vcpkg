include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(FATAL_ERROR "Dynamic building not supported")
endif()

# Get architecture params
set(PROJECT_ARCH "x64")
if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(PROJECT_ARCH "Win32")
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
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/box2d.git
        LOGNAME worktree
    )
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# Put the licence and readme files where vcpkg expects it
message(STATUS "Packaging license")
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/box2d)
file(COPY ${SOURCE_PATH}/Box2D/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/box2d)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/box2d/License.txt ${CURRENT_PACKAGES_DIR}/share/box2d/copyright)
message(STATUS "Packaging license done")

# Building:
foreach(TYPE "Release" "Debug")
    message(STATUS "Building ${TARGET_TRIPLET}-${TYPE}")
    vcpkg_execute_required_process(
        COMMAND "devenv.exe"
            "./Box2D/Build/vs2015/Box2D.sln"
            /Build "${TYPE}|${PROJECT_ARCH}"
            /Project "./Box2D/Build/vs2015/Box2D.vcxproj"
            /Projectconfig "${TYPE}|${PROJECT_ARCH}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-${TYPE}
    )
    message(STATUS "Building ${TARGET_TRIPLET}-${TYPE} done")

    message(STATUS "Packaging ${TARGET_TRIPLET}-${TYPE} lib")
    set(TARGET_PATH "${CURRENT_PACKAGES_DIR}/lib")
    if(TYPE STREQUAL Debug)
        set(TARGET_PATH "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif(TYPE STREQUAL Debug)

    file(
        INSTALL ${SOURCE_PATH}/Box2D/Build/vs2015/bin/${PROJECT_ARCH}/${TYPE}/
        DESTINATION ${TARGET_PATH}
        FILES_MATCHING PATTERN "*.lib"
    )
    file(RENAME ${TARGET_PATH}/Box2D.lib ${TARGET_PATH}/box2d.lib)
    message(STATUS "Packaging ${TARGET_TRIPLET}-${TYPE} lib done")
endforeach()

message(STATUS "Packaging headers")
file(
    COPY ${SOURCE_PATH}/Box2D/Box2D
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    PATTERN "*.h"
)
message(STATUS "Packaging headers done")

vcpkg_copy_pdbs()
