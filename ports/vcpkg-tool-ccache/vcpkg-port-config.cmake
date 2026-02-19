# CCCache tool configuration for vcpkg

# Acquire ccache using vcpkg's tool acquisition mechanism
set(CCACHE_VERSION "4.12.2")

if(CMAKE_HOST_WIN32)
    set(CCACHE_ARCHIVE "ccache-${CCACHE_VERSION}-windows-x86_64.zip")
    set(CCACHE_URL "https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/${CCACHE_ARCHIVE}")
    set(CCACHE_SHA512 "e527841e949b1920cb889ffc1acf99b352fbf20c2d3a6fd34103ee023168d643f321ca89f16bc3f200c4ef2648fe32c9884996af6aeb4ea0e711f95b98956b2f")
    set(CCACHE_PATHS "${DOWNLOADS}/tools/ccache/ccache-${CCACHE_VERSION}-windows-x86_64")
    set(CCACHE_EXECUTABLE_NAME "ccache.exe")
elseif(CMAKE_HOST_APPLE)
    set(CCACHE_ARCHIVE "ccache-${CCACHE_VERSION}-darwin.tar.gz")
    set(CCACHE_URL "https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/${CCACHE_ARCHIVE}")
    set(CCACHE_SHA512 "24e93bb8e8eea43dd13dace69a57f15513baa22770e09316b1664abb229683ff3146fbc80bb60ac7763ef0ab996de93a784c0e9d8d6ae38a1c6059fe20323606")
    set(CCACHE_PATHS "${DOWNLOADS}/tools/ccache/ccache-${CCACHE_VERSION}-darwin")
    set(CCACHE_EXECUTABLE_NAME "ccache")
else()
    set(CCACHE_ARCHIVE "ccache-${CCACHE_VERSION}-linux-x86_64.tar.xz")
    set(CCACHE_URL "https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/${CCACHE_ARCHIVE}")
    set(CCACHE_SHA512 "d5aa5316d18bbb68ba332deca057e9f87e997f46316cb20beb4ef7e264f9181242d80b39629c59b92aff5fe0a1ce83bd35eb398a7f0353cff4ef0aa2730edeff")
    set(CCACHE_PATHS "${DOWNLOADS}/tools/ccache/ccache-${CCACHE_VERSION}-linux-x86_64")
    set(CCACHE_EXECUTABLE_NAME "ccache")
endif()

# Use vcpkg's find_program mechanism to acquire the tool
find_program(CCACHE_EXECUTABLE ${CCACHE_EXECUTABLE_NAME} PATHS ${CCACHE_PATHS} NO_DEFAULT_PATH)

if(NOT CCACHE_EXECUTABLE)
  # Download ccache
  vcpkg_download_distfile(CCACHE_ARCHIVE_PATH
    URLS "${CCACHE_URL}"
    FILENAME "${CCACHE_ARCHIVE}"
    SHA512 "${CCACHE_SHA512}"
  )
  
  file(REMOVE_RECURSE "${CCACHE_PATHS}")
  # Extract archive
  vcpkg_extract_archive(
    ARCHIVE "${CCACHE_ARCHIVE_PATH}"
    DESTINATION "${CCACHE_PATHS}/.."
  )

  set(CCACHE_EXECUTABLE "${CCACHE_PATHS}/${CCACHE_EXECUTABLE_NAME}")
else()
  message(STATUS "Using CCache: ${CCACHE_EXECUTABLE}")
endif()

set(CCACHE_DIR "${CCACHE_PATHS}")

# Setup default ccache configuration directory
if(DEFINED VCPKG_ROOT_DIR)
    set(CCACHE_CONFIG_DIR "${VCPKG_ROOT_DIR}/.ccache")
elseif(DEFINED _VCPKG_ROOT_DIR)
    set(CCACHE_CONFIG_DIR "${_VCPKG_ROOT_DIR}/.ccache")
elseif(DEFINED ENV{VCPKG_ROOT})
    set(CCACHE_CONFIG_DIR "$ENV{VCPKG_ROOT}/.ccache")
else()
    set(CCACHE_CONFIG_DIR "$ENV{HOME}/.ccache")
endif()

# Copy default ccache.conf if it doesn't exist
if(NOT EXISTS "${CCACHE_CONFIG_DIR}/ccache.conf")
    file(MAKE_DIRECTORY "${CCACHE_CONFIG_DIR}")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/ccache.conf"
         DESTINATION "${CCACHE_CONFIG_DIR}")
    message(STATUS "CCache: Installed default configuration to ${CCACHE_CONFIG_DIR}/ccache.conf")
endif()

# Set ccache directory
set(ENV{CCACHE_DIR} "${CCACHE_CONFIG_DIR}")

# Set base directory to current port's buildtrees directory if available
if(DEFINED CURRENT_BUILDTREES_DIR AND DEFINED PORT)
    set(ENV{CCACHE_BASEDIR} "${CURRENT_BUILDTREES_DIR}")
endif()

# Disable hash_dir when using base_dir for relative path matching
set(ENV{CCACHE_NOHASHDIR} "1")

# Configure sloppiness for better cache hits with generated files
if(NOT DEFINED ENV{CCACHE_SLOPPINESS})
    set(ENV{CCACHE_SLOPPINESS} "pch_defines,time_macros,include_file_mtime,include_file_ctime,system_headers")
endif()

# Add compiler launcher options to vcpkg_cmake_configure
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS 
    "-DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_EXECUTABLE}"
    "-DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_EXECUTABLE}")

# Function to create compiler symlinks based on detected compilers
function(vcpkg_ccache_setup_compiler_symlinks)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "DETECTED_CMAKE_VARS_FILE" "")
    
    # Require detected CMake vars file
    if(NOT arg_DETECTED_CMAKE_VARS_FILE OR NOT EXISTS "${arg_DETECTED_CMAKE_VARS_FILE}")
        return()
    endif()
    
    # Require buildtrees directory to be defined
    if(NOT DEFINED CURRENT_BUILDTREES_DIR OR NOT DEFINED PORT)
        return()
    endif()
    
    # Create symlinks in the buildtree (unique per port/triplet)
    set(CCACHE_SYMLINKS_DIR "${CURRENT_BUILDTREES_DIR}/ccache-symlinks" PARENT_SCOPE)
    set(CCACHE_SYMLINKS_DIR "${CURRENT_BUILDTREES_DIR}/ccache-symlinks")
    
    # Load compiler information
    include("${arg_DETECTED_CMAKE_VARS_FILE}")
    
    # Clean and recreate symlinks directory for this build
    file(REMOVE_RECURSE "${CCACHE_SYMLINKS_DIR}")
    file(MAKE_DIRECTORY "${CCACHE_SYMLINKS_DIR}")
    
    # Collect all compiler/tool names to create symlinks for
    set(tool_names)
    
    if(VCPKG_DETECTED_CMAKE_C_COMPILER)
        get_filename_component(C_COMPILER_NAME "${VCPKG_DETECTED_CMAKE_C_COMPILER}" NAME)
        list(APPEND tool_names "${C_COMPILER_NAME}")
    endif()
    
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER)
        get_filename_component(CXX_COMPILER_NAME "${VCPKG_DETECTED_CMAKE_CXX_COMPILER}" NAME)
        list(APPEND tool_names "${CXX_COMPILER_NAME}")
    endif()
    
    if(VCPKG_DETECTED_CMAKE_LINKER)
        get_filename_component(LINKER_NAME "${VCPKG_DETECTED_CMAKE_LINKER}" NAME)
        list(APPEND tool_names "${LINKER_NAME}")
    endif()
    
    list(REMOVE_DUPLICATES tool_names)
    
    # Create symlinks/copies for each tool
    foreach(tool_name IN LISTS tool_names)
        set(SYMLINK_PATH "${CCACHE_SYMLINKS_DIR}/${tool_name}")
        if(CMAKE_HOST_WIN32)
            file(COPY_FILE "${CCACHE_EXECUTABLE}" "${SYMLINK_PATH}")
        else()
            file(CREATE_LINK "${CCACHE_EXECUTABLE}" "${SYMLINK_PATH}" SYMBOLIC)
        endif()
    endforeach()
    
    message(STATUS "CCache symlinks created in: ${CCACHE_SYMLINKS_DIR}")
endfunction()

# Prepend symlinks directory to PATH for non-CMake build systems (if it exists)
if(DEFINED CURRENT_BUILDTREES_DIR AND DEFINED PORT)
    set(CCACHE_SYMLINKS_DIR "${CURRENT_BUILDTREES_DIR}/ccache-symlinks")
    if(EXISTS "${CCACHE_SYMLINKS_DIR}")
        vcpkg_add_to_path(PREPEND "${CCACHE_SYMLINKS_DIR}")
    endif()
endif()

message(STATUS "CCache enabled: ${CCACHE_EXECUTABLE}")
if(DEFINED ENV{CCACHE_BASEDIR})
    message(STATUS "CCache BASEDIR: $ENV{CCACHE_BASEDIR}")
endif()

