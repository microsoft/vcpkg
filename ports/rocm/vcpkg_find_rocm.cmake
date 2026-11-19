function(vcpkg_find_rocm)
    cmake_parse_arguments(PARSE_ARGV 0 vfr "" "OUT_ROCM_TOOLKIT_ROOT;OUT_ROCM_VERSION" "")

    if(NOT vfr_OUT_ROCM_TOOLKIT_ROOT)
        message(FATAL_ERROR "vcpkg_find_rocm() requires an OUT_ROCM_TOOLKIT_ROOT argument")
    endif()

    # Minimum version this port guarantees.  Dependent probes may require more
    # (hwloc, for instance, needs the ROCm SMI library shipped by ROCm >= 5).
    set(ROCM_REQUIRED_VERSION "5.0.0")

    set(rocm_candidates "")
    if(DEFINED ENV{ROCM_PATH})
        list(APPEND rocm_candidates "$ENV{ROCM_PATH}")
    endif()
    list(APPEND rocm_candidates "/opt/rocm")
    file(GLOB versioned_rocm "/opt/rocm-*")
    if(versioned_rocm)
        list(SORT versioned_rocm COMPARE NATURAL ORDER DESCENDING)
        list(APPEND rocm_candidates ${versioned_rocm})
    endif()

    set(rocm_root "")
    foreach(candidate IN LISTS rocm_candidates)
        if(IS_DIRECTORY "${candidate}")
            set(rocm_root "${candidate}")
            break()
        endif()
    endforeach()

    if(NOT rocm_root)
        message(FATAL_ERROR "Could not find ROCm. Before continuing, please install ROCm"
            " (https://rocm.docs.amd.com/) or point the ROCM_PATH environment variable"
            " at an existing installation.")
    endif()

    set(rocm_version "")
    if(EXISTS "${rocm_root}/.info/version")
        file(READ "${rocm_root}/.info/version" rocm_version)
        string(STRIP "${rocm_version}" rocm_version)
        # The file may carry a build suffix such as "6.2.41133-a6a3e3f7".
        string(REGEX MATCH "^[0-9]+\\.[0-9]+(\\.[0-9]+)?" rocm_version "${rocm_version}")
    endif()

    if(rocm_version)
        message(STATUS "Found ROCm ${rocm_version} at ${rocm_root}")
        if(rocm_version VERSION_LESS ROCM_REQUIRED_VERSION)
            message(FATAL_ERROR "ROCm ${rocm_version} found at ${rocm_root}, but ROCm"
                " v${ROCM_REQUIRED_VERSION} or higher is required. Please install a more"
                " recent ROCm from https://rocm.docs.amd.com/")
        endif()
    else()
        message(STATUS "Found ROCm at ${rocm_root} (no readable .info/version, assuming it meets the requirement)")
    endif()

    set(${vfr_OUT_ROCM_TOOLKIT_ROOT} "${rocm_root}" PARENT_SCOPE)
    if(DEFINED vfr_OUT_ROCM_VERSION)
        set(${vfr_OUT_ROCM_VERSION} "${rocm_version}" PARENT_SCOPE)
    endif()
endfunction()
