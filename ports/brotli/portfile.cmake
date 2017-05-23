include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
set(INCLUDE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/c/include/brotli)

set(GIT_URL "https://github.com/google/brotli.git")
set(GIT_REF "0a84e9bf864dfe3862bfe7b4e09650ff283c9825")

if(NOT EXISTS "${DOWNLOADS}/brotli.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/brotli.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH} ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/brotli.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()


vcpkg_configure_cmake(
    SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src"
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()


file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(GLOB DLLS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.dll")
file(GLOB LIBS "${CURRENT_PACKAGES_DIR}/bin/*.lib")
file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(GLOB DEBUG_DLLS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll")
file(GLOB DEBUG_LIBS "${CURRENT_PACKAGES_DIR}/debug/bin/*.lib")
file(GLOB HEADERS "${INCLUDE_DIRECTORY}/*.h")
file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/brotli)
file(REMOVE ${EXES})
file(REMOVE ${LIBS})
file(REMOVE ${DEBUG_EXES})
file(REMOVE ${DEBUG_LIBS})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brotli RENAME copyright)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
