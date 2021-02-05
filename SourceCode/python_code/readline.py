# open the file
my_file = open('dna2.txt', 'r')

# read the first line
my_dna1 = my_file.readline()

# read the second line
my_dna2 = my_file.readline()

# read the third line
my_dna3 = my_file.readline()

print(my_dna1, len(my_dna1))
print(my_dna2, len(my_dna2))
print(my_dna3, len(my_dna3))