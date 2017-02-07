if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/grpc/grpc.git")
set(GIT_REV "1674f650ad9411448a35b7c19c5dbdaf0ebd8916")

if(NOT EXISTS "${DOWNLOADS}/grpc.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/grpc.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REV}
        WORKING_DIRECTORY ${DOWNLOADS}/grpc.git
        LOGNAME worktree
    )
    message(STATUS "Updating sumbodules")
    vcpkg_execute_required_process(
        COMMAND ${GIT} submodule update --init third_party/nanopb
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME submodule
    )
endif()
message(STATUS "Adding worktree and updating sumbodules done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS
        -DgRPC_INSTALL=ON
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/grpc)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCConfig.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCConfigVersion.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCConfigVersion.cmake)

# Update import target prefix in gRPCTargets.cmake
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets.cmake _contents)
set(pattern "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n")
string(REPLACE "${pattern}${pattern}" "${pattern}" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets.cmake "${_contents}")

# Update paths in gRPCTargets-release.cmake
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets-release.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-release.cmake "${_contents}")

# Update paths in gRPCTargets-debug.cmake
file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/gRPC/gRPCTargets-debug.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/debug/lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-debug.cmake "${_contents}")

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)

# Install tools and plugins
file(
    INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools
    FILES_MATCHING PATTERN "*.exe"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

vcpkg_copy_pdbs()
