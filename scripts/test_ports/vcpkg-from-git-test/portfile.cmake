set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(git_remote "${CURRENT_BUILDTREES_DIR}/test-git-repo")
file(REMOVE_RECURSE "${git_remote}")

vcpkg_find_acquire_program(GIT)
vcpkg_list(SET git_config
    -c core.autocrlf=false
    -c user.email=vcpkg@example.com
    -c user.name=vcpkg
)

vcpkg_list(SET git ${GIT} ${git_config})

vcpkg_execute_required_process(
    COMMAND ${git} init "${git_remote}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "git-init"
)
vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant true
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-config"
)
vcpkg_execute_required_process(
    COMMAND ${git} checkout -b main
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-new-branch"
)

file(WRITE "${git_remote}/README.txt" "first commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "${git_remote}/README.txt"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-add.1"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "first commit"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-commit.1"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_remote}"
)
if(NOT "${error_code}" EQUAL "0")
    message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
endif()
string(STRIP "${ref}" ref)

file(WRITE "${git_remote}/README.txt" "second commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "${git_remote}/README.txt"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-add.2"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "second commit"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-commit.2"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE head_ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_remote}"
)
if(NOT "${error_code}" EQUAL "0")
    message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
endif()
string(STRIP "${head_ref}" head_ref)

# test regular mode
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${ref}"
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the first commit. Contents were:
${contents}
")
endif()

# test regular mode with FETCH_REF
vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant false
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-config"
)
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${ref}"
    FETCH_REF main
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the first commit. Contents were:
${contents}
")
endif()

vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant true
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git-config"
)

# test head mode
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${ref}"
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "second commit")
    message(FATAL_ERROR "Failed to checkout the HEAD commit. Contents were:
${contents}
")
endif()
if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${head_ref}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${head_ref}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()

# test head mode + no HEAD_REF -> just uses REF
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${ref}"
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the regular commit. Contents were:
${contents}
")
endif()

# test new head ref
file(WRITE "${git_remote}/README.txt" "third commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "${git_remote}/README.txt"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git.7"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "second commit"
    WORKING_DIRECTORY "${git_remote}"
    LOGNAME "git.8"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE new_head_ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_remote}"
)
if(NOT "${error_code}" EQUAL "0")
    message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
endif()
string(STRIP "${new_head_ref}" new_head_ref)

set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${ref}"
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "third commit")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit. Contents were:
${contents}
")
endif()
if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${new_head_ref}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${new_head_ref}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()
