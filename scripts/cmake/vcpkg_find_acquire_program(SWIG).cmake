set(program_version 4.0.2)
set(program_name swig)
if(CMAKE_HOST_WIN32)
    vcpkg_list(SET sourceforge_args
        REPO swig/swigwin
        REF "swigwin-${program_version}"
        FILENAME "swigwin-${program_version}.zip"
        SHA512 b8f105f9b9db6acc1f6e3741990915b533cd1bc206eb9645fd6836457fd30789b7229d2e3219d8e35f2390605ade0fbca493ae162ec3b4bc4e428b57155db03d
        NO_REMOVE_ONE_LEVEL
        WORKING_DIRECTORY "${DOWNLOADS}/tools/swig"
    )
    set(tool_subdirectory "b8f105f9b9-f0518bc3b7/swigwin-${program_version}")
else()
    set(apt_package_name "swig")
    set(brew_package_name "swig")
endif()
