from assembler import assembler

a = assembler.Assembler("test.asm")
print(a.lines)
print(a.with_labels)