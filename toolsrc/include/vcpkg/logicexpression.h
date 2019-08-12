#pragma once

#include <string>

namespace vcpkg
{
    // Evaluate simple vcpkg logic expressions.  An identifier in the expression is considered 'true'
    // if it is a substring of the evaluation_context (typically the name of the triplet)
    bool evaluate_expression(const std::string& expression, const std::string& evaluation_context);
}