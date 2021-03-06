<?xml version='1.0' encoding='ISO-8859-1'?>
<case codeversion="1.0" codename="darcy" xml:lang="en">
  
  <arcane>
    <title>Experimentation Arcane</title>
    <timeloop>drcLoop</timeloop>
  </arcane>

   <mesh>
     <meshgenerator>
       <!--sod zyx='true'>
        <x set='true' delta='0.1125'>4</x>
        <y set='true' delta='0.1125'>4</y>
        <z set='true' delta='0.1125' total='true'>4</z>
       </sod-->
	    <cartesian>
			<nsd>4 1 1</nsd>
         <!-- '0.0' doit concorder avec drc.n:option_boundary_Xmin! -->
			<origine>0.0 0.0 0.0</origine>
         <!-- '1.0' doit concorder avec drc.n:option_boundary_Xmax! -->
			<lx nx="4" prx="1.0">1.0</lx>
			<ly ny="4" pry="1.0">1.0</ly>
			<lz nz="4" prz="1.0">1.0</lz>
		 </cartesian> 
     </meshgenerator>
   </mesh>
   
   <arcane-post-processing>
     <save-init>0</save-init>
     <end-execution-output>0</end-execution-output>
	  <output-period>0</output-period>
     <output>      
       <!--group>AllFaces</group>
       <variable>face_face_measure</variable>
       <variable>face_transmissivity</variable>
       <variable>face_total_velocity</variable-->
      
       <group>AllCells</group>
       <!--variable>cell_cell_uid</variable-->
       <variable>cell_pressure</variable>
       
       <!--variable>cell_porosity</variable>
       <variable>cell_total_mobility</variable-->
       <variable>cell_water_saturation</variable>
       <variable>cell_oil_saturation</variable>
       
       <!--variable>cell_cell_measure</variable-->
       <!--variable>cell_cell_center</variable-->
       
       <!--variable>cell_water_density</variable-->
       <!--variable>cell_water_viscosity</variable-->
       <!--variable>cell_water_relative_permeability</variable-->
       <!--variable>cell_water_mobility</variable-->
     </output>
   </arcane-post-processing>
   
   <arcane-checkpoint>
     <period>0</period>
     <do-dump-at-end>false</do-dump-at-end>
   </arcane-checkpoint>

  <drc>
    <!--option_dtt_initial>0.001</option_dtt_initial-->
    <!--option_stoptime>0.01</option_stoptime-->
    
    <option_ini_porosity>1.0</option_ini_porosity>
    <option_ini_permeability>1.0</option_ini_permeability>
    <option_ini_oil_density>1.0</option_ini_oil_density>
    <option_ini_water_density>1.0</option_ini_water_density>
    <option_ini_oil_viscosity>1.0</option_ini_oil_viscosity>
    <option_ini_water_viscosity>1.0</option_ini_water_viscosity>
   </drc>

</case>
