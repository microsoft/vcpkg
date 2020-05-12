#include <vcpkg/base/checks.h>
#include <vcpkg/base/json.h>
#include <vcpkg/base/stringview.h>
#include <vcpkg/base/system.print.h>

#include <iostream>
#include <sstream>
#include <string.h>
#include <utility>

using namespace vcpkg;

namespace
{
    enum class FuzzKind
    {
        None,
        Utf8Decoder,
        JsonParser,
    };

    struct FuzzArgs
    {
        FuzzArgs(int argc, char** argv)
        {
            if (argc <= 1)
            {
                print_help_and_exit();
            }

            char** it = argv + 1; // skip the name of the program
            char** last = argv + argc;

            for (; it != last; ++it)
            {
                auto arg = StringView(*it, strlen(*it));
                if (arg == "/?")
                {
                    print_help_and_exit();
                }

                auto pr = split_arg(arg);
                auto key = pr.first;
                auto value = pr.second;
                if (key == "h" || key == "help")
                {
                    print_help_and_exit();
                }

                if (key == "kind")
                {
                    if (value == "json")
                    {
                        kind = FuzzKind::JsonParser;
                    }
                    else if (value == "utf-8")
                    {
                        kind = FuzzKind::Utf8Decoder;
                    }
                    else
                    {
                        System::print2(System::Color::error, "Invalid kind: ", value, "\n");
                        System::print2(System::Color::error, "  Expected one of: utf-8, json\n\n");
                        print_help_and_exit(true);
                    }
                }
                else
                {
                    System::print2("Unknown option: ", key, "\n\n");
                    print_help_and_exit(true);
                }
            }
        }

        // returns {arg, ""} when there isn't an `=`
        // skips preceding `-`s
        std::pair<StringView, StringView> split_arg(StringView arg)
        {
            auto first = std::find_if(arg.begin(), arg.end(), [](char c) { return c != '-'; });
            auto division = std::find(first, arg.end(), '=');
            if (division == arg.end()) {
                return {StringView(first, arg.end()), StringView(arg.end(), arg.end())};
            } else {
                return {StringView(first, division), StringView(division + 1, arg.end())};
            }
        }

        [[noreturn]] void print_help_and_exit(bool invalid = false)
        {
            constexpr auto help =
                R"(
Usage: vcpkg-fuzz <options>

Accepts input on stdin.

Options:
  --kind=...                One of {utf-8, json}
)";

            auto color = invalid ? System::Color::error : System::Color::success;

            System::print2(color, help);
            if (invalid)
            {
                Checks::exit_fail(VCPKG_LINE_INFO);
            }
            else
            {
                Checks::exit_success(VCPKG_LINE_INFO);
            }
        }

        FuzzKind kind;
    };

    std::string read_all_of_stdin()
    {
        std::stringstream ss;
        ss << std::cin.rdbuf();
        return std::move(ss).str();
    }

}

int main(int argc, char** argv)
{
    auto args = FuzzArgs(argc, argv);

    if (args.kind == FuzzKind::None)
    {
        args.print_help_and_exit(true);
    }

    auto text = read_all_of_stdin();
    auto res = Json::parse(text);
    if (!res)
    {
        System::print2(System::Color::error, res.error()->format());
    }
    else
    {
        System::print2(System::Color::success, "success!");
    }
}
