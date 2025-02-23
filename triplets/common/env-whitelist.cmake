set(ENV_WHITELIST
  "PATH"
  "ALLUSERSPROFILE"
  "CommandPromptType"
  "CommonProgramFiles"
  "CommonProgramFiles(x86)"
  "CommonProgramW6432"
  #"COMPUTERNAME"
  "ComSpec"
#    "HOMEDRIVE"
#    "HOMEPATH"
  "ALLUSERSPROFILE"
  "LOCALAPPDATA" # Needs for CI to be allowed.
  "APPDATA"
#    "LOGONSERVER"
  "OS"
  "PATHEXT"
  "PROCESSOR_ARCHITECTURE"
  "PROCESSOR_IDENTIFIER"
  "PROCESSOR_LEVEL"
  "PROCESSOR_REVISION"
  "ProgramData"
  "ProgramFiles"
  "ProgramFiles(x86)"
  "ProgramW6432"
  "PROMPT"
  "PSModulePath"
  "PSExecutionPolicyPreference"
  "PUBLIC"
  "SystemDrive"
  "SystemRoot"
  "TEMP"
  "TMP"
  #"USERDOMAIN"
  #"USERDOMAIN_ROAMINGPROFILE"
  #"USERNAME"
  "USERPROFILE"
  "windir"
  "GIT_ASKPASS"
  "GIT_CEILING_DIRECTORIES"
  "VSCMD_SKIP_SENDTELEMETRY"
  "VCPKG_COMMAND"
  "VCPKG_TOOLCHAIN_ENV_ALREADY_SET"
  "vsconsoleoutput"
  "VSLANG"
  "X_VCPKG_RECURSIVE_DATA"
  "HTTP_PROXY"
  "HTTPS_PROXY"
)

find_program(pwsh_exe NAMES pwsh powershell)
execute_process(
    COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -Command "[System.Environment]::GetEnvironmentVariables().Keys | ForEach-Object { \"$_\" }"
    OUTPUT_VARIABLE env_vars
)
string(REPLACE "\n" ";" env_vars "${env_vars}")
string(REGEX REPLACE ";$" "" env_vars "${env_vars}")

foreach(env_var IN LISTS env_vars)
  #message(STATUS "ENV{${env_var}}:$ENV{${env_var}}")
  if(NOT "${env_var}" IN_LIST ENV_WHITELIST)
    #message(STATUS "Unsetting ${env_var}")
    unset(ENV{${env_var}})
  endif()
endforeach()