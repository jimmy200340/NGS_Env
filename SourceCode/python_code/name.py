def get_at_content(dna, dec):
    length = len(dna)
    a_count = dna.upper().count('A') 
    t_count = dna.upper().count('T') 
    at_content = (a_count + t_count) / length 
    return round(at_content, dec)

my_dna = "ATGCGCGATCGATCGAATCG"
print(get_at_content(dna = my_dna, dec = 2))
# 0.45
print(get_at_content(dec = 2, dna = my_dna))
# 0.45
# print(get_at_content(my_dna, dec=3))   # wrong
# print(get_at_content(dna = my_dna, 3)) # wrong