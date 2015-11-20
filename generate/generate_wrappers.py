
import json

def op(i, a):
    print("    "*i + a)

with open("functions.json") as f:
    defs = json.loads(f.read())

regs = ["A","B","C","X","Y","Z","I","J"]

for f in defs:

    arg_count = len(f["args"])
    ret_count = len(f["returns"])
    print("; Arguments:")
    if arg_count > 0:
        i = 0
        for a in f["args"]:
            print(";  %s: %s - %s" % (regs[i], a["name"], a["help"]))
            i += 1
    else:
        print(";  None")
    i = 0
    print("; Returns:")
    if ret_count > 0:
        for a in reversed(f["returns"]):
            print(";  %s: %s - %s" % (regs[i], a["name"], a["help"]))
            i += 1
    else:
        print(";  None")

    print "%s:" % f["name"]

    indent = 1
    if ret_count > arg_count:
        op(indent, "SUB SP, %d" % (ret_count - arg_count))
    elif arg_count > ret_count:
        for i in range(ret_count, arg_count):
            op(indent, "SET PUSH, %s" % regs[i])
        indent += 1

    for i in range(0, arg_count):
        op(indent, "SET PUSH, %s" % regs[i])
    op(indent+1, "SET A, %s" % f["bbos_id"])
    op(indent+1, "INT 0x4743")

    for i in range(0, ret_count):
        op(indent, "SET %s, POP" % regs[i])

    if arg_count > ret_count:
        op(indent, "ADD SP, %d" % (arg_count - ret_count))
        indent -= 1
        for i in range(ret_count, arg_count):
            op(indent, "SET %s, POP" % regs[i])
    op(indent, "SET PC, POP")
    print("")
