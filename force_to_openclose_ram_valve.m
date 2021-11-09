%------------------------------------------------------------------------------
% Function Name: force_to_openclose_ram_valve
% Author: KATKAR Deepak
% Description:Calcualtion if required acuating Force and Torque for the Ram Valve
%------------------------------------------------------------------------------
% Changed on:
% 26-12-2020  by  xxxxxxxxxxxxxx  change summary
%

%------------------------------------------------------------------------------

function [forces] = force_to_openclose_ram_valve( ...
          design_pressure, ram_diameter, seat_diameter,... 
          density_factor_f, gasket_coefficient_kd,...
          characteristic_value_for_packing_k, frictional_value_mu)
          
pkg load pkg-json;
          
% 4 50 40 60 1 1 0.4 0.5 
% Hardcoded variables...later need to be changed
medium = "Liquid";
packing_width = 8;
packing_length = 48;
packing_contact_pressure = 9.75;
valve_opening_force = 0;
valve_closing_force = 0;
additional_force_to_open_valve = 0;
additional_force_to_close_valve = 0;

% compressive force          
compressive_force_seat = compressive_force_on_surface (seat_diameter, design_pressure);

%% sealing force
sealing_force = valve_disk_sealing_force(seat_diameter, density_factor_f, gasket_coefficient_kd);


% IF loop to be replaced in configureOne 
%% if condition to check if the Pp meets the minimum criteria
if ((strcmp(medium, "Gas") == 1 && packing_contact_pressure < 12) ||... 
    (strcmp(medium, "Liquid") == 1 && packing_contact_pressure < 6))
      error("Check pp values and make corrections");
else
   %% calculated assuming that the exponent has term L / b
   frictional_force_packing = valve_friction_force_packing(ram_diameter,... 
                               packing_width, packing_contact_pressure,...
                               frictional_value_mu,...
                               characteristic_value_for_packing_k,... 
                               packing_length);
 
   %% Calculate packing friction torque Mp
   frictional_torque_packing = valve_friction_force_packing(ram_diameter,... 
                                packing_width, packing_contact_pressure,...
                                frictional_value_mu,...
                                characteristic_value_for_packing_k,... 
                                packing_length);
 
endif

%% Force to open the valve
force_to_open = frictional_force_packing + additional_force_to_open_valve;

%% Force to close the valve
force_to_close = compressive_force_seat + sealing_force + ...
                  frictional_force_packing + additional_force_to_close_valve;

s=struct();
s.oresult1 = force_to_open;
s.oresult2 = force_to_close;

forces =jsonencode(s);
endfunction