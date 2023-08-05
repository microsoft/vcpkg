set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(validator_args "")
if(VCPKG_TARGET_EXECUTABLE_SUFFIX)
    set(validator_args VALIDATOR validate_suffix)
endif()
function(validate_suffix validator_result_var item)
    cmake_path(GET item EXTENSION LAST_ONLY suffix)
    if(NOT suffix STREQUAL VCPKG_TARGET_EXECUTABLE_SUFFIX)
        set(${validator_result_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

set(variables "")

# Tool ports

foreach(tool IN ITEMS bazel)
    list(APPEND variables "vcpkg-tool-${tool}")
    find_program("vcpkg-tool-${tool}"
        NAMES "${tool}"
        ${validator_args}
        PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools"
              "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-${tool}"
        NO_DEFAULT_PATH
        REQUIRED
    )
    if(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-${tool}")
        list(APPEND CMAKE_IGNORE_PATH "${CURRENT_HOST_INSTALLED_DIR}/tools/vcpkg-tool-${tool}")
    endif()
endforeach()
list(APPEND CMAKE_IGNORE_PATH "${CURRENT_HOST_INSTALLED_DIR}/tools")

# For each vcpkg_find_acquire_program(NAME).cmake script,
# there must be a literal call to vcpkg_find_acquire_program(NAME).cmake

list(APPEND variables BAZEL BISON FLEX GIT GN NINJA PERL PKGCONFIG PYTHON3 YASM)
vcpkg_find_acquire_program(BAZEL)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(GN)
vcpkg_find_acquire_program(NINJA)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(YASM)

if(NOT VCPKG_TARGET_IS_OSX)
    # System python too old (3.9; meson needs 3.10)
    list(APPEND variables MESON)
    vcpkg_find_acquire_program(MESON)
endif()

if(VCPKG_HOST_IS_LINUX)
    list(APPEND variables PATCHELF)
    vcpkg_find_acquire_program(PATCHELF)
endif()

if(VCPKG_HOST_IS_WINDOWS)
    list(APPEND variables 7Z ARIA2 CLANG DARK DOXYGEN GASPREPROCESSOR GO GPERF JOM NASM NUGET PYTHON2 RUBY SCONS SWIG)
    vcpkg_find_acquire_program(7Z)
    vcpkg_find_acquire_program(ARIA2)
    vcpkg_find_acquire_program(CLANG)
    vcpkg_find_acquire_program(DARK)
    vcpkg_find_acquire_program(DOXYGEN)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    vcpkg_find_acquire_program(GO)
    vcpkg_find_acquire_program(GPERF)
    vcpkg_find_acquire_program(JOM)
    vcpkg_find_acquire_program(NASM)
    vcpkg_find_acquire_program(NUGET)
    vcpkg_find_acquire_program(PYTHON2)
    vcpkg_find_acquire_program(RUBY)
    vcpkg_find_acquire_program(SCONS)
    vcpkg_find_acquire_program(SWIG)
endif()

set(missing "")
foreach(variable IN LISTS variables)
    list(POP_BACK "${variable}" program)
    if(NOT EXISTS "${program}")
        list(APPEND missing "${variable}: ${program}")
    endif()
    list(POP_FRONT "${variable}" interpreter)
    if(interpreter AND NOT EXISTS "${interpreter}")
        list(APPEND missing "${variable} (interpreter): ${interpreter}")
    endif()
endforeach()
if(missing)
    list(JOIN missing "\n   " missing)
    message(FATAL_ERROR "The following programs do not exist:\n   ${missing}")
endif()
