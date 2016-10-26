include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
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
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets-release.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/gRPC/gRPCTargets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-debug.cmake)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

vcpkg_copy_pdbs()
