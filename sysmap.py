#--------------------------------------------------------------------
# Name: sysmap.py
# Function: convert file from sjis to UTF8, call sysmap_jl.jl, call sysmap_pptx.py to make PPTX file.
# Usage: > python sysmap.py <sjis fn> <pptx fn> [CR]
# Sample: > python sysmap.py asset.csv asset.pptx [CR]
#--------------------------------------------------------------------
import os
import sys
import tempfile

TMPFILE1 = "sysmap-utf8.txt"
TMPFILE2 = "sysmap-pptx.txt"

print("=== sysmap: START.")
fn_in = sys.argv[1]     # SJIS file name
fn_out = sys.argv[2]    # PPTX file name

# print "=== sysmap: %s, %s" % (fn_in, fn_out)
#--------------------------------------------------------------------
# to_utf8 : Convert fin(sjis) to fout(UTF8) file.
#--------------------------------------------------------------------
def to_utf8(fin, fout):
    # print "=== sysmap: to_utf8: %s, %s" % (fin, fout)
    with open(fout, 'w') as f:
        for line in open(fin):
            f.write(unicode(line, 'Shift_JIS').encode('utf-8'))

#--------------------------------------------------------------------
# Main routine
#--------------------------------------------------------------------
#------------------------------------
# Convert SJIS csv file => UTF8 file
#------------------------------------
to_utf8(fn_in, TMPFILE1)

#------------------------------------
# Call Julia code: sysmap_jl.jl
#------------------------------------
cmd = "julia sysmap_jl.jl " + TMPFILE1 + " " + TMPFILE2
print "=== sysmap: cmd = %s" % cmd
os.system(cmd)

#------------------------------------
# Call Python code: sysmap_pptx.py
#------------------------------------
cmd = "python sysmap_pptx.py " + TMPFILE2 + " " + fn_out
print "=== sysmap: cmd = %s" % cmd
os.system(cmd)

os.remove(TMPFILE1)
os.remove(TMPFILE2)

print("=== sysmap: END.")
#--------------------------------------------------------------------
# End of File
#--------------------------------------------------------------------
