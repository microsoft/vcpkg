set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(svn_test_repo "${CURRENT_BUILDTREES_DIR}/test-svn-repo")
set(svn_test_repo_checkout "${CURRENT_BUILDTREES_DIR}/svn-repo")
set(svn_test_repo_layout "${CURRENT_BUILDTREES_DIR}/svn-repo-layout")

set(svn_remote "file:///${svn_test_repo}")
set(svn_remote_trunk "file:///${svn_test_repo}/trunk")

vcpkg_find_acquire_program(SVN)
vcpkg_find_acquire_program(SVNADMIN)

vcpkg_list(SET svnadmin ${SVNADMIN})
vcpkg_list(SET svn ${SVN})

message(STATUS "Creating test svn repository")
file(REMOVE_RECURSE "${svn_test_repo}")
file(REMOVE_RECURSE "${svn_test_repo_checkout}")
file(REMOVE_RECURSE "${svn_test_repo_layout}")
vcpkg_execute_required_process(
    COMMAND ${svnadmin} create "test-svn-repo"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "svn-init"
)
# Create default repo folders

message(STATUS "Creating default layout")
file(MAKE_DIRECTORY "${svn_test_repo_layout}/trunk" "${svn_test_repo_layout}/tags" "${svn_test_repo_layout}/branches")
vcpkg_execute_required_process(
    COMMAND ${svn} import -m "Add default layout" ${svn_test_repo_layout} ${svn_remote}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "svn-add-folders"
)

vcpkg_execute_required_process(
    COMMAND ${svn} checkout ${svn_remote_trunk} ${svn_test_repo_checkout}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "svn-checkout-local"
)

file(WRITE "${svn_test_repo_checkout}/README.txt" "first commit")
vcpkg_execute_required_process(
    COMMAND ${svn} add "README.txt"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-add.1"
)

vcpkg_execute_required_process(
    COMMAND ${svn} commit -m "first commit"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-commit.1"
)

set(ref_1 "2")

# Tag this commit, this will increase ref
vcpkg_execute_required_process(
    COMMAND ${svn} copy -m "tag first commit" . "${svn_remote}/tags/1.0.0"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-copy.1"
)

set(ref_tag "3")

file(WRITE "${svn_test_repo_checkout}/README.txt" "second commit")
vcpkg_execute_required_process(
    COMMAND ${svn} commit -m "second commit"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-commit.2"
)

set(ref_2 "4")

vcpkg_execute_required_process(
    COMMAND ${svn} copy -m "branch second commit" . "${svn_remote}/branches/develop"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-copy.2"
)

vcpkg_execute_required_process(
    COMMAND ${svn} switch --force ^/branches/develop 
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-switch.1"
)

file(WRITE "${svn_test_repo_checkout}/README.txt" "develop branch")
vcpkg_execute_required_process(
    COMMAND ${svn} commit -m "develop branch"
    WORKING_DIRECTORY "${svn_test_repo_checkout}"
    LOGNAME "svn-commit.3"
)

set(ref_branch "6")


message(STATUS "Testing regular mode")
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_svn(
    OUT_SOURCE_PATH source_path
    URL "${svn_remote}/trunk"
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
    URL "${svn_remote}/trunk"
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
    HEAD_REF "trunk"
)

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
    URL "${svn_remote}/branches/develop"
    REF ${ref_branch}
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
    URL "${svn_remote}/tags/1.0.0"
    REF ${ref_tag}
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
    HEAD_REF /branches/develop
)
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
    HEAD_REF /tags/1.0.0
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "first commit")
    message(FATAL_ERROR "Failed to checkout the branch commit. Contents were:
${contents}
")
endif()