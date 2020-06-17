#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP" "Linux" "OSX")

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

file(REMOVE_RECURSE ${SOURCE_PATH}/.build/Local/CBTModules/CBTModules.proj)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/packages.config DESTINATION ${SOURCE_PATH}/.build/Local/CBTModules)

if(TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(BUILD_ARCH "Win32")
else()
    set(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH dirs.proj
    SKIP_CLEAN
    OPTIONS
        "/p:PlatformToolset=WindowsUserModeDriver10.0"
        "/p:BasePlatformToolset=${VCPKG_PLATFORM_TOOLSET}"
        "/p:VCToolsVersion=$ENV{VCToolsVersion}"
    LICENSE_SUBPATH LICENSE.txt
)

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}/out/Release-${BUILD_ARCH}/include" DESTINATION ${CURRENT_PACKAGES_DIR})
file(REMOVE_RECURSE 
  ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PORT}/packages
  ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PORT}/packages
  ${CURRENT_INSTALLED_DIR}/tools/${PORT}/nuget.exe
  ${CURRENT_PACKAGES_DIR}/bin 
  ${CURRENT_PACKAGES_DIR}/debug/bin
  )

vcpkg_copy_pdbs() # automatic templates
###
