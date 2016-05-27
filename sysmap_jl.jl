# --------------------------------------------------------------
# NAME: sysmap_jl
# Function: Process asset data & Call Python to make PowerPoint
# Input file: UTF8 asset csv format text file.
# Output file: csv format text file as an input file of sysmap_pptx
# Usage: julia sysmap_jl.jl <utf-data-fn< <pptx-data-fn> [CR]
#    $ julia sysmap_jl input.txt pptx-data.txt[CR]
# --------------------------------------------------------------

println("=== sysmap_jl: Start. ")
# --------------------------------------------------------------
# Constant paramaters for Power Point position
# --------------------------------------------------------------
SPLITTER = "--- SPLITTER ---"  # Must same with sysmap_pptx.py def.
MARGIN = 2   # ppt margin 2mm between object
WIDTH = 230  # ppt width 230mm
LEFT = 10    # ppt left 10mm

# slide size 4:3
# WIDTH = 230  # ppt width 230mm
# HEIGHT = 15 # ppt object height 15mm
# L1 = 170  # ppt top 170mm
# L2 = 148  # ppt top 148mm
# L3 = 126
# L4 = 104
# L5 = 82
# L6 = 60
# L7 = 38
# L8 = 16

# slide size 16:9
WIDTH = 240  # ppt width 240mm
HEIGHT = 10 # ppt object height 10mm
VM_HEIGHT = 20  # ppt object height 20mm
L1 = 125        # ppt top 125
L2 = 110
L3 = 95
L4 = 80
L5 = 65
L6 = 35
L7 = 35 #--- Not used now.
L8 = 20

# Data source column setting
APPL       = 1   # Column[1]
PV         = 2
APPLSERVER = 3
PCPU       = 4
PCORE      = 5
PMEM       = 6
PSTORAGE   = 7
POS        = 8
CLUSTER    = 9
PMIDDLE    = 10
HYPERVISOR = 11
VM         = 12
VCPU       = 13
VMEM       = 14
VSTORAGE   = 15
VOS        = 16
VMIDDLE    = 17

# --------------------------------------------------------------
# item_sort: sort data frame in order of P, P+H, V
# --------------------------------------------------------------
function item_sort(df)
    # println("=== item_sort()")
    pv_list = sort!(df, cols = [order(:appl), order(:PV), order(:Hypervisor, rev=true), order(:VM)])
    # println("pv_list: ", pv_list)     # only P, P+H list
    return(pv_list)
end

# --------------------------------------------------------------
# Main
# --------------------------------------------------------------
using DataFrames

fn_in  = ARGS[1]    # Excel/CSV input data file
fn_out = ARGS[2]  # CSV file for ppt drawing

df = readtable(fn_in, separator=',', header=true)
fd = open(fn_out, "w")

# --------------------------------------------------------------
# Sort P -> P+H -> V
# --------------------------------------------------------------
applgroup = groupby(item_sort(df), :appl)
# println("=== applgroup : ", applgroup)

# --------------------------------------------------------------
# make data for PPTX about App, P, P+H, V
# --------------------------------------------------------------
#-----------------------------------
# Main loop for Appl, P, P+H, V
#-----------------------------------
for ag in applgroup  #--- each Appl

    # ---PreProcess: define L2 left position for P, P+H
    p_list = ag[ ag[:PV].=="P", : ]
    # println("p_list : ", p_list)
    s = size(ag[ ag[:PV].=="P", : ])
    width_l1 = round(WIDTH / s[1]) - MARGIN   # each L1 width

    # ---PreProcess: define L3 left position for V
    vm_list = ag[ ag[:PV].=="V", : ]

    # ---Start P, P+H process
    for n in 1:size(p_list)[1]

        obj_level1 = []   #--- Physical Server
        obj_level2 = []   #--- Phy + Hypervisor Server
        push!(obj_level1, p_list[n,APPLSERVER]) # serv name row:n col:serv_name
        push!(obj_level1, LEFT + width_l1 * (n-1)) #--- left pos
        push!(obj_level1, L1)                      #--- top pos
        push!(obj_level1, width_l1)                #--- width
        push!(obj_level1, HEIGHT)              #--- height
        # println(" obj_level1 = ", obj_level1)
        println(fd, obj_level1)

        #-----------------------------------
        # Appl name @ L8
        #-----------------------------------
        apname = []   #--- Appl name
        push!(apname, p_list[n, APPL]) # Appl name row:n col:Appl
        push!(apname, LEFT + width_l1 * (n-1)) #--- left pos
        push!(apname, L8)                      #--- top position Level
        push!(apname, width_l1)                #--- width
        push!(apname, HEIGHT)              #--- height
        # println(" apname = ", apname)
        println(fd, apname)
    
        #-----------------------------------
        # Hypervisor if exist.
        #-----------------------------------
        if !isna(p_list[n, HYPERVISOR])
            push!(obj_level2, p_list[n, HYPERVISOR]) #--- Hypervisor name
            pv_left_pos = LEFT + width_l1 * (n-1)    #--- left pos 
            push!(obj_level2, pv_left_pos)
            push!(obj_level2, L2)                  #--- top pos
            push!(obj_level2, width_l1)            #--- width
            push!(obj_level2, HEIGHT)              #--- height
            # println(" obj_level2 = ", obj_level2)
            println(fd, obj_level2)

            #-----------------------------------
            # VM if exist.
            #-----------------------------------
            host_serv = p_list[n, APPLSERVER]
            # println(" host_serv : ", host_serv)

            dd = vm_list[ vm_list[:appl_server] .== host_serv, : ]
            # println(" dd : ", dd)

            vm_count = size(vm_list[ vm_list[:appl_server] .== host_serv, : ])
            # println(" vm_count[1] : ", vm_count[1])

            width_l3 = round(width_l1 / vm_count[1] - MARGIN) # each L3 width

            #------------------------------
            #-- VM loop
            #------------------------------
            for i in 1:vm_count[1]

                #------------------------------
                #-- VM vOS (L3)
                #------------------------------
                obj_level3 = []   #--- VM
                push!(obj_level3, dd[i, VOS])  # 16: vOS
                push!(obj_level3, pv_left_pos + MARGIN * (i-1) + width_l3 * (i-1)) #--- Left pos
                push!(obj_level3, L3)                  #--- top pos
                push!(obj_level3, width_l3)            #--- width
                push!(obj_level3, HEIGHT)          #--- height
                # println(" obj_level3 = ", string(obj_level3))
                println(fd, string(obj_level3))

                #------------------------------
                #-- VM name (L6)
                #------------------------------
                obj_level6 = []   #--- VM
                push!(obj_level6, dd[i, VM])  # 12: VM
                push!(obj_level6, pv_left_pos + MARGIN * (i-1) + width_l3 * (i-1)) #--- Left pos
                push!(obj_level6, L6)                  #--- top pos
                push!(obj_level6, width_l3)            #--- width
                push!(obj_level6, VM_HEIGHT)          #--- height
                # println(" obj_level6 = ", string(obj_level6))
                println(fd, string(obj_level6))

                #------------------------------
                #-- VM Middleware (L5)
                #------------------------------
                obj_level5 = []
                push!(obj_level5, dd[i, VMIDDLE])  # 17: vMiddle
                push!(obj_level5, pv_left_pos + MARGIN * (i-1) + width_l3 * (i-1)) #--- Left pos
                push!(obj_level5, L5)                  #--- top pos
                push!(obj_level5, width_l3)            #--- width
                push!(obj_level5, HEIGHT)          #--- height
                # println(" obj_level5 = ", string(obj_level5))
                println(fd, string(obj_level5))
            end #--- VM

            #------------------------------
            #-- Hypervisor middleware without VM
            #------------------------------
            # Need this ?? 
        else
            #------------------------------
            #-- Physical OS (L3)
            #------------------------------
            p_level3 = [] 
            push!(p_level3, p_list[n,POS])  #--- 8:pOS
            push!(p_level3, LEFT + width_l1 * (n-1)) #--- left pos
            push!(p_level3, L3)                      #--- top pos
            push!(p_level3, width_l1)                #--- width
            push!(p_level3, HEIGHT)              #--- height
            # println(" p_level3 = ", p_level3)
            println(fd, p_level3)

            #------------------------------
            #-- Physical Cluster (L4)
            #------------------------------
            p_level4 = [] 
            if !isna(p_list[n, CLUSTER])  #---Skip Cluster NA field
                push!(p_level4, p_list[n,CLUSTER])  #--- 9:Clustering
                push!(p_level4, LEFT + width_l1 * (n-1)) #--- left pos
                push!(p_level4, L4)                      #--- top pos
                push!(p_level4, width_l1)                #--- width
                push!(p_level4, HEIGHT)              #--- height
                # println(" p_level4 = ", p_level4)
                println(fd, p_level4)
            end
            #------------------------------
            #-- Physical Middleware (L5)
            #------------------------------
            p_level5 = [] 
            push!(p_level5, p_list[n,VMIDDLE])  #--- 17:vMiddle
            push!(p_level5, LEFT + width_l1 * (n-1)) #--- left pos
            push!(p_level5, L5)                      #--- top pos
            push!(p_level5, width_l1)                #--- width
            push!(p_level5, HEIGHT)              #--- height
            # println(" p_level5 = ", p_level5)
            println(fd, p_level5)

        end #--- Hypervisor
    end #--- Physical
    println(fd, SPLITTER)

end #--- Appl Group

# --------------------------------------------------------------
# Closing
# --------------------------------------------------------------

println("=== sysmap_jl : End.")
# --------------------------------------------------------------
# End of File
# --------------------------------------------------------------

