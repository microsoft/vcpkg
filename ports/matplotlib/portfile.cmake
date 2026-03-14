set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled) # pip dist-info/RECORD files contain absolute paths

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matplotlib/matplotlib
    REF "v${VERSION}"
    SHA512 a28b8f2b3ce4f70469a237d81cfc84f87fbb5a26074febb9b453d72792efb7da567e99ddba17de83c223a51e3524143d42f62131118da73c77d7e9146713ef20
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(PKGCONFIG)

include("${CURRENT_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")

# Install the meson-python build backend and its requirements into a virtual environment.
# build isolation is disabled below so these tools are used directly by pip when building.
x_vcpkg_get_python_packages(
    PYTHON_VERSION "3"
    PYTHON_EXECUTABLE "${PYTHON3}"
    PACKAGES
        "meson-python>=0.13.1"
        "meson>=1.1.0"
        "setuptools_scm"
        "numpy>=1.23"
        "ninja"
    OUT_PYTHON_VAR PYTHON3_ENV
)

# Set PKG_CONFIG so meson can locate vcpkg-installed freetype, qhull, and pybind11.
set(ENV{PKG_CONFIG} "${PKGCONFIG}")
vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH}
    "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    "${CURRENT_INSTALLED_DIR}/share/pkgconfig"
)

# --no-build-isolation: use the virtual environment set up above (with meson-python and build tools)
#   rather than letting pip create its own isolated build environment.
# --no-deps: runtime dependencies (numpy, pillow, etc.) are managed separately by the user via pip;
#   only the matplotlib package itself is installed here.
# --config-settings: instruct meson-python to use the vcpkg-installed system freetype and qhull
#   instead of downloading and building bundled copies, which avoids network access during the build.
vcpkg_execute_required_process(
    COMMAND "${PYTHON3_ENV}" -I -m pip install
        --no-build-isolation
        --no-deps
        --config-settings=setup-args=-Dsystem-freetype=true
        --config-settings=setup-args=-Dsystem-qhull=true
        "${SOURCE_PATH}"
        "--target=${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME "pip-install-${TARGET_TRIPLET}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE/LICENSE")

# Remove compiled Python bytecode that pip may create during installation
file(GLOB_RECURSE PYC_FILES "${CURRENT_PACKAGES_DIR}/*.pyc")
if(PYC_FILES)
    file(REMOVE ${PYC_FILES})
endif()
