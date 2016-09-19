include(vcpkg_common_functions)

find_program(GIT git)

set(GIT_URL "https://github.com/Itseez/opencv")
set(GIT_REF "92387b1ef8fad15196dd5f7fb4931444a68bc93a")

if(NOT EXISTS "${DOWNLOADS}/opencv.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/opencv.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/opencv.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} am ${CMAKE_CURRENT_LIST_DIR}/0001-OpenCV-should-follow-FHS-like-conventions.patch --ignore-whitespace --whitespace=fix
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME patch
    )
endif()
message(STATUS "Adding worktree and patching done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS
        -DBUILD_ZLIB=OFF
        -DINSTALL_CREATE_DISTRIB=ON
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_apps=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TESTS=OFF
        -DOpenCV_DISABLE_ARCH_PATH=ON
        -DWITH_FFMPEG=OFF
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/OpenCVConfig-version.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig-version.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/OpenCVConfig.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/OpenCVModules.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/OpenCVModules-release.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/cmake/OpenCVModules-debug.cmake ${CURRENT_PACKAGES_DIR}/share/opencv/OpenCVModules-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
vcpkg_copy_pdbs()
