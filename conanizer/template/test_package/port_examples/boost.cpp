#include <boost/regex.hpp>
#include <iostream>
#include <string>

int main()
{
    std::string line = "Subject: Regex working!";
    boost::regex pat( "^Subject: (Re: |Aw: )*(.*)" );

    boost::smatch matches;
    if (boost::regex_match(line, matches, pat))
        std::cout << matches[2] << std::endl;
    
}