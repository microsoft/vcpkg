include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/Microsoft/cppwinrt")
set(GIT_REF "9e01842")

if(NOT EXISTS "${DOWNLOADS}/cppwinrt.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/cppwinrt.git
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
        WORKING_DIRECTORY ${DOWNLOADS}/cppwinrt.git
        LOGNAME worktree
    )
endif()
message(STATUS "Adding worktree done")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

set(HEADER_PATH ${SOURCE_PATH}/10.0.14393.0/winrt/)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${HEADER_PATH}/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt)
