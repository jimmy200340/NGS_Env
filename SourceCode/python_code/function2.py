def get_at_content(dna): 
    length = len(dna) 
    a_count = dna.upper().count('A') 
    t_count = dna.upper().count('T') 
    at_content = (a_count + t_count) / length 
    return round(at_content, 2)

my_dna1 = "ATGCGCGATCGATCGAATCG"
print("AT content is " + str(get_at_content(my_dna1)))
# AT content is 0.45
my_dna2 = "ATGCATGCAACTGTAGC"
at_content = get_at_content(my_dna2)
print("AT content is " + str(at_content))
# AT content is 0.53
print(get_at_content("aactgtagctagctagcagcgta"))
# 0.52