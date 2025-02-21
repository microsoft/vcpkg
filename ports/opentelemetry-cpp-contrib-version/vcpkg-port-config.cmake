include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF f5c979ce0f9d5a9f2dab4f856aaae2afa8fc758d
        HEAD_REF main
        SHA512 ba4513065a26871b73285fb06b935b28552978161cdacf21ad51a2344f48c20937713a9676320bdb20a01d86b8d0d6bcd810c14a153161317d9da4791590b736
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
