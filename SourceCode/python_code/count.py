protein = "vlspadktnv" 

valine_count = protein.count('v')
lsp_count = protein.count('lsp')
tryptophan_count = protein.count("w")

print('valines: '+str(valine_count))
# valines: 2
print('lsp: '+str(lsp_count))
# lsp: 1
print('tryptophans: '+str(tryptophan_count))
# tryptophans: 0