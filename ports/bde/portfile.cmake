# Acquire Python 2 and add it to PATH
vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
vcpkg_add_to_path(${PYTHON2_EXE_PATH})

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF ee80556db9afbc4107bf9cdcc51333829f251d9f # 3.61.0.0
    SHA512 fa8f0741a174f8d1f08c00d94e04db5a1afca4eeec3d1dec673ab0a0bc19bd5eb7d3f5d1cb8b532ae53c90fb1e1362dbc5ae78e5294637b7318fac8018af80d5
    HEAD_REF master
)

vcpkg_add_to_path(${TOOLS_PATH}/bin)

# Acquire BDE sources
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bloomberg/bde"
    REF a8e484bcb405f14ea76159ceb12b61dc9ba3455f # 3.61.0.0
    SHA512 66b89273ad8bc1c9ef62bb1d548e501cd40d8f94be8b8bce9ae68d1b0fb74958dd6bfbd10c4f42da264ba145e22da546a672f7bead57b1c8daad4c43ac223de5
    HEAD_REF master
)

#https://bloomberg.github.io/bde/library_information/build.html
if(VCPKG_TARGET_IS_WINDOWS)
    set(CMAKE_TOOLCHAIN_FILE ${TOOLS_PATH}/cmake/toolchains/win32/cl-default.cmake)
elseif(VCPKG_TARGET_IS_LINUX)
    set(CMAKE_TOOLCHAIN_FILE ${TOOLS_PATH}/cmake/toolchains/linux/gcc-default.cmake)
elseif(VCPKG_TARGET_IS_OSX)
    set(CMAKE_TOOLCHAIN_FILE ${TOOLS_PATH}/cmake/toolchains/darwin/gcc-default.cmake)    
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_MODULE_PATH=${TOOLS_PATH}/cmake
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
)

vcpkg_install_cmake()    

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
