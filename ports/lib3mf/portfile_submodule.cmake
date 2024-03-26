include(vcpkg_execute_required_process)

#set(VCPKG_BUILD_TYPE release) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 3MFConsortium/lib3mf
    REF 23a0a899c940467716456fee3936d756bdf97740 # This is the commit you are interested in.
    SHA512 7dab8804c7ee5b568057e07863da536b9fc2a97f74388096d77ae2a786bf0fcf8a1cac477327ea50d5f4d1aebfad968bb9c24b4f6ab29589777cab32c843bf0f # You need to replace this with the actual SHA-512 hash of the commit.
    TAG v2.3.1 # This is the version you mentioned.
)

function(clone_submodules source_path)
  file(READ "${source_path}/.gitmodules" gitmodules_content)
  string(REGEX MATCHALL "\\[submodule \"([^\"]+)\"\\][^\[]*path = ([^\n]+)\n[^\[]*url = ([^\n]+)" submodule_matches "${gitmodules_content}")

  foreach(submodule_match ${submodule_matches})
    # Here we ensure the extracted information is split into separate variables
    string(REGEX REPLACE "\\[submodule \"([^\"]+)\"\\][^\[]*path = ([^\n]+)\n[^\[]*url = ([^\n]+)" "\\1" submodule_name "${submodule_match}")
    string(REGEX REPLACE "\\[submodule \"([^\"]+)\"\\][^\[]*path = ([^\n]+)\n[^\[]*url = ([^\n]+)" "\\2" submodule_path "${submodule_match}")
    string(REGEX REPLACE "\\[submodule \"([^\"]+)\"\\][^\[]*path = ([^\n]+)\n[^\[]*url = ([^\n]+)" "\\3" submodule_url "${submodule_match}")

    # Normalize submodule name to be filesystem-friendly
    string(REPLACE "/" "_" normalized_submodule_name "${submodule_name}")

    # Define a log file name based on the submodule name
    set(logfile "${CMAKE_CURRENT_BINARY_DIR}/submodule-${normalized_submodule_name}-clone-log.txt")

    message(STATUS "Cloning submodule ${submodule_name} from ${submodule_url} to ${submodule_path}")

    # Normalize path for Windows
    file(TO_NATIVE_PATH "${source_path}/${submodule_path}" native_submodule_path)
    execute_process(COMMAND git.exe version)

    # Clone the submodule and direct output to the log file
    #vcpkg_execute_required_process(COMMAND git clone ${submodule_url} "${native_submodule_path}" WORKING_DIRECTORY ${source_path} LOGNAME ${logfile})
   execute_process(
      COMMAND git.exe clone ${submodule_url} "${full_submodule_path}"
      WORKING_DIRECTORY ${source_path}
      RESULT_VARIABLE git_result
      ERROR_VARIABLE git_error
      OUTPUT_VARIABLE git_output
    )

    # Check if the clone was successful
    if(NOT git_result EQUAL "0")
      message(FATAL_ERROR "Failed to clone submodule: ${submodule_name}\nError: ${git_error}")
      message(${git_output})
    else()
      message(STATUS "Submodule ${submodule_name} cloned successfully.")
    endif()
  endforeach()
endfunction()

# Now call the function with the path to where the source is located
clone_submodules(${SOURCE_PATH})


# Proceed with the usual build process
#vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DLIB3MF_TESTS=OFF)

# Install the package
#vcpkg_cmake_install()


# Copy all PDB's
#vcpkg_copy_pdbs()

# Install the license
#vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove some of the debug stuff
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")