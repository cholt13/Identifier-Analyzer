%{
/*
 *  Corey Holt - cmh09h
 *  COP4342
 *  11/26/2013
 *  Assignment 11
 *
 *  This lex specification file finds all of the identifiers in a C
 *  file, tracks the line numbers they appear on, and prints a listing
 *  of the identifiers sorted by ASCII ordering. The line numbers on
 *  which each identifier occurs is printed as a comma-separated list
 *  for each identifier.
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/* Emulate boolean values for integers */
#define TRUE 1
#define FALSE 0

/* Keep track of current line of input during lexical analysis */
int yyline = 1;

/* Use struct for storing identifiers and their line numbers */
typedef struct Identifier
{
	char* id_str;
	int line_array[20];
	int line_index;
	int need_to_print;
} Identifier;

/* Will have max of 1000 identifiers, so make array of 1000 Identifiers */
Identifier ids[1000];
/* Keep track of next empty slot in identifiers array */
int ids_index = 0;
/* Keep track of the max length out of all identifiers for formatting */
int max_id_len = 0;

/* Function prototypes to be defined in bottom section of lex file */
extern void record_id(char*, int);
extern void print_ids();
extern void clean_up();
%}

letter	[a-zA-Z_]
digit	[0-9]
id	{letter}({letter}|{digit})*

%%
\n		{
			/* Lex is moving on to next line of input */
			++yyline;
			/*
			 * For following reserved words, can have lex
			 * simply do nothing, because they cannot be
			 * identifiers
			 */
		}
auto		;
break		;
case		;
char		;
continue	;
default		;
do		;
double		;
else		;
extern		;
float		;
for		;
goto		;
if		;
int		;
long		;
register	;
return		;
short		;
sizeof		;
static		;
struct		;
switch		;
typedef		;
union		;
unsigned	;
void		;
while		;
\#.*\n		{++yyline; /* No identifiers in preprocessor commands */}
\'.{1,2}\'	;
\".*\"		;
\/\/.*\n	{++yyline; /* Can ignore rest of line in full line comment */}
\/\*.*\*\/	;
{id}		{
			/*
			 * Identifier recognized, so pass its string and
			 * line number to record_id function for storing
			 */
			record_id(yytext, yyline);
			/* Update the max length of an id if necessary */
			if (strlen(yytext) > max_id_len)
			{
				max_id_len = strlen(yytext);
			}
		}
.		;

%%
int main()
{
	/* Call yylex() to perform the lexical analysis of the input */
	yylex();
	/*
	 * After lex finishes, all identifiers and their line numbers have
	 * been stored, so call print_ids() to generate sorted output
	 */
	print_ids();
	clean_up();
	return 0;
}

/*
 * This function adds an identifier and the line number where lex recognized
 * it to the ids array. If an identifier has already been discovered, then
 * the new line number is added to the identifier's line_array if it is not
 * a duplicate line number. If the identifier has not been discovered yet,
 * then it adds the identifier's string and line number to the Identifier
 * struct contained in the next open slot in the ids array. 
 */
void record_id(char* id, int line)
{
	/*
	 * Loop over all ids in ids array, looking for the id string
	 * parameter. If found, merely need to add the new line number
	 * to that id's line_array if it is not a duplicate number.
	 */
	int i;
	for (i = 0; i < ids_index; ++i)
	{
		/* Check if the id in this slot is equal to the parameter */
		if (!strcmp(id, ids[i].id_str))
		{
			/* Do not add line number if duplicate */
			if (ids[i].line_array[ids[i].line_index - 1] == line)
			{
				return;
			}
			/* Add line number and increment line_array index */
			ids[i].line_array[ids[i].line_index] = line;
			++ids[i].line_index;
			return;
		}
	}

	/* Only proceed to following code if this is a new identifier */

	/* Allocate dynamic memory for the id string */
	ids[ids_index].id_str = malloc(strlen(id) + 1);
	/* Copy the id string recognized by lex into the dynamic memory */
	strcpy(ids[ids_index].id_str, id);
	/* Since this is a new id record, put the line # in first slot */
	ids[ids_index].line_array[0] = line;
	/* Next empty slot of line_array is now slot 1, so store this */
	ids[ids_index].line_index = 1;
	/* This new id will need to be printed later */
	ids[ids_index].need_to_print = TRUE;
	/* A new id has been stored, so increment the global id counter */
	++ids_index;
}

/* 
 * This function prints the identifiers contained in the ids array and the
 * line numbers on which they are found in the input. Identifiers are
 * printed according to ASCII ordering.
 */
void print_ids()
{
	int num_printed = 0;
	/* 
	 * next_to_print is updated when a lower ASCII order id is found
	 * that still needs to be printed
	 */
	int next_to_print;
	int i;
	int j;

	/* Need to print all ids in the ids array */
	while (num_printed < ids_index)
	{
 
	/* Loop to find the next id that still needs to be printed */
	for (i = 0; i < ids_index; ++i)
	{
		/* If id in this slot has been printed already, go to next */
		if (ids[i].need_to_print == FALSE)
		{
			continue;
		}
		else
		{
			/* i is the earliest need_to_print id */
			next_to_print = i;
			break;
		}
	}

	/* 
	 * If this is not the last id that needs printing, then must check
	 * if any other ids that still need printing have a lower ASCII
	 * order than the earliest id selected above
	 */
	if (num_printed != ids_index - 1)
	{
		/* 
	 	 * Perform running update of next id to print if lower
		 * ASCII order word is found that still needs printing
		 */
		for (j = next_to_print; j < ids_index; ++j)
		{
			/* If id has already been printed, do not compare */
			if (ids[j].need_to_print == FALSE)
			{
				continue;
			}

			/* Need to compare lowercase versions of strings to
			   ensure proper alphabetic ordering, so convert */
			char lc_id_str1[81];
			strcpy(lc_id_str1, ids[j].id_str);
			int k;
			for (k = 0; lc_id_str1[k]; ++k)
			{
				lc_id_str1[k] = tolower(lc_id_str1[k]);
			}
			char lc_id_str2[81];
			strcpy(lc_id_str2, ids[next_to_print].id_str);
			for (k = 0; lc_id_str2[k]; ++k)
			{
				lc_id_str2[k] = tolower(lc_id_str2[k]);
			}

			/* Compare the lowercase versions of the strings */
			if (strcmp(lc_id_str1, lc_id_str2) < 0)
			{
				/*
				 * Lower ASCII order word that still needs
				 * printing has been found, so select
				 * that one as next_to_print instead
				 */
				next_to_print = j;
			}
		}
	}

	/*
	 * next_to_print now holds index of next identifier yet to be printed
	 * in ASCII order, so print the id string right-justified according
	 * to the max id length determined during lexical analysis, followed
	 * by a colon and then the list of line numbers on which that id
	 * appeared in the input
	 */
	printf("%*s: ", max_id_len, ids[next_to_print].id_str);
	for (j = 0; j < ids[next_to_print].line_index - 1; ++j)
	{
		printf("%d, ", ids[next_to_print].line_array[j]);
	}
	printf("%d\n", ids[next_to_print].line_array[j]);

	/* 
	 * Have printed an identifier and line number list, so record that
	 * this identifier no longer needs to be printed in the future
	 */
	ids[next_to_print].need_to_print = FALSE;
	++num_printed;

	} /* End while (num_printed < ids_index) */
} /* End of print_ids */

/*
 * This function just frees up all dynamic memory used for identifier strings
 */
void clean_up()
{
	int i;
	for (i = 0; i < ids_index; ++i)
	{
		free(ids[i].id_str);
	}
}
