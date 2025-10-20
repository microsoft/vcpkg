include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF ec0b6cf82ec204e13ff9b0b231ffda05c6191196
        HEAD_REF main
        SHA512 3ea1780895e51a414713d3487dc82e071a4fd5b98dc055661b7d4267d5a099274d7cf2b043085f152174e870924086b9ef0c92a00efc7605ba53b5732ae55f33
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
