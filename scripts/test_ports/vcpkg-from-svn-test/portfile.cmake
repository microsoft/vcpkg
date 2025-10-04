set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

macro(windows_to_mingw_path NativePath ResultPath)
  string(REGEX REPLACE "^([a-zA-Z]):[\\/]" "/\\1/" _tmp "${NativePath}")
  string(REPLACE "\\" "/" ${ResultPath} "${_tmp}")
endmacro()

set(svn_test_repo "${CURRENT_BUILDTREES_DIR}/test-svn-repo")
set(svn_test_repo2 "${CURRENT_BUILDTREES_DIR}/test-svn-repo2")
set(svn_test_repo_checkout "${CURRENT_BUILDTREES_DIR}/svn-repo")

windows_to_mingw_path("${svn_test_repo}" svn_test_repo_sanitized)
windows_to_mingw_path("${svn_test_repo2}" svn_test_repo2_sanitized)
windows_to_mingw_path("${svn_test_repo_checkout}" svn_test_repo_checkout_sanitized)

set(svn_remote "file:///${svn_test_repo_sanitized}")
set(svn_remote2 "file:///${svn_test_repo2_sanitized}")

vcpkg_find_acquire_program(GIT)
vcpkg_list(SET git_config
    -c core.autocrlf=false
    -c user.email=vcpkg@example.com
    -c user.name=vcpkg
    -c init.defaultBranch=main
)
vcpkg_list(SET git ${GIT} ${git_config})

vcpkg_execute_in_download_mode(
    COMMAND ${GIT} svn --version
    OUTPUT_VARIABLE svn_version_output
    ERROR_VARIABLE svn_version_error
    RESULT_VARIABLE svn_version_result
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
)

if(svn_version_result)
    message(NOTICE "git-svn is required for test to continue. The test ${PORT} was skipped!")
    return()
endif()

message(STATUS "Setup of test svn repository")

macro(remove_recursive_if_exists Path)
    if(EXISTS "${Path}")
        file(REMOVE_RECURSE "${Path}")
    endif()
endmacro()

remove_recursive_if_exists("${svn_test_repo}")
remove_recursive_if_exists("${svn_test_repo_checkout}")
file(MAKE_DIRECTORY "${svn_test_repo}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/empty-test-repo/" DESTINATION "${svn_test_repo}/")

vcpkg_execute_required_process(
    COMMAND ${git} svn clone --stdlayout ${svn_remote} "${svn_test_repo_checkout_sanitized}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "git-svn-checkout-local"
)

file(WRITE "${svn_test_repo_checkout}/README.txt" "first commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "README.txt"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-add.1"
)

vcpkg_execute_required_process(
    COMMAND ${git} commit -m "First Commit"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-commit.1"
)

set(ref_1 "2")

vcpkg_execute_required_process(
    COMMAND ${git} svn dcommit 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-dcommit.1"
)
# Tag this commit, this will increase ref
vcpkg_execute_required_process(
    COMMAND ${git} svn branch -t -m "Create tag" 1.0.0
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-tag.1"
)

vcpkg_execute_required_process(
    COMMAND ${git} svn dcommit 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-dcommit.2"
)

set(ref_tag "3")

vcpkg_execute_required_process(
    COMMAND ${git} checkout main 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-checkout.1"
)

vcpkg_execute_required_process(
    COMMAND ${git} switch main
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-switch.1"
)

file(WRITE "${svn_test_repo_checkout}/README.txt" "second commit")
vcpkg_execute_required_process(
    COMMAND ${git} commit -a -m "second commit"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-commit.2"
)

vcpkg_execute_required_process(
    COMMAND ${git} svn dcommit 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-dcommit.3"
)

set(ref_2 "4")

vcpkg_execute_required_process(
    COMMAND ${git} svn branch -m "Create develop branch" develop 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-branch.1"
)
vcpkg_execute_required_process(
    COMMAND ${git} checkout origin/develop 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-checkout-branch.1"
)

file(WRITE "${svn_test_repo_checkout}/README.txt" "develop branch")
vcpkg_execute_required_process(
    COMMAND ${git} commit -a -m "develop branch"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-commit.3"
)

vcpkg_execute_required_process(
    COMMAND ${git} svn dcommit 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "git-svn-dcommit.4"
)

set(ref_branch "6")

message(STATUS "Testing regular mode")
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF "${ref_1}"
)

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the first commit. Contents were:
${contents}
")
endif()


message(STATUS "Testing regular mode that happens to match HEAD")
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF "${ref_2}"
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "second commit")
    message(FATAL_ERROR "Failed to checkout the second commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing head mode with trunk")
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF "${ref_2}"
    FETCH_REF "trunk"
    HEAD_REF "trunk"
)

if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${ref_2}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${ref_2}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "second commit")
    message(FATAL_ERROR "Failed to checkout the second commit. Contents were:
${contents}
")
endif()
set(VCPKG_USE_HEAD_VERSION OFF)

message(STATUS "Testing regular mode with branch")
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF ${ref_branch}
    FETCH_REF "develop"
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "develop branch")
    message(FATAL_ERROR "Failed to checkout the branch commit. Contents were:
${contents}
")
endif()
message(STATUS "Testing regular mode with tag")
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF ${ref_tag}
    FETCH_REF "tags/1.0.0"
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the tag commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing head mode with branch")
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    HEAD_REF develop
)

if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${ref_branch}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${ref_2}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "develop branch")
    message(FATAL_ERROR "Failed to checkout the branch commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing head mode with tag")
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    HEAD_REF tags/1.0.0
)

if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${ref_tag}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${ref_2}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the branch commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing head mode + no HEAD_REF -> just uses REF")
set(VCPKG_USE_HEAD_VERSION ON)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}"
    STDLAYOUT
    REF ${ref_1}
)

if(NOT "${VCPKG_HEAD_VERSION}" STREQUAL "${ref_tag}")
    message(FATAL_ERROR "Failed to checkout the right HEAD commit.
    Expected: ${ref_1}
    Actual  : ${VCPKG_HEAD_VERSION}
")
endif()

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the branch commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing normal mode with a different url.")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${svn_test_repo}
            ${svn_test_repo2}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "copy-repository"
)

set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote2}"
    STDLAYOUT
    REF "${ref_1}"
)

file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the first commit. Contents were:
${contents}
")
endif()
