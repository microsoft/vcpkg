include(vcpkg_execute_required_process)

set(VCPKG_BUILD_TYPE release) 

# Define the source path
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lib3mf)

# Remove the existing source path if necessary
file(REMOVE_RECURSE ${SOURCE_PATH})

# Clone the repository
vcpkg_execute_required_process(
    COMMAND git clone https://github.com/vijaiaeroastro/lib3mf.git ${SOURCE_PATH}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME git-clone
)

vcpkg_execute_required_process(
    COMMAND git --version
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME git-version
)

# Checkout the specific commit
vcpkg_execute_required_process(
    COMMAND git checkout 0b212ba3de1fb2abf44e1a345fe3d4496c2f3622
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME git-checkout
)

# Initialize and update submodules
vcpkg_execute_required_process(
    COMMAND git submodule update --init --recursive
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME git-submodule
)

# Proceed with the usual build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DLIB3MF_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")

foreach(_file IN ITEMS ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lib3mf.pc ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lib3mf.pc)
    file(READ "${_file}" _contents)
    string(REPLACE "/home/vijai/Code/DEPS/vcpkg" "\${prefix}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endforeach()

