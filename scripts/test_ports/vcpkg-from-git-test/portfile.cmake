set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(git_test_repo "${CURRENT_BUILDTREES_DIR}/test-git-repo")
file(REMOVE_RECURSE "${git_test_repo}")

# LFS expects a URL for a local repository
set(git_remote "file:///${git_test_repo}")

message(STATUS "Creating test git repository")
vcpkg_find_acquire_program(GIT)
vcpkg_list(SET git_config
    -c core.autocrlf=false
    -c user.email=vcpkg@example.com
    -c user.name=vcpkg
)

vcpkg_list(SET git ${GIT} ${git_config})

vcpkg_execute_required_process(
    COMMAND ${git} init "test-git-repo"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "git-init"
)
vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant true
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-config"
)
vcpkg_execute_required_process(
    COMMAND ${git} checkout -b main
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-new-branch"
)

file(WRITE "${git_test_repo}/README.txt" "first commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "README.txt"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-add.1"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "first commit"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-commit.1"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_test_repo}"
)
if(NOT "${error_code}" EQUAL "0")
    message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
endif()
string(STRIP "${ref}" ref)

file(WRITE "${git_test_repo}/README.txt" "second commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "README.txt"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-add.2"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "second commit"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-commit.2"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE head_ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_test_repo}"
)
if(NOT "${error_code}" EQUAL "0")
    message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
endif()
string(STRIP "${head_ref}" head_ref)

message(STATUS "Testing regular mode")
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

message(STATUS "Testing regular mode that happens to match HEAD")
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${head_ref}"
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "second commit")
    message(FATAL_ERROR "Failed to checkout the second commit. Contents were:
${contents}
")
endif()

message(STATUS "Testing regular mode with FETCH_REF")
vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant false
    WORKING_DIRECTORY "${git_test_repo}"
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

message(STATUS "Testing regular mode with FETCH_REF that happens to match HEAD")
set(VCPKG_USE_HEAD_VERSION OFF)
vcpkg_from_git(
    OUT_SOURCE_PATH source_path
    URL "${git_remote}"
    REF "${head_ref}"
    FETCH_REF main
    HEAD_REF main
)
file(READ "${source_path}/README.txt" contents)
if(NOT "${contents}" STREQUAL "second commit")
    message(FATAL_ERROR "Failed to checkout the second commit. Contents were:
${contents}
")
endif()

vcpkg_execute_required_process(
    COMMAND ${git} config uploadpack.allowReachableSHA1InWant true
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git-config"
)

message(STATUS "Testing head mode")
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

message(STATUS "Testing head mode + no HEAD_REF -> just uses REF")
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

message(STATUS "Testing new head ref")
file(WRITE "${git_test_repo}/README.txt" "third commit")
vcpkg_execute_required_process(
    COMMAND ${git} add "README.txt"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git.7"
)
vcpkg_execute_required_process(
    COMMAND ${git} commit -m "second commit"
    WORKING_DIRECTORY "${git_test_repo}"
    LOGNAME "git.8"
)
vcpkg_execute_in_download_mode(
    COMMAND ${git} rev-parse HEAD
    OUTPUT_VARIABLE new_head_ref
    RESULT_VARIABLE error_code
    WORKING_DIRECTORY "${git_test_repo}"
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

message(STATUS "Testing LFS support")
vcpkg_execute_in_download_mode(
    COMMAND "${GIT}" lfs --version
    OUTPUT_VARIABLE lfs_version_output
    ERROR_VARIABLE lfs_version_error
    RESULT_VARIABLE lfs_version_result
    WORKING_DIRECTORY "${git_test_repo}"
)
if(NOT lfs_version_result)
    vcpkg_execute_required_process(
        COMMAND ${git} lfs install --local
        WORKING_DIRECTORY "${git_test_repo}"
        LOGNAME "git-lfs-install"
    )
    file(WRITE "${git_test_repo}/.gitattributes" "* text=auto\n*.bin filter=lfs diff=lfs merge=lfs -text\n")

    message(STATUS "Testing fetching with the same Git and LFS urls")
    file(WRITE "${git_test_repo}/lfs_file.bin" "fourth commit")
    vcpkg_execute_required_process(
        COMMAND ${git} add ".gitattributes" "lfs_file.bin"
        WORKING_DIRECTORY "${git_test_repo}"
        LOGNAME "git-lfs-add"
    )
    vcpkg_execute_required_process(
        COMMAND ${git} commit -m "fourth commit"
        WORKING_DIRECTORY "${git_test_repo}"
        LOGNAME "git-lfs-commit"
    )
    vcpkg_execute_in_download_mode(
        COMMAND ${git} rev-parse HEAD
        OUTPUT_VARIABLE ref
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY "${git_test_repo}"
    )
    if(NOT "${error_code}" EQUAL "0")
        message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
    endif()
    string(STRIP "${ref}" ref)

    vcpkg_execute_in_download_mode(
        COMMAND ${git} lfs ls-files --name-only
        OUTPUT_VARIABLE lfs_files
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY "${git_test_repo}"
    )
    if(NOT "${error_code}" EQUAL "0")
        message(FATAL_ERROR "Failed lfs ls-files: ${error_code}")
    endif()
    string(STRIP "${lfs_files}" lfs_files)
    if(NOT "${lfs_files}" MATCHES [[lfs_file\.bin]])
        message(FATAL_ERROR "File was not added to LFS")
    endif()

    set(VCPKG_USE_HEAD_VERSION OFF)
    vcpkg_from_git(
        OUT_SOURCE_PATH source_path
        URL "${git_remote}"
        REF "${ref}"
        HEAD_REF main
        LFS
    )
    file(READ "${source_path}/lfs_file.bin" contents)
    if(NOT "${contents}" STREQUAL "fourth commit")
        message(FATAL_ERROR "Failed to checkout the fourth commit. Contents were:
${contents}
    ")
    endif()

    message(STATUS "Testing fetching from different Git and LFS urls")
    # requires LFS 3.0.0 or later for "--force" on prune
    string(REGEX MATCH "git-lfs/([0-9\\.]+) " lfs_version "${lfs_version_output}")
    set(lfs_version "${CMAKE_MATCH_1}")
    if(lfs_version VERSION_GREATER_EQUAL "3.0.0")
        file(WRITE "${git_test_repo}/lfs_file2.bin" "fifth commit")
        vcpkg_execute_required_process(
            COMMAND ${git} add "lfs_file2.bin"
            WORKING_DIRECTORY "${git_test_repo}"
            LOGNAME "git-lfs-add.2"
        )
        vcpkg_execute_required_process(
            COMMAND ${git} commit -m "fifth commit"
            WORKING_DIRECTORY "${git_test_repo}"
            LOGNAME "git-lfs-commit.2"
        )
        vcpkg_execute_in_download_mode(
            COMMAND ${git} rev-parse HEAD
            OUTPUT_VARIABLE ref
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${git_test_repo}"
        )
        if(NOT "${error_code}" EQUAL "0")
            message(FATAL_ERROR "Failed to rev-parse HEAD: ${error_code}")
        endif()
        string(STRIP "${ref}" ref)

        set(git_test_repo_2 "${CURRENT_BUILDTREES_DIR}/test-git-repo-2")
        file(REMOVE_RECURSE "${git_test_repo_2}")
        set(git_remote_2 "file:///${git_test_repo_2}")
        vcpkg_execute_required_process(
            COMMAND ${git} init --bare "test-git-repo-2"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "git-init.2"
        )
        # note: LFS won't prune "unpushed" files, which is checked using the "origin" remote by default.
        # If there is no remote then files are never considered to be "pushed", and so are never pruned.
        vcpkg_execute_required_process(
            COMMAND ${git} remote add origin "${git_remote_2}"
            WORKING_DIRECTORY "${git_test_repo}"
            LOGNAME "git-remote-add"
        )
        vcpkg_execute_required_process(
            COMMAND ${git} push --all origin
            WORKING_DIRECTORY "${git_test_repo}"
            LOGNAME "git-push"
        )

        vcpkg_execute_in_download_mode(
            COMMAND ${git} lfs prune --force --verbose
            OUTPUT_VARIABLE lfs_prune
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${git_test_repo}"
        )
        if(NOT "${error_code}" EQUAL "0")
            message(FATAL_ERROR "Failed to prune LFS files: ${error_code}")
        endif()
        if(NOT "${lfs_prune}" MATCHES "0 retained")
            message(FATAL_ERROR "LFS prune did not delete all files:\n${lfs_prune}")
        endif()

        set(VCPKG_USE_HEAD_VERSION OFF)
        vcpkg_from_git(
            OUT_SOURCE_PATH source_path
            URL "${git_remote}"
            REF "${ref}"
            HEAD_REF main
            LFS "${git_remote_2}"
        )
        file(READ "${source_path}/lfs_file2.bin" contents)
        if(NOT "${contents}" STREQUAL "fifth commit")
            message(FATAL_ERROR "Failed to checkout the fifth commit. Contents were:
    ${contents}
        ")
        endif()
    else()
        message(NOTICE "Git LFS version is older than 3.0.0: some tests were skipped")
    endif()
else()
    message(NOTICE "Git LFS is not available: some tests were skipped")
endif()
