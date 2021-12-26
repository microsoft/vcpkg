list(APPEND LOGS
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-out.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-rel-err.log"
    "${CURRENT_BUILDTREES_DIR}/config-${TARGET_TRIPLET}-dbg-err.log"
)

set(CHECK_SUCCESS_LOG "${CURRENT_BUILDTREES_DIR}/result_success")
set(CHECK_FAILED_LOG "${CURRENT_BUILDTREES_DIR}/result_failed")

foreach(LOG IN LISTS LOGS CHECK_SUCCESS_LOG CHECK_FAILED_LOG)
    file(REMOVE "${LOG}")
    if(EXISTS "${LOG}")
        message(FATAL_ERROR "Could not remove ${LOG}")
    endif()
endforeach()

set(VCPKG_BUILD_TYPE release)

vcpkg_configure_cmake(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    PREFER_NINJA
)

if (EXISTS "${CHECK_SUCCESS_LOG}")
    foreach(LOG IN LISTS LOGS)
        if(EXISTS "${LOG}")
            file(READ "${LOG}" _contents)
            message("${_contents}")
        endif()
    endforeach()
else()
    file(READ "${CHECK_FAILED_LOG}" FAILURE_DETAILS)
    set(HELP_DETAIL)
    if (FAILURE_DETAILS MATCHES "MSVC C" OR FAILURE_DETAILS MATCHES "MSVC CXX")
        set(HELP_DETAIL
[[Please ensure you've installed the following Visual Studio Components using Visual Studio Installer:
  - Windows Universal C Runtime
  - C++ Build Tools core features
  - Visual Studio Build tools:
    * VC++ 2017 version ... latest v141 tools (for Visual Studio 2017)
    * MSVC v142 - VS 2019 C++ x64/x86 build tools (for Visual Studio 2019)
    * MSVC v143 - VS 2022 C++ x64/x86 build tools (for Visual Studio 2022)
  - MSBuild
  - Windows SDK
  - English language Pack
  
For ARM / ARM64 or UWP triplet, please also installed:
  - Visual Studio Build tools for ARM:
    * VC++ 2017 version ... Libs for Spectre (ARM) (for Visual Studio 2017)
    * MSVC v142 - VS 2019 C++ ARM build tools (for Visual Studio 2019)
    * MSVC v143 - VS 2022 C++ ARM build tools (for Visual Studio 2022)
  - Visual Studio Build tools for ARM64:
    * VC++ 2017 version ... Libs for Spectre (ARM64) (for Visual Studio 2017)
    * MSVC v142 - VS 2019 C++ ARM64 build tools (for Visual Studio 2019)
    * MSVC v143 - VS 2022 C++ ARM64 build tools (for Visual Studio 2022)
  - Visual Studio Build tools for UWP:
    * Visual C++ runtime for UWP (for Visual Studio 2017)
    * C++ Universal Windows Platform support for v142 build tools (for Visual Studio 2019)
    * C++ Universal Windows Platform support for v143 build tools (for Visual Studio 2022)
]]
        )
    elseif (FAILURE_DETAILS MATCHES "gcc" OR FAILURE_DETAILS MATCHES "g++")
        set(HELP_DETAIL "Please ensure you've installed gcc / g++ >= 6.0")
    else()
        set(HELP_DETAIL "Please ensure you've installed compiler: ${FAILURE_DETAILS}")
    endif()
    message(FATAL_ERROR "Failed to detect the ${FAILURE_DETAILS} compiler.\n${HELP_DETAIL}\n")
endif()