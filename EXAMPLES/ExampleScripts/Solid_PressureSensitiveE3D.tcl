#[jeremic,zhyang]@ucdavis.edu
# tcl example file using Template3Dep material 
#  --- Drucker-Prager Model with isotropic hardening
# Inelastic static analysis -- Triaxial test
#
#two load stages:
# stage 1: isotropic compression
# stage 2: triaxial shearing
#22Nov2002


# ################################
# create the modelbuilder
# #################################

model BasicBuilder -ndm 3 -ndf 3

set g   9.81
set p   5.0
set np -5.0
set ld -8.0 
set lf1 0.005
set NN1 200
# ################################
# build the model
# #################################

node 1 1.0 1.0 0.0
node 2 0.0 1.0 0.0
node 3 0.0 0.0 0.0
node 4 1.0 0.0 0.0
node 5 1.0 1.0 1.0
node 6 0.0 1.0 1.0
node 7 0.0 0.0 1.0
node 8 1.0 0.0 1.0

#triaxial test boundary
fix 1 0 1 1
fix 2 1 1 1
fix 3 1 0 1
fix 4 0 0 1
 

#Elastic-plastic model
#================================================================
# Drucker-Prager model
#Yield surface 
set DPys "-DP"

#potential surface
set DPps "-DP 0.1"

# Scalar evolution law: linear hardening coef = 1.0
set ES1  "-Leq  0.0"

# Tensorial evolution law: linear hardening coef. = 0.0
set ET1  "-Linear  0.0"

# initial stress
set stressp "0.10 0 0  0 0.10 0  0 0 0.10"

# EPState
#__________E________Eo____v___rho______________alpha___k
set EPS "70000.0 70000.0 0.2 1.8 -NOD 1 -NOS 2  0.2    0.0 -stressp $stressp"
#
# where
#alpha = 2 sin(phi) / (3^0.5) / (3-sin(phi) ), phi is the friction angle
# and k is the cohesion

# Creating nDMaterial using Template Elastic-PLastic Model
nDMaterial Template3Dep 1 -YS $DPys -PS $DPps -EPS $EPS -ELS1 $ES1 -ELT1 $ET1

nDMaterial PressureDependentElastic3D 2 70000.0 0.3 1.8 0.6 100 5



#____________tag_____8 nodes______matID__bforce1_bforce2_bforce3_rho
element Brick8N  1  5 6 7 8 1 2 3 4   2      0.0     0.0    -9.81  1.8



#===========================================================
#stage 1
#===========================================================
#isotropic load
pattern Plain 2 "Linear" {
load 1 $np 0   0   -pattern 2
load 3 0   $p  0   -pattern 2
load 4 $np $p  0   -pattern 2
load 5 $np $np $np -pattern 2
load 6 $p  $np $np -pattern 2
load 7 $p  $p  $np -pattern 2
load 8 $np $p  $np -pattern 2
}

#Set up recorder
recorder Node node_iso.out disp -time -node 5 -dof 3
recorder plot node_iso.out "disp load"  10 10 300 300 -columns 2 1
#stress recorder
#recorder Element all -time -file SigmaIso.out stress
#recorder plot SigmaIso.out "Load factor vs. Normal stress"  10 400 300 300 -columns 1 3

system UmfPack
constraints Penalty 1e12 1e12
test NormDispIncr 1.0e-5 30 0
integrator LoadControl $lf1 1 $lf1 $lf1
algorithm Newton
numberer RCM
analysis Static

analyze $NN1


##===========================================================
##stage 2
##===========================================================
##Axial loading
#wipeAnalysis
##loadConst
#
#equalDOF 5 6 3 3
#equalDOF 5 7 3 3
#equalDOF 5 8 3 3
#       	  
#
##set previous load constant
#loadConst time 0
#
## Before shifting to disp. control, apply reference load on the top
#pattern Plain 3 "Linear" {
#load 5 0.0 0.0 $np 
#load 6 0.0 0.0 $np
#load 7 0.0 0.0 $np 
#load 8 0.0 0.0 $np
#}
#
## Stop the old recorders by destroying them
#remove recorders
#
##Set up recorder for axial loading stage
##recorder Node node_z.out disp -time -node 5 -dof 3
#
#recorder Node node_z.out disp -time -node 5 -dof 3
#recorder plot node_z.out "Disp vs Load" 10 10 300 300 -columns 2 1
#
#recorder Element 1 -file element.out force
##recorder plot element.out "nodal force displ horizontal" 10 400 300 300 -columns 1 3
#
#set NN2 200
#set ndz -0.0001
#
#system UmfPack
#constraints Penalty 1e12 1e12
#test NormDispIncr 1.0e-08 30  0
#integrator DisplacementControl 5 3 $ndz 1 $ndz $ndz
#algorithm Newton
#numberer RCM
#analysis Static
#
#analyze $NN2
#
#wipe
#
#
