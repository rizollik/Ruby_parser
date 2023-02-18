This program parses products from the category provided on the petsonic.com website. It extracts the information from the HTML code of the product pages and with the help of API queries. The result is a CSV file with the information about each product (name, price, etc.).

## Libraries Used

- open-uri

open-uri is a library that allows you to open URLs and read their contents.

- nokogiri

nokogiri is a library that is used for parsing HTML and XML documents.

- csv

csv is a library for reading and writing CSV files.

- net/http

net/http is a library for making HTTP requests.

- json

json is a library for reading and writing JSON data.

## Description

The parser works by first accessing the web page and downloading its content. Once the content is downloaded, the Nokogiri library is used to parse the HTML and extract the desired data. The XPath query language is then used to select certain nodes from the parsed HTML and the Open-URI library is used to open the extracted data. Finally, the CSV library is used to write the extracted data to a CSV file. The result of the parser is a CSV file containing the data extracted from the web page. This file can then be used in other applications and environments.