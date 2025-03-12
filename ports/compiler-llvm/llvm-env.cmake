include_guard(GLOBAL)

function(setup_llvm_env)
    if(NOT DEFINED ENV{LLVMInstallDir})
        set(LLVMInstallDir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../compiler/llvm")
        cmake_path(NORMAL_PATH LLVMInstallDir)
        set(ENV{LLVMInstallDir} "${LLVMInstallDir}")
        set(ENV{LLVMToolsVersion} "19")
        set(ENV{PATH} "$ENV{LLVMInstallDir}/bin;$ENV{PATH}")
    endif()
endfunction()
