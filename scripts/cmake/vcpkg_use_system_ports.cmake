## # vcpkg_use_system_ports
## Check if one or more features are a part of a package installation.
## 
## ## Usage
## ```cmake
## vcpkg_use_system_ports(
##   OUT_PORTS_OPTIONS <FEATURE_OPTIONS>  
##   [FEATURES
##     <cuda> <cuda>
##     [<opencv> <opencv>]
##     ...]
##   [INVERTED_FEATURES
##     <cuda> <cuda>
##     [<opencv> <opencv>]
##     ...]
## )
## ```
## `vcpkg_use_system_ports()` accepts these parameters: 
## 
## * `OUT_PORTS_OPTIONS`:  
##   An output variable, the function will clear the variable passed to `OUT_PORTS_OPTIONS` 
##   and then set it to contain a list of option definitions (`--with-<PORT_NAME>=ON|OFF`).
##   
##   This should be set to `FEATURE_OPTIONS` by convention.
##   
## * `EXTRA_OPTIONS`:  
##   A list of (`PORT_NAME`, `OPTION_NAME`) pairs.  
##   For each `PORT_NAME` a definition is added to `OUT_PORTS_OPTIONS` in the form of:   
##     
##     * `-with-<OPTION_NAME>=${CURRENT_INSTALLED_DIR}`, if a feature is specified for installation,
##     * `-disable-<OPTION_NAME>`, otherwise. 
## 
## * `INVERTED_FEATURES`:  
##   A list of (`PORT_NAME`, `OPTION_NAME`) pairs, uses reversed logic from `EXTRA_OPTIONS`.  
##   For each `PORT_NAME` a definition is added to `OUT_PORTS_OPTIONS` in the form of:   
##     
##     * `--disable-<OPTION_NAME>`, if a feature is specified for installation,
##     * `--with-<OPTION_NAME>=${CURRENT_INSTALLED_DIR}`, otherwise. 
## 
## 
## ## Notes
## 
## The `EXTRA_OPTIONS` name parameter can be omitted if no `INVERTED_FEATURES` are used.
## 
## At least one (`PORT_NAME`, `OPTION_NAME`) pair must be passed to the function call.
## 
## Arguments passed to `EXTRA_OPTIONS` and `INVERTED_FEATURES` are not validated to prevent duplication.  
## If the same (`PORT_NAME`, `OPTION_NAME`) pair is passed to both lists, 
## two conflicting definitions are added to `OUT_PORTS_OPTIONS`.
## 
## 
## ## Examples
## 
## ### Example 1: Regular features
## 
## ```cmake
## $ ./vcpkg install mimalloc[asm,secure]
## 
## # ports/mimalloc/portfile.cmake
## vcpkg_use_system_ports(OUT_PORTS_OPTIONS EXTRA_OPTIONS
##   # Keyword EXTRA_OPTIONS is optional if INVERTED_FEATURES are not used
##     asm       MI_SEE_ASM
##     override  MI_OVERRIDE
##     secure    MI_SECURE
## )
## 
## vcpkg_configure_make(
##   SOURCE_PATH ${SOURCE_PATH}
##   PREFER_NINJA
##   OPTIONS
##     # Expands to "-DMI_SEE_ASM=ON; -DMI_OVERRIDE=OFF; -DMI_SECURE=ON"
##     ${EXTRA_OPTIONS}
## )
## ```
## 
## ## Examples in portfiles
## 
## 
function(vcpkg_use_system_ports)
    cmake_parse_arguments(_vsp "" "OUT_PORTS_OPTIONS" "PORTS;INVERTED_PORTS" ${ARGN})

    if (NOT DEFINED _vsp_OUT_PORTS_OPTIONS)
        message(FATAL_ERROR "OUT_PORTS_OPTIONS must be specified.")
    endif()

    macro(_check_features _vsp_ARGUMENT _set_case)
        foreach(_vsp_ARG ${${_vsp_ARGUMENT}})
            set(_vsp_PORTS_VARIABLE ${_vsp_ARG})
            if (${_set_case})
                list(APPEND _vsp_PORTS_OPTIONS --with-${_vsp_PORTS_VARIABLE}=${CURRENT_INSTALLED_DIR})
            else()
                list(APPEND _vsp_PORTS_OPTIONS --disable-${_vsp_PORTS_VARIABLE})
            endif()
        endforeach()
    endmacro()

    set(_vsp_PORTS_OPTIONS)

    if (DEFINED _vsp_PORTS OR DEFINED _vsp_INVERTED_PORTS)
        _check_features(_vsp_PORTS ON)
        _check_features(_vsp_INVERTED_PORTS OFF)
    else() 
        # Skip arguments that correspond to OUT_PORTS_OPTIONS and its value.
        list(SUBLIST ARGN 2 -1 _vsp_ARGN)
        _check_features(_vsp_ARGN ON OFF)
    endif()
    set(${_vsp_OUT_PORTS_OPTIONS} "${_vsp_PORTS_OPTIONS}" PARENT_SCOPE)
endfunction()
