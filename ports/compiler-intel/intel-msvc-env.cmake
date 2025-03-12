include_guard(GLOBAL)

function(setup_intel_msvc_env)
  if(NOT DEFINED ENV{INTEL_TOOLCHAIN_ENV_ALREADY_SET})
    set(ONEAPIROOT_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../compiler/intel")
    file(GLOB CMPLR_ROOT LIST_DIRECTORIES true "${ONEAPIROOT_DIR}/compiler/*")

    cmake_path(CONVERT "$ENV{INCLUDE}" TO_CMAKE_PATH_LIST include_env)
    list(PREPEND include_env
            "${CMPLR_ROOT}/include"
        )
    cmake_path(CONVERT "${include_env}" TO_NATIVE_PATH_LIST include_env NORMALIZE)
    set(ENV{INCLUDE} "${include_env}")

    cmake_path(CONVERT "$ENV{LIB}" TO_CMAKE_PATH_LIST lib_env)
    list(PREPEND lib_env
            "${CMPLR_ROOT}/lib/clang/19/lib/windows"
            "${CMPLR_ROOT}/opt/compiler/lib"
            "${CMPLR_ROOT}/lib"
        )
    cmake_path(CONVERT "${lib_env}" TO_NATIVE_PATH_LIST lib_env NORMALIZE)
    set(ENV{LIB} "${lib_env}")

    cmake_path(CONVERT "$ENV{PATH}" TO_CMAKE_PATH_LIST path)
    list(APPEND path
                "${CMPLR_ROOT}/bin"
        )
    cmake_path(CONVERT "${path}" TO_NATIVE_PATH_LIST path NORMALIZE)
    set(ENV{PATH} "${path}")

    set(ENV{INTEL_TOOLCHAIN_ENV_ALREADY_SET} "1")
  endif()

# rem OpenCL FPGA runtime
# if exist "%CMPLR_ROOT%\opt\oclfpga\fpgavars.bat" (
    # call "%CMPLR_ROOT%\opt\oclfpga\fpgavars.bat"
# )

# set "PATH=%CMPLR_ROOT%\bin;%PATH%"
# set "PATH=%CMPLR_ROOT%\lib\ocloc;%PATH%"
# if /i "%USE_INTEL_LLVM%"=="1" (
    # set "PATH=%CMPLR_ROOT%\bin\compiler;%PATH%"
# )

# set "CPATH=%CMPLR_ROOT%\include;%CPATH%"
# set "INCLUDE=%CMPLR_ROOT%\include;%INCLUDE%"
# set "LIB=%CMPLR_ROOT%\lib\clang\19\lib\windows;%CMPLR_ROOT%\opt\compiler\lib;%CMPLR_ROOT%\lib;%LIB%"
# set "PKG_CONFIG_PATH=%CMPLR_ROOT%\lib\pkgconfig;%PKG_CONFIG_PATH%"

# set "OCL_ICD_FILENAMES=%OCL_ICD_FILENAMES%;%CMPLR_ROOT%\bin\intelocl64_emu.dll;%CMPLR_ROOT%\bin\intelocl64.dll"

# set "CMAKE_PREFIX_PATH=%CMPLR_ROOT%;%CMAKE_PREFIX_PATH%"
endfunction()
