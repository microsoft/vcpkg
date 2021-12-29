set(build_python_versions)

if("python2" IN_LIST FEATURES)
    # Find Python2 libraries. Can't use find_package here, but we already know where everything is
    file(GLOB python2_include_dir "${CURRENT_INSTALLED_DIR}/include/python2.*")
    string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python2_version "${python2_include_dir}")

    string(APPEND USER_CONFIG_EXTRA_LINES
        "using python : ${python2_version} : : \"${python2_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/lib\" ;\n"
        "using python : ${python2_version} : : \"${python2_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/debug/lib\" : <python-debugging>on ;\n")
    list(APPEND build_python_versions "${python2_version}")
endif()

if("python3" IN_LIST FEATURES)
    # Find Python3 libraries. Can't use find_package here, but we already know where everything is
    file(GLOB python3_include_dir "${CURRENT_INSTALLED_DIR}/include/python3.*")
    string(REGEX REPLACE ".*python([0-9\.]+).*" "\\1" python3_version "${python3_include_dir}")

    string(APPEND USER_CONFIG_EXTRA_LINES
        "using python : ${python3_version} : : \"${python3_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/lib\" ;\n"
        "using python : ${python3_version} : : \"${python3_include_dir}\" : \"${CURRENT_INSTALLED_DIR}/debug/lib\" : <python-debugging>on ;\n")
    list(APPEND build_python_versions "${python3_version}")
endif()

if(NOT build_python_versions)
    message(FATAL_ERROR "Boost.Python requires at least one Python specified as a feature.")
endif()

string(REPLACE ";" "," build_python_versions "${build_python_versions}")
list(APPEND B2_OPTIONS
    python=${build_python_versions}
)

if(CMAKE_CXX_FLAGS_DEBUG MATCHES "BOOST_DEBUG_PYTHON" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND B2_OPTIONS
        python-debugging=on
    )
endif()
