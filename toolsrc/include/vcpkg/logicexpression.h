#pragma once

#include <string>
#include <unordered_map>
#include <vcpkg/base/expected.h>

namespace vcpkg
{
    struct ExpressionContext
    {
        // map of cmake variables and their values.
        const std::unordered_map<std::string, std::string>& cmake_context;

        // The legacy context is a string (typically the name of the triplet).
        // An identifier was considered 'true' if it is a substring of this.
        // It is now used for backwards compatability diagnostic messages and
        // will be eventually removed.
        const std::string& legacy_context;
    };

    // Evaluate simple vcpkg logic expressions.  An identifier in the expression is considered 'true'
    // if it is a substring of the evaluation_context (typically the name of the triplet)
    ExpectedT<bool, std::string> evaluate_expression(const std::string& expression, const ExpressionContext& context);
}