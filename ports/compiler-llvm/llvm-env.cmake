
set(LLVMInstallDir "${CMAKE_CURRENT_LIST_DIR}/../../compiler-llvm")
cmake_path(NORMAL_PATH LLVMInstallDir)
set(ENV{LLVMInstallDir} "${LLVMInstallDir}")
set(ENV{LLVMToolsVersion} "19")
set(ENV{PATH} "$ENV{LLVMInstallDir}/bin;$ENV{PATH}")
