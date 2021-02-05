# open a new file
my_file = open('test_append.txt', 'w')
my_file.write("Hello world\n")
my_file.close()

# open the old file
append_file = open('test_append.txt', 'a')

# append data
append_file.write('abc'+'def\n')
append_file.write(str(len("AGTGCTAG"))+'\n')
append_file.write('ATGC\n'.lower())
append_file.write(str(5.)+'\n')

# close file
append_file.close()



