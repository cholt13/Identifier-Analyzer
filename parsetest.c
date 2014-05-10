#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define MAX_LENGTH 81
#define TRUE 1
#define FALSE 0

int parseCommand(char*);

int main()
{
	char command[MAX_LENGTH] = "ls > test.txt";

	if (parseCommand(command) == -1)
	{
		printf("Parsing failed.\n");
	}
	else
	{
		printf("Parsing successful.\n");
	}

	printf("Shell terminated.\n");
	return 0;
}

int parseCommand(char* command)
{
	int arraySize = 5;
	char** commandArray = malloc(arraySize * sizeof(char*));
	int tokenIndex = 0;
	char* token;
	char* saveptr;

	token = strtok_r(command, " ", &saveptr);
	if (token == NULL)
	{
		return -1;
	}

	commandArray[tokenIndex++] = token;

	while (token != NULL)
	{
		if (tokenIndex > arraySize - 1)
		{
			/* Handle dynamic resizing */
			char** newArray = malloc(arraySize * 2 *
						 sizeof(char*));
			int i;
			for (i = 0; i < arraySize; ++i)
			{
				newArray[i] = commandArray[i];
			}
			free(commandArray);
			commandArray = newArray;
			arraySize *= 2;
		}
		token = strtok_r(NULL, " ", &saveptr);
		if (token == NULL)
			continue;
		commandArray[tokenIndex++] = token;
	}

	int j;
	for (j = 0; j < tokenIndex; ++j)
	{
		printf("%s\n", commandArray[j]);
	}

	free(commandArray);
	return 0;
}
