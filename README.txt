Author: Corey Holt
Date: 11/26/2013

Used together with lex, clexer.l finds all of the identifiers in 
a C file, tracks the line numbers they appear on, and prints a 
listing of the identifiers sorted by ASCII ordering. The line 
numbers on which each identifier occurs are printed as a 
comma-separated list for each identifier.

The included parsetest.c file can be used for a sample lexical 
analysis.