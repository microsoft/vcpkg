if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)

find_program(GIT git)

set(GIT_URL "https://github.com/google/googletest.git")
set(GIT_TAG "release-1.8.0")

if(NOT EXISTS "${DOWNLOADS}/googletest.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/googletest.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_TAG}
        WORKING_DIRECTORY ${DOWNLOADS}/googletest.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} am ${CMAKE_CURRENT_LIST_DIR}/0001-Enable-C-11-features-for-VS2015-fix-appveyor-fail.patch --ignore-whitespace --whitespace=fix
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME patch
    )
endif()
message(STATUS "Adding worktree and patching done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/googletest/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtest RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin/)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest.dll ${CURRENT_PACKAGES_DIR}/bin/gtest.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.dll ${CURRENT_PACKAGES_DIR}/bin/gtest_main.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock.dll ${CURRENT_PACKAGES_DIR}/bin/gmock.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.dll ${CURRENT_PACKAGES_DIR}/bin/gmock_main.dll)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtest.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_main.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtest_main.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmock.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_main.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmock_main.dll)

vcpkg_copy_pdbs()
