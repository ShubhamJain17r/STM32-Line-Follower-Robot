// ==============================================================================
// High-Speed Closed-Loop Line Follower Robot: Parametric Mechanical Assembly
// Platform: STM32F446RE Motherboard + 8-Channel QTR-8 Sensor Blade
// Kinematics: 42mm Wheels, 110mm Track Width, 100mm Wheelbase, 40mm Overhang
// ==============================================================================

$fn = 60; // Curve resolution

// --- Key Dimensions (all in millimeters) ---
WHEEL_DIAMETER          = 42.0;
WHEEL_WIDTH             = 19.0;
TRACK_WIDTH             = 110.0; // Distance between left and right wheel centerlines
WHEELBASE               = 100.0; // Rear axle to front caster pivot
SENSOR_OVERHANG         = 40.0;  // Front caster pivot to optical sensor centerline

CHASSIS_LENGTH          = 135.0;
CHASSIS_WIDTH           = 94.0;
CHASSIS_THICKNESS       = 3.0;

// Motherboard PCB mounting holes (80mm x 50mm, 72mm x 42mm hole pattern)
PCB_HOLE_SPACING_X      = 72.0;
PCB_HOLE_SPACING_Y      = 42.0;

// N20 Motor Dimensions
N20_LENGTH              = 26.0;
N20_WIDTH               = 12.0;
N20_HEIGHT              = 10.0;
N20_SHAFT_LEN           = 10.0;
N20_SHAFT_DIA           = 3.0;

// Battery Compartment (3S 450-650mAh LiPo: ~55mm x 30mm x 22mm)
BATTERY_LEN             = 58.0;
BATTERY_WIDTH           = 32.0;
BATTERY_DEPTH           = 1.5;

// Ball Caster
CASTER_BALL_DIA         = 8.0;
CASTER_HOUSING_OD       = 14.0;

// Front Sensor Blade (65mm x 16mm, mounting holes at 58mm pitch)
BLADE_LEN               = 65.0;
BLADE_WIDTH             = 16.0;
BLADE_HOLE_SPACING      = 58.0;

// ==============================================================================
// Module: Main Chassis Base Plate
// ==============================================================================
module chassis_base_plate() {
    difference() {
        // Base perimeter with rounded front & rear
        hull() {
            // Rear axle region
            translate([-10, -CHASSIS_WIDTH/2 + 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            translate([-10, CHASSIS_WIDTH/2 - 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            // Mid body
            translate([WHEELBASE - 30, -CHASSIS_WIDTH/2 + 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            translate([WHEELBASE - 30, CHASSIS_WIDTH/2 - 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            // Front nose (narrower towards caster)
            translate([WHEELBASE + 10, -20, 0])
                cylinder(r=6, h=CHASSIS_THICKNESS);
            translate([WHEELBASE + 10, 20, 0])
                cylinder(r=6, h=CHASSIS_THICKNESS);
        }

        // Wheel cutouts for 42mm tires (left and right)
        translate([-WHEEL_DIAMETER/2 - 2, -TRACK_WIDTH/2 - 2, -1])
            cube([WHEEL_DIAMETER + 4, WHEEL_WIDTH + 4, CHASSIS_THICKNESS + 2]);
        translate([-WHEEL_DIAMETER/2 - 2, TRACK_WIDTH/2 - WHEEL_WIDTH - 2, -1])
            cube([WHEEL_DIAMETER + 4, WHEEL_WIDTH + 4, CHASSIS_THICKNESS + 2]);

        // Recessed Battery Pocket (centers mass low between rear wheels)
        translate([15, -BATTERY_WIDTH/2, CHASSIS_THICKNESS - BATTERY_DEPTH])
            cube([BATTERY_LEN, BATTERY_WIDTH, BATTERY_DEPTH + 1]);

        // Battery velcro strap slots
        translate([20, -BATTERY_WIDTH/2 - 4, -1])
            cube([20, 3, CHASSIS_THICKNESS + 2]);
        translate([20, BATTERY_WIDTH/2 + 1, -1])
            cube([20, 3, CHASSIS_THICKNESS + 2]);

        // Motherboard M3 Standoff Holes (4x M3)
        translate([30 - PCB_HOLE_SPACING_X/2, -PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([30 + PCB_HOLE_SPACING_X/2, -PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([30 - PCB_HOLE_SPACING_X/2,  PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([30 + PCB_HOLE_SPACING_X/2,  PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);

        // Front Ball Caster Socket Hole (at WHEELBASE)
        translate([WHEELBASE, 0, -1])
            cylinder(d=CASTER_HOUSING_OD, h=CHASSIS_THICKNESS + 2);

        // Front Sensor Blade Extension Mount Holes (M3)
        translate([WHEELBASE + 18, -15, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([WHEELBASE + 18,  15, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);

        // N20 Motor Mount Screw Holes (M2 heat-set insert holes)
        for (side = [-1, 1]) {
            y_pos = side * (TRACK_WIDTH/2 - WHEEL_WIDTH - 8);
            translate([-8, y_pos - 4, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([-8, y_pos + 4, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([12, y_pos - 4, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([12, y_pos + 4, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
        }
    }
}

// ==============================================================================
// Module: N20 Clamping Motor Bracket with Encoder Protection
// ==============================================================================
module n20_motor_bracket(side=1) {
    difference() {
        // Outer housing
        translate([-12, -8, 0])
            cube([28, 16, 14]);

        // N20 Motor pocket
        translate([-10, -N20_WIDTH/2, 2])
            cube([N20_LENGTH + 2, N20_WIDTH, N20_HEIGHT]);

        // D-Shaft clearance
        translate([N20_LENGTH - 10, -4, 7])
            rotate([0, 90, 0])
            cylinder(d=6.0, h=10);

        // Rear Magnetic Encoder Protective Cowl cavity
        translate([-13, -N20_WIDTH/2 - 1, 1])
            cube([5, N20_WIDTH + 2, N20_HEIGHT + 2]);

        // Wiring exit channel
        translate([-13, -3, 6])
            cube([6, 6, 9]);

        // Mounting screw holes (M2 through-holes)
        translate([-6, -5, -1]) cylinder(d=2.2, h=16);
        translate([-6,  5, -1]) cylinder(d=2.2, h=16);
        translate([14, -5, -1]) cylinder(d=2.2, h=16);
        translate([14,  5, -1]) cylinder(d=2.2, h=16);
    }
}

// ==============================================================================
// Module: Front Sensor Blade Cantilever Arm (Height Adjustable)
// ==============================================================================
module sensor_blade_cantilever() {
    difference() {
        // Cantilever structural body
        union() {
            // Main tongue extending from caster forward to sensor bar
            translate([WHEELBASE + 10, -20, 0])
                cube([SENSOR_OVERHANG - 5, 40, 3.5]);

            // Front transverse mounting bar for Board 2
            translate([WHEELBASE + SENSOR_OVERHANG - 2, -BLADE_LEN/2, 0])
                cube([8, BLADE_LEN, 8]);
        }

        // Chassis attachment holes (matches base plate holes at WHEELBASE + 18)
        translate([WHEELBASE + 18, -15, -1]) cylinder(d=3.2, h=10);
        translate([WHEELBASE + 18,  15, -1]) cylinder(d=3.2, h=10);

        // Vertical adjustment slots for Board 2 (allows 2.0mm - 4.0mm optical ground clearance)
        translate([WHEELBASE + SENSOR_OVERHANG + 2, -BLADE_HOLE_SPACING/2, 4])
            rotate([0, 90, 0])
            hull() {
                translate([-2, 0, -5]) cylinder(d=3.2, h=10);
                translate([ 2, 0, -5]) cylinder(d=3.2, h=10);
            }
        translate([WHEELBASE + SENSOR_OVERHANG + 2,  BLADE_HOLE_SPACING/2, 4])
            rotate([0, 90, 0])
            hull() {
                translate([-2, 0, -5]) cylinder(d=3.2, h=10);
                translate([ 2, 0, -5]) cylinder(d=3.2, h=10);
            }

        // Center cutout for ribbon cable clearance
        translate([WHEELBASE + 25, -12, -1])
            cube([SENSOR_OVERHANG - 20, 24, 10]);
    }
}

// ==============================================================================
// Module: 42mm Competition Wheel & Silicone Tire Hub
// ==============================================================================
module wheel_42mm_hub() {
    difference() {
        union() {
            // Outer rim
            cylinder(d=WHEEL_DIAMETER, h=WHEEL_WIDTH, center=true);
        }

        // Tire retention groove
        difference() {
            cylinder(d=WHEEL_DIAMETER + 1, h=WHEEL_WIDTH - 4, center=true);
            cylinder(d=WHEEL_DIAMETER - 3, h=WHEEL_WIDTH - 4, center=true);
        }

        // Lightweighting spoke cutouts (5 spokes)
        for (i = [0:4]) {
            rotate([0, 0, i * 72])
                translate([12, 0, 0])
                cylinder(d=8, h=WHEEL_WIDTH + 2, center=true);
        }

        // 3mm D-Shaft motor coupling bore
        intersection() {
            cylinder(d=N20_SHAFT_DIA + 0.1, h=WHEEL_WIDTH + 2, center=true);
            translate([-1.5, -2, -(WHEEL_WIDTH+2)/2])
                cube([2.5, 4, WHEEL_WIDTH + 2]);
        }
    }
}

// ==============================================================================
// Full Assembly Visualization
// ==============================================================================
module full_robot_assembly() {
    // 1. Chassis Base Plate
    color([0.2, 0.2, 0.2, 0.9])
        chassis_base_plate();

    // 2. Left and Right Motor Brackets
    color([0.8, 0.2, 0.2]) {
        translate([0, -(TRACK_WIDTH/2 - WHEEL_WIDTH - 8), 3])
            n20_motor_bracket(side=-1);
        translate([0, (TRACK_WIDTH/2 - WHEEL_WIDTH - 8), 3])
            mirror([0, 1, 0])
            n20_motor_bracket(side=1);
    }

    // 3. Left and Right 42mm Wheels
    color([0.1, 0.1, 0.1]) {
        translate([0, -TRACK_WIDTH/2, WHEEL_DIAMETER/2 - 3])
            rotate([90, 0, 0])
            wheel_42mm_hub();
        translate([0, TRACK_WIDTH/2, WHEEL_DIAMETER/2 - 3])
            rotate([-90, 0, 0])
            wheel_42mm_hub();
    }

    // 4. Front Sensor Cantilever Arm
    color([0.1, 0.6, 0.8])
        sensor_blade_cantilever();

    // 5. Board 1 Motherboard (80mm x 50mm PCB on 6mm standoffs)
    color([0.1, 0.5, 0.2, 0.8])
        translate([30 - 40, -25, 3 + 6])
            cube([80, 50, 1.6]);

    // 6. Board 2 Front Sensor Blade (65mm x 16mm PCB)
    color([0.1, 0.1, 0.1, 0.9])
        translate([WHEELBASE + SENSOR_OVERHANG - 8, -BLADE_LEN/2, 3])
            cube([16, BLADE_LEN, 1.0]);

    // 7. Front Ball Caster
    color([0.9, 0.9, 0.9])
        translate([WHEELBASE, 0, -CASTER_BALL_DIA/2])
            sphere(d=CASTER_BALL_DIA);
}

// Render full assembly by default
full_robot_assembly();
