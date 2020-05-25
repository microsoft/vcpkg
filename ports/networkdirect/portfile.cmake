vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://github.com/microsoft/NetworkDirect")
set(GIT_REV master)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=1 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME clone
    )
    message(STATUS "Fetching submodules")
    vcpkg_execute_required_process(
      COMMAND ${GIT} submodule update --init --recursive
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME submodules
    )
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES patch_v2.patch
)

# MSBuild - TARGET Restore #not work /t:Restore or /Restore and /t:Build
vcpkg_find_acquire_program(NUGET)
execute_process(
    COMMAND ${NUGET} restore ${SOURCE_PATH}/dirs.proj -Force -NonInteractive -Verbosity detailed
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH dirs.proj
    SKIP_CLEAN
    OPTIONS
        "/p:PlatformToolset=WindowsUserModeDriver10.0"
        "/p:BasePlatformToolset=v142"
        "/p:VCToolsVersion=$ENV{VCToolsVersion}"
    LICENSE_SUBPATH LICENSE.txt
)

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}/out/Release-${MSBUILD_PLATFORM}/include" DESTINATION ${CURRENT_PACKAGES_DIR})
file(REMOVE ${CURRENT_INSTALLED_DIR}/tools/${PORT}/nuget.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_copy_pdbs() # automatic templates
###
