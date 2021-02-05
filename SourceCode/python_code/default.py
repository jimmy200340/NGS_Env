def get_at_content(dna, dec=2):
    length = len(dna)
    a_count = dna.upper().count('A') 
    t_count = dna.upper().count('T') 
    at_content = (a_count + t_count) / length 
    return round(at_content, dec)

my_dna = "ATGCATGCAACTGTAGC"
print(get_at_content(my_dna))
# 0.53
print(get_at_content(my_dna, 3))
# 0.529
print(get_at_content(dec=4, dna=my_dna))
# 0.5294