#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/expected.h>
#include <vcpkg/base/span.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/packagespec.h>
#include <vcpkg/platform-expression.h>
#include <vcpkg/sourceparagraph.h>
#include <vcpkg/triplet.h>

namespace vcpkg
{
    using namespace vcpkg::Parse;

    namespace SourceParagraphFields
    {
        static const std::string BUILD_DEPENDS = "Build-Depends";
        static const std::string DEFAULT_FEATURES = "Default-Features";
        static const std::string DESCRIPTION = "Description";
        static const std::string FEATURE = "Feature";
        static const std::string MAINTAINERS = "Maintainer";
        static const std::string NAME = "Source";
        static const std::string VERSION = "Version";
        static const std::string PORT_VERSION = "Port-Version";
        static const std::string HOMEPAGE = "Homepage";
        static const std::string TYPE = "Type";
        static const std::string SUPPORTS = "Supports";
    }

    namespace ManifestFields
    {
        constexpr static StringLiteral NAME = "name";
        constexpr static StringLiteral VERSION = "version-string";

        constexpr static StringLiteral PORT_VERSION = "port-version";
        constexpr static StringLiteral MAINTAINERS = "maintainers";
        constexpr static StringLiteral DESCRIPTION = "description";
        constexpr static StringLiteral HOMEPAGE = "homepage";
        constexpr static StringLiteral DOCUMENTATION = "documentation";
        constexpr static StringLiteral LICENSE = "license";
        constexpr static StringLiteral DEPENDENCIES = "dependencies";
        constexpr static StringLiteral DEV_DEPENDENCIES = "dev-dependencies";
        constexpr static StringLiteral FEATURES = "features";
        constexpr static StringLiteral DEFAULT_FEATURES = "default-features";
        constexpr static StringLiteral SUPPORTS = "supports";
    }

    static Span<const StringView> get_list_of_valid_fields()
    {
        static const StringView valid_fields[] = {
            SourceParagraphFields::NAME,
            SourceParagraphFields::VERSION,
            SourceParagraphFields::PORT_VERSION,
            SourceParagraphFields::DESCRIPTION,
            SourceParagraphFields::MAINTAINERS,
            SourceParagraphFields::BUILD_DEPENDS,
            SourceParagraphFields::HOMEPAGE,
            SourceParagraphFields::TYPE,
            SourceParagraphFields::SUPPORTS,
            SourceParagraphFields::DEFAULT_FEATURES,
        };

        return valid_fields;
    }

    static Span<const StringView> get_list_of_manifest_fields()
    {
        constexpr static StringView valid_fields[] = {
            ManifestFields::NAME,
            ManifestFields::VERSION,

            ManifestFields::PORT_VERSION,
            ManifestFields::MAINTAINERS,
            ManifestFields::DESCRIPTION,
            ManifestFields::HOMEPAGE,
            ManifestFields::DOCUMENTATION,
            ManifestFields::LICENSE,
            ManifestFields::DEPENDENCIES,
            ManifestFields::DEV_DEPENDENCIES,
            ManifestFields::FEATURES,
            ManifestFields::DEFAULT_FEATURES,
            ManifestFields::SUPPORTS,
        };

        return valid_fields;
    }

    void print_error_message(Span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list)
    {
        Checks::check_exit(VCPKG_LINE_INFO, error_info_list.size() > 0);

        for (auto&& error_info : error_info_list)
        {
            Checks::check_exit(VCPKG_LINE_INFO, error_info != nullptr);
            if (!error_info->error.empty())
            {
                System::print2(
                    System::Color::error, "Error: while loading ", error_info->name, ":\n", error_info->error, '\n');
            }
        }

        bool have_remaining_fields = false;
        for (auto&& error_info : error_info_list)
        {
            if (!error_info->extra_fields.empty())
            {
                System::print2(System::Color::error,
                               "Error: There are invalid fields in the control or manifest file of ",
                               error_info->name,
                               '\n');
                System::print2("The following fields were not expected:\n");

                for (const auto& pr : error_info->extra_fields)
                {
                    System::print2("    In ", pr.first, ": ", Strings::join(", ", pr.second), "\n");
                }
                have_remaining_fields = true;
            }
        }

        if (have_remaining_fields)
        {
            System::print2("This is the list of valid fields for CONTROL files (case-sensitive): \n\n    ",
                           Strings::join("\n    ", get_list_of_valid_fields()),
                           "\n\n");
            System::print2("And this is the list of valid fields for manifest files: \n\n    ",
                           Strings::join("\n    ", get_list_of_manifest_fields()),
                           "\n\n");
            System::print2("You may need to update the vcpkg binary; try running bootstrap-vcpkg.bat or "
                           "bootstrap-vcpkg.sh to update.\n\n");
        }

        for (auto&& error_info : error_info_list)
        {
            if (!error_info->missing_fields.empty())
            {
                System::print2(System::Color::error,
                               "Error: There are missing fields in the control file of ",
                               error_info->name,
                               '\n');
                System::print2("The following fields were missing:\n");
                for (const auto& pr : error_info->missing_fields)
                {
                    System::print2("    In ", pr.first, ": ", Strings::join(", ", pr.second), "\n");
                }
            }
        }

        for (auto&& error_info : error_info_list)
        {
            if (!error_info->expected_types.empty())
            {
                System::print2(System::Color::error,
                               "Error: There are invalid field types in the CONTROL or manifest file of ",
                               error_info->name,
                               '\n');
                System::print2("The following fields had the wrong types:\n\n");

                for (const auto& pr : error_info->expected_types)
                {
                    System::printf("    %s was expected to be %s\n", pr.first, pr.second);
                }
                System::print2("\n");
            }
        }
    }

    std::string Type::to_string(const Type& t)
    {
        switch (t.type)
        {
            case Type::ALIAS: return "Alias";
            case Type::PORT: return "Port";
            default: return "Unknown";
        }
    }

    Type Type::from_string(const std::string& t)
    {
        if (t == "Alias") return Type{Type::ALIAS};
        if (t == "Port" || t.empty()) return Type{Type::PORT};
        return Type{Type::UNKNOWN};
    }

    bool operator==(const Type& lhs, const Type& rhs) { return lhs.type == rhs.type; }
    bool operator!=(const Type& lhs, const Type& rhs) { return !(lhs == rhs); }

    static void trim_all(std::vector<std::string>& arr)
    {
        for (auto& el : arr)
        {
            el = Strings::trim(std::move(el));
        }
    }

    static ParseExpected<SourceParagraph> parse_source_paragraph(const fs::path& path_to_control, Paragraph&& fields)
    {
        auto origin = path_to_control.u8string();

        ParagraphParser parser(std::move(fields));

        auto spgh = std::make_unique<SourceParagraph>();

        parser.required_field(SourceParagraphFields::NAME, spgh->name);
        parser.required_field(SourceParagraphFields::VERSION, spgh->version);

        auto pv_str = parser.optional_field(SourceParagraphFields::PORT_VERSION);
        if (!pv_str.empty())
        {
            auto pv_opt = Strings::strto<int>(pv_str);
            if (auto pv = pv_opt.get())
            {
                spgh->port_version = *pv;
            }
            else
            {
                parser.add_type_error(SourceParagraphFields::PORT_VERSION, "a non-negative integer");
            }
        }

        spgh->description = Strings::split(parser.optional_field(SourceParagraphFields::DESCRIPTION), '\n');
        trim_all(spgh->description);

        spgh->maintainers = Strings::split(parser.optional_field(SourceParagraphFields::MAINTAINERS), '\n');
        trim_all(spgh->maintainers);

        spgh->homepage = parser.optional_field(SourceParagraphFields::HOMEPAGE);
        TextRowCol textrowcol;
        std::string buf;
        parser.optional_field(SourceParagraphFields::BUILD_DEPENDS, {buf, textrowcol});
        spgh->dependencies = parse_dependencies_list(buf, origin, textrowcol).value_or_exit(VCPKG_LINE_INFO);
        buf.clear();
        parser.optional_field(SourceParagraphFields::DEFAULT_FEATURES, {buf, textrowcol});
        spgh->default_features = parse_default_features_list(buf, origin, textrowcol).value_or_exit(VCPKG_LINE_INFO);

        auto supports_expr = parser.optional_field(SourceParagraphFields::SUPPORTS);
        if (!supports_expr.empty())
        {
            auto maybe_expr = PlatformExpression::parse_platform_expression(
                supports_expr, PlatformExpression::MultipleBinaryOperators::Allow);
            if (auto expr = maybe_expr.get())
            {
                spgh->supports_expression = std::move(*expr);
            }
            else
            {
                parser.add_type_error(SourceParagraphFields::SUPPORTS, "a platform expression");
            }
        }

        spgh->type = Type::from_string(parser.optional_field(SourceParagraphFields::TYPE));
        auto err = parser.error_info(spgh->name.empty() ? origin : spgh->name);
        if (err)
            return err;
        else
            return spgh;
    }

    static ParseExpected<FeatureParagraph> parse_feature_paragraph(const fs::path& path_to_control, Paragraph&& fields)
    {
        auto origin = path_to_control.u8string();
        ParagraphParser parser(std::move(fields));

        auto fpgh = std::make_unique<FeatureParagraph>();

        parser.required_field(SourceParagraphFields::FEATURE, fpgh->name);
        fpgh->description = Strings::split(parser.required_field(SourceParagraphFields::DESCRIPTION), '\n');
        trim_all(fpgh->description);

        fpgh->dependencies =
            parse_dependencies_list(parser.optional_field(SourceParagraphFields::BUILD_DEPENDS), origin)
                .value_or_exit(VCPKG_LINE_INFO);

        auto err = parser.error_info(fpgh->name.empty() ? origin : fpgh->name);
        if (err)
            return err;
        else
            return fpgh;
    }

    ParseExpected<SourceControlFile> SourceControlFile::parse_control_file(
        const fs::path& path_to_control, std::vector<Parse::Paragraph>&& control_paragraphs)
    {
        if (control_paragraphs.size() == 0)
        {
            auto ret = std::make_unique<Parse::ParseControlErrorInfo>();
            ret->name = path_to_control.u8string();
            return ret;
        }

        auto control_file = std::make_unique<SourceControlFile>();

        auto maybe_source = parse_source_paragraph(path_to_control, std::move(control_paragraphs.front()));
        if (const auto source = maybe_source.get())
            control_file->core_paragraph = std::move(*source);
        else
            return std::move(maybe_source).error();

        control_paragraphs.erase(control_paragraphs.begin());

        for (auto&& feature_pgh : control_paragraphs)
        {
            auto maybe_feature = parse_feature_paragraph(path_to_control, std::move(feature_pgh));
            if (const auto feature = maybe_feature.get())
                control_file->feature_paragraphs.emplace_back(std::move(*feature));
            else
                return std::move(maybe_feature).error();
        }

        return control_file;
    }

    static std::vector<std::string> invalid_json_fields(const Json::Object& obj,
                                                        Span<const StringView> known_fields) noexcept
    {
        const auto field_is_unknown = [known_fields](StringView sv) {
            // allow directives
            if (sv.size() != 0 && *sv.begin() == '$')
            {
                return false;
            }
            return std::find(known_fields.begin(), known_fields.end(), sv) == known_fields.end();
        };

        std::vector<std::string> res;
        for (const auto& kv : obj)
        {
            if (field_is_unknown(kv.first))
            {
                res.push_back(kv.first.to_string());
            }
        }

        return res;
    }

    struct StringField : Json::VisitorCrtpBase<StringField>
    {
        using type = std::string;
        StringView type_name() { return type_name_; }

        Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv) { return sv.to_string(); }

        explicit StringField(StringView type_name_) : type_name_(type_name_) { }

    private:
        StringView type_name_;
    };

    struct BooleanField : Json::VisitorCrtpBase<BooleanField>
    {
        using type = bool;
        StringView type_name() { return "a boolean"; }

        Optional<bool> visit_boolean(Json::Reader&, StringView, bool b) { return b; }
    };

    enum class AllowEmpty : bool
    {
        No,
        Yes,
    };

    template<class T>
    struct ArrayField : Json::VisitorCrtpBase<ArrayField<T>>
    {
        using type = std::vector<typename T::type>;

        StringView type_name() { return type_name_; }

        ArrayField(StringView type_name_, AllowEmpty allow_empty, T&& t = {})
            : type_name_(type_name_), underlying_visitor_(static_cast<T&&>(t)), allow_empty_(allow_empty)
        {
        }

        Optional<type> visit_array(Json::Reader& r, StringView key, const Json::Array& arr)
        {
            if (allow_empty_ == AllowEmpty::No && arr.size() == 0)
            {
                return nullopt;
            }
            return r.array_elements(arr, key, underlying_visitor_);
        }

    private:
        StringView type_name_;
        T underlying_visitor_;
        AllowEmpty allow_empty_;
    };

    struct ParagraphField : Json::VisitorCrtpBase<ParagraphField>
    {
        using type = std::vector<std::string>;
        StringView type_name() { return "a string or array of strings"; }

        Optional<std::vector<std::string>> visit_string(Json::Reader&, StringView, StringView sv)
        {
            std::vector<std::string> out;
            out.push_back(sv.to_string());
            return out;
        }

        Optional<std::vector<std::string>> visit_array(Json::Reader& r, StringView key, const Json::Array& arr)
        {
            return r.array_elements(arr, key, StringField{"a string"});
        }
    };

    struct IdentifierField : Json::VisitorCrtpBase<IdentifierField>
    {
        using type = std::string;
        StringView type_name() { return "an identifier"; }

        // [a-z0-9]+(-[a-z0-9]+)*, plus not any of {prn, aux, nul, con, lpt[1-9], com[1-9], core, default}
        static bool is_ident(StringView sv)
        {
            static const std::regex BASIC_IDENTIFIER = std::regex(R"([a-z0-9]+(-[a-z0-9]+)*)");

            // we only check for lowercase in RESERVED since we already remove all
            // strings with uppercase letters from the basic check
            static const std::regex RESERVED = std::regex(R"(prn|aux|nul|con|(lpt|com)[1-9]|core|default)");

            if (!std::regex_match(sv.begin(), sv.end(), BASIC_IDENTIFIER))
            {
                return false; // we're not even in the shape of an identifier
            }

            if (std::regex_match(sv.begin(), sv.end(), RESERVED))
            {
                return false; // we're a reserved identifier
            }

            return true;
        }

        Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv)
        {
            if (is_ident(sv))
            {
                return sv.to_string();
            }
            else
            {
                return nullopt;
            }
        }
    };

    struct PackageNameField : Json::VisitorCrtpBase<PackageNameField>
    {
        using type = std::string;
        StringView type_name() { return "a package name"; }

        static bool is_package_name(StringView sv)
        {
            if (sv.size() == 0)
            {
                return false;
            }

            for (const auto& ident : Strings::split(sv, '.'))
            {
                if (!IdentifierField::is_ident(ident))
                {
                    return false;
                }
            }

            return true;
        }

        Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv)
        {
            if (!is_package_name(sv))
            {
                return nullopt;
            }
            return sv.to_string();
        }
    };

    // We "parse" this so that we can add actual license parsing at some point in the future
    // without breaking anyone
    struct LicenseExpressionField : Json::VisitorCrtpBase<LicenseExpressionField>
    {
        using type = std::string;
        StringView type_name() { return "an SPDX license expression"; }

        enum class Mode
        {
            ExpectExpression,
            ExpectContinue,
            ExpectException,
        };

        constexpr static StringView EXPRESSION_WORDS[] = {
            "WITH",
            "AND",
            "OR",
        };
        constexpr static StringView VALID_LICENSES[] =
#include "spdx-licenses.inc"
            ;

        constexpr static StringView VALID_EXCEPTIONS[] =
#include "spdx-exceptions.inc"
            ;

        Optional<std::string> visit_string(Json::Reader&, StringView, StringView sv)
        {
            Mode mode = Mode::ExpectExpression;
            size_t open_parens = 0;
            std::string current_word;

            const auto check_current_word = [&current_word, &mode] {
                if (current_word.empty())
                {
                    return true;
                }

                Span<const StringView> valid_ids;
                bool case_sensitive = false;
                switch (mode)
                {
                    case Mode::ExpectExpression:
                        valid_ids = VALID_LICENSES;
                        mode = Mode::ExpectContinue;
                        // a single + is allowed on the end of licenses
                        if (current_word.back() == '+')
                        {
                            current_word.pop_back();
                        }
                        break;
                    case Mode::ExpectContinue:
                        valid_ids = EXPRESSION_WORDS;
                        mode = Mode::ExpectExpression;
                        case_sensitive = true;
                        break;
                    case Mode::ExpectException:
                        valid_ids = VALID_EXCEPTIONS;
                        mode = Mode::ExpectContinue;
                        break;
                }

                const auto equal = [&](StringView sv) {
                    if (case_sensitive)
                    {
                        return sv == current_word;
                    }
                    else
                    {
                        return Strings::case_insensitive_ascii_equals(sv, current_word);
                    }
                };

                if (std::find_if(valid_ids.begin(), valid_ids.end(), equal) == valid_ids.end())
                {
                    return false;
                }

                if (current_word == "WITH")
                {
                    mode = Mode::ExpectException;
                }

                current_word.clear();
                return true;
            };

            for (const auto& ch : sv)
            {
                if (ch == ' ' || ch == '\t')
                {
                    if (!check_current_word())
                    {
                        return nullopt;
                    }
                }
                else if (ch == '(')
                {
                    if (!check_current_word())
                    {
                        return nullopt;
                    }
                    if (mode != Mode::ExpectExpression)
                    {
                        return nullopt;
                    }
                    ++open_parens;
                }
                else if (ch == ')')
                {
                    if (!check_current_word())
                    {
                        return nullopt;
                    }
                    if (mode != Mode::ExpectContinue)
                    {
                        return nullopt;
                    }
                    if (open_parens == 0)
                    {
                        return nullopt;
                    }
                    --open_parens;
                }
                else
                {
                    current_word.push_back(ch);
                }
            }

            if (!check_current_word())
            {
                return nullopt;
            }
            else
            {
                return sv.to_string();
            }
        }
    };

    struct PlatformExprField : Json::VisitorCrtpBase<PlatformExprField>
    {
        using type = PlatformExpression::Expr;
        StringView type_name() { return "a platform expression"; }

        Optional<PlatformExpression::Expr> visit_string(Json::Reader&, StringView, StringView sv)
        {
            auto opt =
                PlatformExpression::parse_platform_expression(sv, PlatformExpression::MultipleBinaryOperators::Deny);
            if (auto res = opt.get())
            {
                return std::move(*res);
            }
            else
            {
                Debug::print("Failed to parse platform expression: ", opt.error(), "\n");
                return nullopt;
            }
        }
    };

    struct DependencyField : Json::VisitorCrtpBase<DependencyField>
    {
        using type = Dependency;
        StringView type_name() { return "a dependency"; }

        constexpr static StringView NAME = "name";
        constexpr static StringView FEATURES = "features";
        constexpr static StringView DEFAULT_FEATURES = "default-features";
        constexpr static StringView PLATFORM = "platform";
        constexpr static StringView KNOWN_FIELDS[] = {NAME, FEATURES, DEFAULT_FEATURES, PLATFORM};

        Optional<Dependency> visit_string(Json::Reader&, StringView, StringView sv)
        {
            if (!PackageNameField::is_package_name(sv))
            {
                return nullopt;
            }

            Dependency dep;
            dep.name = sv.to_string();
            return dep;
        }

        Optional<Dependency> visit_object(Json::Reader& r, StringView, const Json::Object& obj)
        {
            {
                auto extra_fields = invalid_json_fields(obj, KNOWN_FIELDS);
                if (!extra_fields.empty())
                {
                    r.error().add_extra_fields(type_name().to_string(), std::move(extra_fields));
                }
            }

            Dependency dep;
            r.required_object_field(type_name(), obj, NAME, dep.name, PackageNameField{});
            r.optional_object_field(
                obj, FEATURES, dep.features, ArrayField<IdentifierField>{"an array of identifiers", AllowEmpty::Yes});

            bool default_features = true;
            r.optional_object_field(obj, DEFAULT_FEATURES, default_features, BooleanField{});
            if (!default_features)
            {
                dep.features.push_back("core");
            }

            r.optional_object_field(obj, PLATFORM, dep.platform, PlatformExprField{});

            return dep;
        }
    };

    struct FeatureField : Json::VisitorCrtpBase<FeatureField>
    {
        using type = std::unique_ptr<FeatureParagraph>;
        StringView type_name() { return "a feature"; }

        constexpr static StringView NAME = "name";
        constexpr static StringView DESCRIPTION = "description";
        constexpr static StringView DEPENDENCIES = "dependencies";

        Optional<std::unique_ptr<FeatureParagraph>> visit_object(Json::Reader& r, StringView, const Json::Object& obj)
        {
            auto feature = std::make_unique<FeatureParagraph>();

            r.required_object_field(type_name(), obj, NAME, feature->name, IdentifierField{});
            r.required_object_field(type_name(), obj, DESCRIPTION, feature->description, ParagraphField{});
            r.optional_object_field(obj,
                                    DEPENDENCIES,
                                    feature->dependencies,
                                    ArrayField<DependencyField>{"an array of dependencies", AllowEmpty::Yes});

            return std::move(feature);
        }
    };

    Parse::ParseExpected<SourceControlFile> SourceControlFile::parse_manifest_file(const fs::path& path_to_manifest,
                                                                                   const Json::Object& manifest)
    {
        struct JsonErr final : Json::ReaderError
        {
            ParseControlErrorInfo pcei;

            void add_missing_field(std::string&& type, std::string&& key) override
            {
                pcei.missing_fields[std::move(type)].push_back(std::move(key));
            }
            void add_expected_type(std::string&& key, std::string&& expected_type) override
            {
                pcei.expected_types.emplace(std::move(key), std::move(expected_type));
            }
            void add_extra_fields(std::string&& type, std::vector<std::string>&& fields) override
            {
                if (!fields.empty())
                {
                    auto& fields_for_type = pcei.extra_fields[std::move(type)];
                    fields_for_type.insert(fields_for_type.end(), fields.begin(), fields.end());
                }
            }
            void add_mutually_exclusive_fields(std::string&& type, std::vector<std::string>&& fields) override
            {
                if (!fields.empty())
                {
                    auto& fields_for_type = pcei.mutually_exclusive_fields[std::move(type)];
                    fields_for_type.insert(fields_for_type.end(), fields.begin(), fields.end());
                }
            }
        } err = {};
        auto visit = Json::Reader{&err};

        err.pcei.name = path_to_manifest.u8string();
        {
            auto extra_fields = invalid_json_fields(manifest, get_list_of_manifest_fields());
            if (!extra_fields.empty())
            {
                err.pcei.extra_fields["manifest"] = std::move(extra_fields);
            }
        }

        auto control_file = std::make_unique<SourceControlFile>();
        control_file->core_paragraph = std::make_unique<SourceParagraph>();

        auto& spgh = control_file->core_paragraph;

        constexpr static StringView type_name = "vcpkg.json";
        visit.required_object_field(type_name, manifest, ManifestFields::NAME, spgh->name, IdentifierField{});
        visit.required_object_field(
            type_name, manifest, ManifestFields::VERSION, spgh->version, StringField{"a version"});
        visit.optional_object_field(manifest, ManifestFields::MAINTAINERS, spgh->maintainers, ParagraphField{});
        visit.optional_object_field(manifest, ManifestFields::DESCRIPTION, spgh->description, ParagraphField{});
        visit.optional_object_field(manifest, ManifestFields::HOMEPAGE, spgh->homepage, StringField{"a url"});
        visit.optional_object_field(manifest, ManifestFields::DOCUMENTATION, spgh->documentation, StringField{"a url"});
        visit.optional_object_field(manifest, ManifestFields::LICENSE, spgh->license, LicenseExpressionField{});
        visit.optional_object_field(manifest,
                                    ManifestFields::DEPENDENCIES,
                                    spgh->dependencies,
                                    ArrayField<DependencyField>{"an array of dependencies", AllowEmpty::Yes});

        if (manifest.contains(ManifestFields::DEV_DEPENDENCIES))
        {
            System::print2(System::Color::error, "dev_dependencies are not yet supported");
            Checks::exit_fail(VCPKG_LINE_INFO);
        }

        visit.optional_object_field(manifest, ManifestFields::SUPPORTS, spgh->supports_expression, PlatformExprField{});

        visit.optional_object_field(manifest,
                                    ManifestFields::DEFAULT_FEATURES,
                                    spgh->default_features,
                                    ArrayField<IdentifierField>{"an array of identifiers", AllowEmpty::Yes});

        visit.optional_object_field(manifest,
                                    ManifestFields::FEATURES,
                                    control_file->feature_paragraphs,
                                    ArrayField<FeatureField>{"an array of feature definitions", AllowEmpty::Yes});

        if (err.pcei.has_error())
        {
            return std::make_unique<ParseControlErrorInfo>(std::move(err.pcei));
        }

        return std::move(control_file);
    }

    Optional<const FeatureParagraph&> SourceControlFile::find_feature(const std::string& featurename) const
    {
        auto it = Util::find_if(feature_paragraphs,
                                [&](const std::unique_ptr<FeatureParagraph>& p) { return p->name == featurename; });
        if (it != feature_paragraphs.end())
            return **it;
        else
            return nullopt;
    }
    Optional<const std::vector<Dependency>&> SourceControlFile::find_dependencies_for_feature(
        const std::string& featurename) const
    {
        if (featurename == "core")
        {
            return core_paragraph->dependencies;
        }
        else if (auto p_feature = find_feature(featurename).get())
            return p_feature->dependencies;
        else
            return nullopt;
    }

    std::vector<FullPackageSpec> filter_dependencies(const std::vector<vcpkg::Dependency>& deps,
                                                     Triplet t,
                                                     const std::unordered_map<std::string, std::string>& cmake_vars)
    {
        std::vector<FullPackageSpec> ret;
        for (auto&& dep : deps)
        {
            if (dep.platform.evaluate(cmake_vars))
            {
                ret.emplace_back(FullPackageSpec({dep.name, t}, dep.features));
            }
        }
        return ret;
    }
}
