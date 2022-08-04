function(vcpkg_msbuild_inject_props)
    cmake_parse_arguments(
        PARSE_ARGV 0
        "arg"
        ""
        "INJECT_PROPS"
        "PROJECT_TO_INJECT"
    )
    if(arg_PROJECT_TO_INJECT MATCHES ".sln")
        file(READ "${arg_PROJECT_TO_INJECT}" content)
        string(REGEX MATCHALL [[Project\("[^"]+"\) = "[^"]+", "[^"]+", "[^"]+"]] projects_in_sln "${content}")
        message(STATUS "projects_in_sln:${projects_in_sln}")
        list(TRANSFORM projects_in_sln REPLACE [[Project\("[^"]+"\) = "[^"]+", "([^"]+)", "[^"]+"]] [[\1]])
        cmake_path(GET arg_PROJECT_TO_INJECT PARENT_PATH project_dir)
        cmake_path(CONVERT "${projects_in_sln}" TO_CMAKE_PATH_LIST project_files)
        list(TRANSFORM project_files PREPEND "${project_dir}/")
        message(STATUS "project_files:${project_files}")
    else()
        set(project_files "${arg_PROJECT_TO_INJECT}")
    endif()
    foreach(project_file IN LISTS project_files)
        file(READ "${project_file}" content)
        string(REGEX REPLACE "</Project>$" "  <Import Project=\"${arg_INJECT_PROPS}\" />\n</Project>" content "${content}")
        file(WRITE "${project_file}" "${content}")
    endforeach()
endfunction()
