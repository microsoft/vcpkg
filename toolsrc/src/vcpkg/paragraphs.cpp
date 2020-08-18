#include <vcpkg/base/files.h>
#include <vcpkg/base/parse.h>
#include <vcpkg/base/system.debug.h>
#include <vcpkg/base/system.print.h>
#include <vcpkg/base/util.h>

#include <vcpkg/binaryparagraph.h>
#include <vcpkg/paragraphparser.h>
#include <vcpkg/paragraphs.h>

using namespace vcpkg::Parse;
using namespace vcpkg;

namespace vcpkg::Parse
{
    static Optional<std::pair<std::string, TextRowCol>> remove_field(Paragraph* fields, const std::string& fieldname)
    {
        auto it = fields->find(fieldname);
        if (it == fields->end())
        {
            return nullopt;
        }

        auto value = std::move(it->second);
        fields->erase(it);
        return value;
    }

    void ParagraphParser::required_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (const auto field = maybe_field.get())
            out = std::move(*field);
        else
            missing_fields.push_back(fieldname);
    }
    void ParagraphParser::optional_field(const std::string& fieldname, std::pair<std::string&, TextRowCol&> out)
    {
        auto maybe_field = remove_field(&fields, fieldname);
        if (auto field = maybe_field.get()) out = std::move(*field);
    }
    void ParagraphParser::required_field(const std::string& fieldname, std::string& out)
    {
        TextRowCol ignore;
        required_field(fieldname, {out, ignore});
    }
    std::string ParagraphParser::optional_field(const std::string& fieldname)
    {
        std::string out;
        TextRowCol ignore;
        optional_field(fieldname, {out, ignore});
        return out;
    }
    std::string ParagraphParser::required_field(const std::string& fieldname)
    {
        std::string out;
        TextRowCol ignore;
        required_field(fieldname, {out, ignore});
        return out;
    }

    std::unique_ptr<ParseControlErrorInfo> ParagraphParser::error_info(const std::string& name) const
    {
        if (!fields.empty() || !missing_fields.empty())
        {
            auto err = std::make_unique<ParseControlErrorInfo>();
            err->name = name;
            err->extra_fields["CONTROL"] = Util::extract_keys(fields);
            err->missing_fields["CONTROL"] = std::move(missing_fields);
            err->expected_types = std::move(expected_types);
            return err;
        }
        return nullptr;
    }

    template<class T, class F>
    static Optional<std::vector<T>> parse_list_until_eof(StringLiteral plural_item_name, Parse::ParserBase& parser, F f)
    {
        std::vector<T> ret;
        parser.skip_whitespace();
        if (parser.at_eof()) return std::vector<T>{};
        do
        {
            auto item = f(parser);
            if (!item) return nullopt;
            ret.push_back(std::move(item).value_or_exit(VCPKG_LINE_INFO));
            parser.skip_whitespace();
            if (parser.at_eof()) return {std::move(ret)};
            if (parser.cur() != ',')
            {
                parser.add_error(Strings::concat("expected ',' or end of text in ", plural_item_name, " list"));
                return nullopt;
            }
            parser.next();
            parser.skip_whitespace();
        } while (true);
    }

    ExpectedS<std::vector<std::string>> parse_default_features_list(const std::string& str,
                                                                    StringView origin,
                                                                    TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<std::string>("default features", parser, &parse_feature_name);
        if (!opt) return {parser.get_error()->format(), expected_right_tag};
        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<ParsedQualifiedSpecifier>> parse_qualified_specifier_list(const std::string& str,
                                                                                    StringView origin,
                                                                                    TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<ParsedQualifiedSpecifier>(
            "dependencies", parser, [](ParserBase& parser) { return parse_qualified_specifier(parser); });
        if (!opt) return {parser.get_error()->format(), expected_right_tag};

        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
    ExpectedS<std::vector<Dependency>> parse_dependencies_list(const std::string& str,
                                                               StringView origin,
                                                               TextRowCol textrowcol)
    {
        auto parser = Parse::ParserBase(str, origin, textrowcol);
        auto opt = parse_list_until_eof<Dependency>("dependencies", parser, [](ParserBase& parser) {
            auto loc = parser.cur_loc();
            return parse_qualified_specifier(parser).then([&](ParsedQualifiedSpecifier&& pqs) -> Optional<Dependency> {
                if (pqs.triplet)
                {
                    parser.add_error("triplet specifier not allowed in this context", loc);
                    return nullopt;
                }
                return Dependency{pqs.name, pqs.features.value_or({}), pqs.platform.value_or({})};
            });
        });
        if (!opt) return {parser.get_error()->format(), expected_right_tag};

        return {std::move(opt).value_or_exit(VCPKG_LINE_INFO), expected_left_tag};
    }
}

namespace vcpkg::Paragraphs
{
    struct PghParser : private Parse::ParserBase
    {
    private:
        void get_fieldvalue(std::string& fieldvalue)
        {
            fieldvalue.clear();

            do
            {
                // scan to end of current line (it is part of the field value)
                Strings::append(fieldvalue, match_until(is_lineend));
                skip_newline();

                if (cur() != ' ') return;
                auto spacing = skip_tabs_spaces();
                if (is_lineend(cur())) return add_error("unexpected end of line, to span a blank line use \"  .\"");
                Strings::append(fieldvalue, "\n", spacing);
            } while (true);
        }

        void get_fieldname(std::string& fieldname)
        {
            fieldname = match_zero_or_more(is_alphanumdash).to_string();
            if (fieldname.empty()) return add_error("expected fieldname");
        }

        void get_paragraph(Paragraph& fields)
        {
            fields.clear();
            std::string fieldname;
            std::string fieldvalue;
            do
            {
                if (cur() == '#')
                {
                    skip_line();
                    continue;
                }

                auto loc = cur_loc();
                get_fieldname(fieldname);
                if (cur() != ':') return add_error("expected ':' after field name");
                if (Util::Sets::contains(fields, fieldname)) return add_error("duplicate field", loc);
                next();
                skip_tabs_spaces();
                auto rowcol = cur_rowcol();
                get_fieldvalue(fieldvalue);

                fields.emplace(fieldname, std::make_pair(fieldvalue, rowcol));
            } while (!is_lineend(cur()));
        }

    public:
        PghParser(StringView text, StringView origin) : Parse::ParserBase(text, origin) { }

        ExpectedS<std::vector<Paragraph>> get_paragraphs()
        {
            std::vector<Paragraph> paragraphs;

            skip_whitespace();
            while (!at_eof())
            {
                paragraphs.emplace_back();
                get_paragraph(paragraphs.back());
                match_zero_or_more(is_lineend);
            }
            if (get_error()) return get_error()->format();

            return paragraphs;
        }
    };

    ExpectedS<Paragraph> parse_single_paragraph(const std::string& str, const std::string& origin)
    {
        auto pghs = PghParser(str, origin).get_paragraphs();

        if (auto p = pghs.get())
        {
            if (p->size() != 1) return {"There should be exactly one paragraph", expected_right_tag};
            return std::move(p->front());
        }
        else
        {
            return pghs.error();
        }
    }

    ExpectedS<Paragraph> get_single_paragraph(const Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_single_paragraph(*spgh, control_path.u8string());
        }

        return contents.error().message();
    }

    ExpectedS<std::vector<Paragraph>> get_paragraphs(const Files::Filesystem& fs, const fs::path& control_path)
    {
        const Expected<std::string> contents = fs.read_contents(control_path);
        if (auto spgh = contents.get())
        {
            return parse_paragraphs(*spgh, control_path.u8string());
        }

        return contents.error().message();
    }

    ExpectedS<std::vector<Paragraph>> parse_paragraphs(const std::string& str, const std::string& origin)
    {
        return PghParser(str, origin).get_paragraphs();
    }

    bool is_port_directory(const Files::Filesystem& fs, const fs::path& path)
    {
        return fs.exists(path / fs::u8path("CONTROL")) || fs.exists(path / fs::u8path("vcpkg.json"));
    }

    ParseExpected<SourceControlFile> try_load_manifest(const Files::Filesystem& fs,
                                                       const std::string& port_name,
                                                       const fs::path& path_to_manifest,
                                                       std::error_code& ec)
    {
        auto error_info = std::make_unique<ParseControlErrorInfo>();
        auto res = Json::parse_file(fs, path_to_manifest, ec);
        if (ec) return error_info;

        if (auto val = res.get())
        {
            if (val->first.is_object())
            {
                return SourceControlFile::parse_manifest_file(path_to_manifest, val->first.object());
            }
            else
            {
                error_info->name = port_name;
                error_info->error = "Manifest files must have a top-level object";
                return error_info;
            }
        }
        else
        {
            error_info->name = port_name;
            error_info->error = res.error()->format();
            return error_info;
        }
    }

    ParseExpected<SourceControlFile> try_load_port(const Files::Filesystem& fs, const fs::path& path)
    {
        const auto path_to_manifest = path / fs::u8path("vcpkg.json");
        const auto path_to_control = path / fs::u8path("CONTROL");
        if (fs.exists(path_to_manifest))
        {
            vcpkg::Checks::check_exit(VCPKG_LINE_INFO,
                                      !fs.exists(path_to_control),
                                      "Found both manifest and CONTROL file in port %s; please rename one or the other",
                                      path.u8string());

            std::error_code ec;
            auto res = try_load_manifest(fs, path.filename().u8string(), path_to_manifest, ec);
            if (ec)
            {
                auto error_info = std::make_unique<ParseControlErrorInfo>();
                error_info->name = path.filename().u8string();
                error_info->error = Strings::format(
                    "Failed to load manifest file for port: %s\n", path_to_manifest.u8string(), ec.message());
            }

            return res;
        }
        ExpectedS<std::vector<Paragraph>> pghs = get_paragraphs(fs, path_to_control);
        if (auto vector_pghs = pghs.get())
        {
            return SourceControlFile::parse_control_file(path_to_control, std::move(*vector_pghs));
        }
        auto error_info = std::make_unique<ParseControlErrorInfo>();
        error_info->name = path.filename().u8string();
        error_info->error = pghs.error();
        return error_info;
    }

    ExpectedS<BinaryControlFile> try_load_cached_package(const VcpkgPaths& paths, const PackageSpec& spec)
    {
        ExpectedS<std::vector<Paragraph>> pghs =
            get_paragraphs(paths.get_filesystem(), paths.package_dir(spec) / "CONTROL");

        if (auto p = pghs.get())
        {
            BinaryControlFile bcf;
            bcf.core_paragraph = BinaryParagraph(p->front());
            p->erase(p->begin());

            bcf.features =
                Util::fmap(*p, [&](auto&& raw_feature) -> BinaryParagraph { return BinaryParagraph(raw_feature); });

            return bcf;
        }

        return pghs.error();
    }

    LoadResults try_load_all_ports(const Files::Filesystem& fs, const fs::path& ports_dir)
    {
        LoadResults ret;
        auto port_dirs = fs.get_files_non_recursive(ports_dir);
        Util::sort(port_dirs);
        Util::erase_remove_if(port_dirs, [&](auto&& port_dir_entry) {
            return fs.is_regular_file(port_dir_entry) && port_dir_entry.filename() == ".DS_Store";
        });

        for (auto&& path : port_dirs)
        {
            auto maybe_spgh = try_load_port(fs, path);
            if (const auto spgh = maybe_spgh.get())
            {
                ret.paragraphs.emplace_back(std::move(*spgh));
            }
            else
            {
                ret.errors.emplace_back(std::move(maybe_spgh).error());
            }
        }
        return ret;
    }

    std::vector<std::unique_ptr<SourceControlFile>> load_all_ports(const Files::Filesystem& fs,
                                                                   const fs::path& ports_dir)
    {
        auto results = try_load_all_ports(fs, ports_dir);
        if (!results.errors.empty())
        {
            if (Debug::g_debugging)
            {
                print_error_message(results.errors);
            }
            else
            {
                for (auto&& error : results.errors)
                {
                    System::print2(
                        System::Color::warning, "Warning: an error occurred while parsing '", error->name, "'\n");
                }
                System::print2(System::Color::warning,
                               "Use '--debug' to get more information about the parse failures.\n\n");
            }
        }
        return std::move(results.paragraphs);
    }
}
