# first store a list of lines in the file
file = open("dna2.txt")
all_lines = file.readlines()

# print the lengths
for line in all_lines:
    print("The length is " + str(len(line)))
# The length is 19
# The length is 19
# The length is 18

# print the first characters
for line in all_lines:
    print("The first character is " + line[1])
# The first character is T
# The first character is C
# The first character is C