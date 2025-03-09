find_program(BAZEL bazel${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/bazel" REQUIRED)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BAZEL_DIR}")
set(ENV{BAZEL_BIN_PATH} "${BAZEL_DIR}")


# https://bazel.build/reference/command-line-reference#flag--output_user_root
# https://bazel.build/reference/command-line-reference#flag--output_base

# https://bazel.build/reference/command-line-reference#flag--system_rc -> deactivate

# https://bazel.build/reference/command-line-reference#flag--distdir