from argparse import ArgumentError
import re
class Assembler(object):
    def __init__(self, input_file) -> None:
        with open(input_file, "r") as f:
            self.raw_lines = f.readlines()
        
        lines = [
            self.fix_line(line) for line in self.raw_lines
        ]
        self.lines = [
            line for line in lines if lines != ""
        ]
        self.add_label_details()

    def add_label_details(self):
        self.with_labels = []
        used_labels = set()
        current = []
        for line in self.lines:
            if (pos := line.find(":")) != -1:
                label = line[:pos]
                if label in current or label not in used_labels:
                    used_labels.add(label)
                    if label not in current:
                        current.append(label)
                else:
                    raise AssertionError("Label names cannot be reused.")
                if pos + 1 < len(line):
                    self.with_labels.append((line, current))
                    current = []
            else:
                self.with_labels.append((line, current))
                current = []

    def fix_line(self, line: str):
        if (semi_index := line.find(";")) != -1:
            #print(semi_index)
            line = line[:semi_index].strip()
        else:
            # Can ONLY be empty or a label
            line = line.strip()
            print(line)  
            if re.match(r"^\w[\w\d]*\:$", line):
                #Label
                pass
            elif line != "":
                raise ArgumentError("Bad line: {}", line)
        return line
    
