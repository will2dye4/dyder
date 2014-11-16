# dyder - A simple Web spider

dyder is a Web spider whose goal is simple: discover as many domains as possible. It is not concerned with downloading and indexing Web sites;
it just wants to find out what sites are out there. I wrote this application as my first foray into Ruby programming. As of now, it is quite
simple in its functionality: You provide it a keyword (which currently has to be the title of an English-language Wikipedia article), and it
will discover up to 50 sites by scanning Web pages for links, starting with the English-language Wikipedia page for the keyword. I am currently
limiting the number of results to 50 so that the program will run fairly quickly; in the future I will add politeness (i.e., reading robots.txt
before crawling a site and possibly rate-limiting) and expand the program to index a larger number of sites.