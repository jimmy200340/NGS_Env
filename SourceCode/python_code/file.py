# print the length of each line
file = open("dna2.txt")
for line in file:
    print("The length is " + str(len(line)))
file.close()
# The length is 19
# The length is 19
# The length is 18

# print the second character of each line
file = open("dna2.txt")
for line in file:
    print("The first character is " + line[1])
# The first character is T
# The first character is C
# The first character is C