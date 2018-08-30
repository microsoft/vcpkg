include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
if(NOT EXISTS "${DOWNLOADS}/fdlibm-59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz")
  find_program(GIT NAMES git git.cmd)
  # Note: git init is safe to run multiple times
  vcpkg_execute_required_process(
    COMMAND ${GIT} init git-tmp
    WORKING_DIRECTORY ${DOWNLOADS}
    LOGNAME git-init
  )
  vcpkg_execute_required_process(
    COMMAND ${GIT} fetch https://android.googlesource.com/platform/external/fdlibm 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac --depth 1 -n
    WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
    LOGNAME git-fetch
  )
  vcpkg_execute_required_process(
    COMMAND ${GIT} archive 59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac -o ../fdlibm-59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz
    WORKING_DIRECTORY ${DOWNLOADS}/git-tmp
    LOGNAME git-archive
  )
endif()
vcpkg_extract_source_archive(${DOWNLOADS}/fdlibm-59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libm5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fdlibm RENAME copyright)
