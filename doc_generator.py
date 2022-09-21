from specification import InstructionType, SubI, BIT_WIDTH
from specification.param import LParam, PositionalParameter, SubParam

STYLE = """
.bit_table {
    border-collapse: collapse;
}
.left_most {
    border-left: 1px solid black;
}
.right_border {
    border-right: 1px solid black;
}
.bit_cell {
    height: 22px;
    width: 30px;
    border-top: 1px solid black;
    border-bottom: 1px solid black;
    text-align: center;
}
.bit_header {
    text-align: right;
}
"""

HTML_OUTLINE = """
<html>
    <head>
    <style>{style}</style>
    </head>
    <body>
{body_content}
    </body>
</html>
"""

BIT_OUTLINE_TABLE = """
<table class="bit_table" style="width:600px">
    <colgroup>
        {col_outline}
    </colgroup>
    <tr>
        {dummy1}
    </tr>
    <tr>
        {dummy2}
    </tr>
</table>
""".format(
    col_outline = ("<col width=\"{:.2f}%\"/>".format(100/(BIT_WIDTH +1 )))*(BIT_WIDTH+1),
    dummy1 = "{header}",
    dummy2 = "{bit_desc}",
)

TD_HEADER = """<td class= "bit_header" colspan="{size}">{val}</td>"""

def bit_cell(last, val, width=1, right=False):
    return """
        <td class="bit_cell{left}{right}" colspan="{width}">
            {val}
        </td>""".format(
        left = " left_most" if last == BIT_WIDTH else "",
        width = width,
        right = " right_border" if right or last == width else "",
        val = val
    )

def draw_bit_table(instruction_type) -> str:
    fixed = instruction_type.fixed()
    ins_format = instruction_type.format()
    param_defs = filter(
        lambda x: isinstance(x, LParam) or
            (
                isinstance(x, SubParam) and 
                ins_format[x.start] == "?"
            ),
        instruction_type.params_def()
    )
    joined = [(f[0], f[1], "fixed", f[2]) for f in fixed] + \
        [(pd.start, pd.end, "param", pd.name) for pd in param_defs ]
    joined.sort(key=lambda x: -x[1])
    last = BIT_WIDTH
    i = 0
    header = [TD_HEADER.format(size=1, val=str(BIT_WIDTH))]
    desc = ["<td></td>"]
    while last > 0:
        if i >= len(joined) or joined[i][1] < last:
            start = 0 if i >= len(joined) else joined[i][1]
            end, t, val = last,  "unknown", ""
        else:
            start, end, t, val = joined[i]
            i += 1
        if t == "fixed":
            header.append(TD_HEADER.format(size=end-start, val=str(start)))
            if type(val) == int:
                val = bin(val)[2:][::-1].ljust(end-start, "0")
            for v in val[::-1]:
                last -= 1
                desc.append(bit_cell(last, v, 1, last == start))
        else:
            header.append(TD_HEADER.format(size=end-start, val=str(start)))
            desc.append(bit_cell(last, val[:3*(end-start)], end-start, True))
            last = start
    return BIT_OUTLINE_TABLE.format(
        header = "".join(header),
        bit_desc = "".join(desc)
    )
    #print(joined)


def generate_doc(instruction, depth=1):
    doc = []
    doc.append("<h{d}>{name}</h{d}>".format(d=(depth+1), name=instruction.__name__))
    main_doc = instruction.__doc__ or ""
    doc.append("".join("<p>{}<p>".format(v) for v in main_doc.split("\n\n")))
    doc.append(draw_bit_table(instruction))
    # TODO(params) / parent_params + fixed
    for c in instruction.children():
        doc.append(generate_doc(c, depth+1))
    return "\n".join(doc)


def draw_all():
    with open("doc.html", "w") as f:
        f.write(
            HTML_OUTLINE.format(
                style = STYLE,
                body_content = generate_doc(InstructionType)
            )
        )


if __name__ == "__main__":
    draw_all()
