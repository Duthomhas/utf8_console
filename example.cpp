// Copyright 2019 Michael Thomas Greer
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE_1_0.txt
//  or copy at https://www.boost.org/LICENSE_1_0.txt )

// This example program should compile and behave identically
// on Windows with utf8_console and on *nixen as-is.
//
// Use it by providing Unicode as:
//  • command line arguments
//  • keyboard input
//  • redirected file input
//
// The file "input-example.txt" is useful for this. For example:
//
//   example.msvc.argv.exe ¿Cómo estás? < input-example.txt

#include <iostream>
#include <limits>
#include <string>

#ifndef USE_ARGV
#define USE_ARGV 0
#endif

namespace std
{
  template <class CharT, class Traits>
  std::basic_istream <CharT, Traits> & endl( std::basic_istream <CharT, Traits> & ins )
  {
    return ins.ignore( std::numeric_limits <std::streamsize> ::max(), '\n' );
  }
}

#if USE_ARGV == 1

int main( int argc, char** argv )
{
  for (int n = 0; n < argc; n++)
  {
    std::cout << n << " : " << argv[n] << " : ";
    for (const char* p = argv[n]; *p; ++p) std::cout << std::hex << ((unsigned)*p & 0xFF) << " ";
    std::cout << "\n";
  }

#else

int main()
{
#endif

  std::string s;
  int         n;

  std::cout << "¿Qué tal?\n\n";

  std::cout << "s? ";
  getline( std::cin, s );
  std::cout << "size = " << s.size() << " : " << s << "\n";
  for (char c : s) std::cout << std::hex << ((unsigned)c & 0xFF) << " ";
  std::cout << "\n\n";

  std::cout << "n? ";
  std::cin >> n >> std::endl;
  std::cout << "n = " << std::dec << n << "\n\n";

  std::cout << "s? ";
  std::cin >> s;
  std::cout << "size = " << s.size() << " : " << s << "\n";
  for (char c : s) std::cout << std::hex << ((unsigned)c & 0xFF) << " ";
  std::cout << "\n\n";
}
