from emulator.cpu import CPU


with open("callstack.bin", "rb") as f:
    raw_b = f.read()

cpu = CPU()
cpu.write_blob(0, raw_b)

cpu.run()