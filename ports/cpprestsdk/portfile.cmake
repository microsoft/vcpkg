include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/Microsoft/cpprestsdk")
set(GIT_REF "3542f07")

if(NOT EXISTS "${DOWNLOADS}/cpprestsdk.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/cpprestsdk.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/cpprestsdk.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} apply ${CMAKE_CURRENT_LIST_DIR}/0001-Use-find_package-on-Windows.-Enable-install-target-f.patch --ignore-whitespace --whitespace=fix
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME patch
    )
endif()
message(STATUS "Adding worktree and patching done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Release
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXCLUDE_WEBSOCKETS=ON
    OPTIONS_DEBUG
        -DCASA_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY ${CURRENT_BUILDTREES_DIR}/src/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpprestsdk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cpprestsdk/license.txt ${CURRENT_PACKAGES_DIR}/share/cpprestsdk/copyright)
vcpkg_copy_pdbs()

