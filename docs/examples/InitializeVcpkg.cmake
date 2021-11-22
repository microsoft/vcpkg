#[=======================================================================[.rst:
InitializeVcpkg
---------------

Initialize a vcpkg Git submodule, or alternatively use a vcpkg repository
at a path specified by ``VCPKG_ROOT``. Whether vcpkg is used is controlled
by the ``VCPKG`` option, which defaults to `ON`.

This module must be included before the first call to `project()`.

#]=======================================================================]

option(VCPKG "Use vcpkg for dependencies" ON)
set(VCPKG_ROOT "${CMAKE_SOURCE_DIR}/vcpkg" CACHE STRING "Path to the vcpkg Git repository")

if(VCPKG)
  if(NOT VCPKG_ROOT STREQUAL "${CMAKE_SOURCE_DIR}/vcpkg")
    message(STATUS "Using dependencies from vcpkg repository at ${VCPKG_ROOT}")

    if(NOT EXISTS "${VCPKG_ROOT}/.vcpkg-root")
      message(FATAL_ERROR "${VCPKG_ROOT} is not a valid vcpkg root directory. Set VCPKG_ROOT to a root directory of a vcpkg Git repository.")
    endif()
  else()
    message(STATUS "Using dependencies from vcpkg Git submodule")
    set(VCPKG_ROOT "${CMAKE_SOURCE_DIR}/vcpkg")

    if(NOT EXISTS "${VCPKG_ROOT}/.vcpkg-root")
      find_package(Git)
      if(NOT GIT_FOUND)
        message(FATAL_ERROR "Unable to initialize vcpkg Git submodule because CMake was unable to find a git executable.")
      endif()

      message(STATUS "Initializing vcpkg Git submodule")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule init
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      )
      execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule update
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      )
    endif()
  endif()

  set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
else()
  message(STATUS "Using dependencies from system")
endif()
