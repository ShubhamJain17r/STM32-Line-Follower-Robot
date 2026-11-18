// ==============================================================================
// High-Speed Competition Line Follower Robot: Parametric Unibody Chassis
// Architecture: Integrated Drop-In Battery Pocket + Top-Mounted Motherboard
// Caster: Commercial Off-The-Shelf (COTS) 2-Hole Ball Caster (e.g. Pololu / CY-15A)
// Sensor Blade: Modular Slotted Cantilever Arm (Height Adjustable 2.0mm - 4.0mm)
// ==============================================================================

$fn = 60; // Curve resolution

// --- Key Dimensions (all in millimeters) ---
WHEEL_DIAMETER          = 42.0;
WHEEL_WIDTH             = 19.0;
TRACK_WIDTH             = 110.0; // Distance between left and right wheel centerlines
WHEELBASE               = 100.0; // Rear axle to COTS front caster pivot
SENSOR_OVERHANG         = 40.0;  // Front caster pivot to optical sensor centerline

CHASSIS_LENGTH          = 138.0;
CHASSIS_WIDTH           = 94.0;
CHASSIS_THICKNESS       = 3.2;   // Structural plate thickness

// Motherboard PCB mounting holes (80mm x 50mm PCB, 72mm x 42mm M3 hole pattern)
PCB_HOLE_SPACING_X      = 72.0;
PCB_HOLE_SPACING_Y      = 42.0;

// N20 Motor Dimensions
N20_LENGTH              = 26.0;
N20_WIDTH               = 12.0;
N20_HEIGHT              = 10.0;
N20_FACE_HOLE_PITCH     = 9.0;   // 2x M1.6 screw holes on front gearbox face

// Battery Drop-In Pocket (3S 450-650mAh LiPo: ~56mm x 31mm x 16mm)
// Positioned directly between wheels over rear axle to minimize Yaw Inertia (Iz)
BATTERY_POCKET_LEN      = 58.0;
BATTERY_POCKET_WIDTH    = 32.0;

// COTS Commercial Ball Caster Mounting (2x M3 holes spaced 24mm apart)
COTS_CASTER_HOLE_PITCH  = 24.0;
COTS_CASTER_CLEARANCE   = 16.0;  // Center cutout for caster ball housing

// Front Sensor Blade (65mm x 16mm PCB, M2.5 mounting holes at 58mm pitch)
BLADE_LEN               = 65.0;
BLADE_WIDTH             = 16.0;
BLADE_HOLE_SPACING      = 58.0;

// ==============================================================================
// Module 1: Main Chassis Base Plate
// ==============================================================================
module chassis_base_plate() {
    difference() {
        // Outer unibody perimeter
        hull() {
            // Rear axle & motor region
            translate([-12, -CHASSIS_WIDTH/2 + 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            translate([-12, CHASSIS_WIDTH/2 - 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            // Mid body
            translate([WHEELBASE - 25, -CHASSIS_WIDTH/2 + 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            translate([WHEELBASE - 25, CHASSIS_WIDTH/2 - 8, 0])
                cylinder(r=8, h=CHASSIS_THICKNESS);
            // Front nose tapered toward caster
            translate([WHEELBASE + 8, -18, 0])
                cylinder(r=6, h=CHASSIS_THICKNESS);
            translate([WHEELBASE + 8,  18, 0])
                cylinder(r=6, h=CHASSIS_THICKNESS);
        }

        // Wheel cutouts for 42mm tires (left and right)
        translate([-WHEEL_DIAMETER/2 - 2, -TRACK_WIDTH/2 - 2, -1])
            cube([WHEEL_DIAMETER + 4, WHEEL_WIDTH + 4, CHASSIS_THICKNESS + 2]);
        translate([-WHEEL_DIAMETER/2 - 2, TRACK_WIDTH/2 - WHEEL_WIDTH - 2, -1])
            cube([WHEEL_DIAMETER + 4, WHEEL_WIDTH + 4, CHASSIS_THICKNESS + 2]);

        // ----------------------------------------------------------------------
        // TOP DROP-IN BATTERY POCKET (Through-Chassis Cavity)
        // Drops in from top, sits flush with bottom of base (13mm above track)
        // ----------------------------------------------------------------------
        translate([8, -BATTERY_POCKET_WIDTH/2, -1])
            cube([BATTERY_POCKET_LEN, BATTERY_POCKET_WIDTH, CHASSIS_THICKNESS + 2]);

        // Velcro strap slots (15mm x 3mm slots on left and right of battery pocket)
        translate([18, -BATTERY_POCKET_WIDTH/2 - 5, -1])
            cube([15, 3.2, CHASSIS_THICKNESS + 2]);
        translate([18,  BATTERY_POCKET_WIDTH/2 + 1.8, -1])
            cube([15, 3.2, CHASSIS_THICKNESS + 2]);
        translate([42, -BATTERY_POCKET_WIDTH/2 - 5, -1])
            cube([15, 3.2, CHASSIS_THICKNESS + 2]);
        translate([42,  BATTERY_POCKET_WIDTH/2 + 1.8, -1])
            cube([15, 3.2, CHASSIS_THICKNESS + 2]);

        // ----------------------------------------------------------------------
        // N20 MOTOR RECESSES & CLAMP SCREW HOLES (M2)
        // ----------------------------------------------------------------------
        for (side = [-1, 1]) {
            y_motor = side * (TRACK_WIDTH/2 - WHEEL_WIDTH/2 - N20_LENGTH/2);
            // 4x M2 clamping holes per motor
            translate([-8, y_motor - 7, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([-8, y_motor + 7, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([10, y_motor - 7, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
            translate([10, y_motor + 7, -1]) cylinder(d=2.4, h=CHASSIS_THICKNESS+2);
        }

        // ----------------------------------------------------------------------
        // MOTHERBOARD PCB STANDOFF HOLES (4x M3)
        // 80mm x 50mm PCB centered over the mid chassis
        // ----------------------------------------------------------------------
        pcb_center_x = 42.0;
        translate([pcb_center_x - PCB_HOLE_SPACING_X/2, -PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([pcb_center_x + PCB_HOLE_SPACING_X/2, -PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([pcb_center_x - PCB_HOLE_SPACING_X/2,  PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([pcb_center_x + PCB_HOLE_SPACING_X/2,  PCB_HOLE_SPACING_Y/2, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);

        // ----------------------------------------------------------------------
        // COTS COMMERCIAL BALL CASTER MOUNTING (2x M3 Holes)
        // Standard online flange mount (e.g. Pololu 1/2" Ball Caster or CY-15A)
        // ----------------------------------------------------------------------
        translate([WHEELBASE, -COTS_CASTER_HOLE_PITCH/2, -1])
            cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([WHEELBASE,  COTS_CASTER_HOLE_PITCH/2, -1])
            cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        // Center aperture for caster housing drop
        translate([WHEELBASE, 0, -1])
            cylinder(d=COTS_CASTER_CLEARANCE, h=CHASSIS_THICKNESS+2);

        // ----------------------------------------------------------------------
        // FRONT SENSOR BLADE EXTENSION MOUNT HOLES (2x M3)
        // ----------------------------------------------------------------------
        translate([WHEELBASE + 14, -12, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
        translate([WHEELBASE + 14,  12, -1]) cylinder(d=3.2, h=CHASSIS_THICKNESS+2);
    }

    // Battery Bottom Retaining Tabs (prevents battery from slipping through bottom)
    // 4 small 3mm lips on corners of pocket
    translate([8, -BATTERY_POCKET_WIDTH/2, 0])
        cube([6, 3, 1.2]);
    translate([8,  BATTERY_POCKET_WIDTH/2 - 3, 0])
        cube([6, 3, 1.2]);
    translate([8 + BATTERY_POCKET_LEN - 6, -BATTERY_POCKET_WIDTH/2, 0])
        cube([6, 3, 1.2]);
    translate([8 + BATTERY_POCKET_LEN - 6,  BATTERY_POCKET_WIDTH/2 - 3, 0])
        cube([6, 3, 1.2]);
}

// ==============================================================================
// Module 2: N20 Clamping Saddle Bracket with Encoder Protective Cowl
// ==============================================================================
module n20_motor_clamp() {
    difference() {
        // Outer saddle body
        translate([-11, -8, 0])
            cube([24, 16, 12]);

        // Motor body cavity
        translate([-9, -N20_WIDTH/2, -1])
            cube([N20_LENGTH, N20_WIDTH, N20_HEIGHT + 1]);

        // Rear Magnetic Encoder Protective Cowl cavity
        translate([-12, -N20_WIDTH/2 - 1, -1])
            cube([5, N20_WIDTH + 2, N20_HEIGHT + 2]);

        // Encoder wire exit slot
        translate([-12, -3, 5])
            cube([6, 6, 8]);

        // 4x M2 Clamping Through-Holes
        translate([-8, -6, -1]) cylinder(d=2.4, h=14);
        translate([-8,  6, -1]) cylinder(d=2.4, h=14);
        translate([10, -6, -1]) cylinder(d=2.4, h=14);
        translate([10,  6, -1]) cylinder(d=2.4, h=14);
    }
}

// ==============================================================================
// Module 3: Front Sensor Blade Mount (Height-Adjustable Cantilever)
// ==============================================================================
module sensor_blade_mount() {
    difference() {
        union() {
            // Longitudinal cantilever tongue
            translate([WHEELBASE + 8, -16, 0])
                cube([SENSOR_OVERHANG - 2, 32, 3.5]);

            // Transverse vertical mounting bar for Sensor Blade PCB
            translate([WHEELBASE + SENSOR_OVERHANG + 2, -BLADE_LEN/2, 0])
                cube([6, BLADE_LEN, 9]);
        }

        // Chassis attachment holes (matches WHEELBASE + 14 on base plate)
        translate([WHEELBASE + 14, -12, -1]) cylinder(d=3.2, h=12);
        translate([WHEELBASE + 14,  12, -1]) cylinder(d=3.2, h=12);

        // Dual vertical adjustment slots for Sensor Blade Board 2 (allows 2mm - 4mm clearance)
        for (y_slot = [-BLADE_HOLE_SPACING/2, BLADE_HOLE_SPACING/2]) {
            translate([WHEELBASE + SENSOR_OVERHANG + 5, y_slot, 4.5])
                rotate([0, 90, 0])
                hull() {
                    translate([-2.0, 0, -5]) cylinder(d=3.2, h=10);
                    translate([ 2.0, 0, -5]) cylinder(d=3.2, h=10);
                }
        }

        // Center cutout for 10-pin ribbon cable
        translate([WHEELBASE + 20, -10, -1])
            cube([16, 20, 10]);
    }
}

// ==============================================================================
// Complete Assembly View
// ==============================================================================
module robot_assembly() {
    // Chassis Base Plate
    color([0.25, 0.25, 0.25, 0.9])
        chassis_base_plate();

    // Motor Clamps
    color([0.8, 0.2, 0.2]) {
        translate([0, -(TRACK_WIDTH/2 - WHEEL_WIDTH/2 - N20_LENGTH/2), CHASSIS_THICKNESS])
            n20_motor_clamp();
        translate([0, (TRACK_WIDTH/2 - WHEEL_WIDTH/2 - N20_LENGTH/2), CHASSIS_THICKNESS])
            mirror([0, 1, 0])
            n20_motor_clamp();
    }

    // Front Sensor Blade Mount
    color([0.1, 0.6, 0.85])
        sensor_blade_mount();

    // 3S LiPo Battery (Dropped into pocket, low CG over axle)
    color([0.2, 0.2, 0.8, 0.8])
        translate([8 + 1, -BATTERY_POCKET_WIDTH/2 + 1, 1.2])
            cube([BATTERY_POCKET_LEN - 2, BATTERY_POCKET_WIDTH - 2, 16.0]);

    // Motherboard PCB (80mm x 50mm mounted on 6mm standoffs)
    color([0.1, 0.5, 0.2, 0.8])
        translate([42 - 40, -25, CHASSIS_THICKNESS + 6.0])
            cube([80, 50, 1.6]);

    // Front Sensor Blade Board 2 (65mm x 16mm PCB)
    color([0.1, 0.1, 0.1, 0.95])
        translate([WHEELBASE + SENSOR_OVERHANG + 2 - 1.0, -BLADE_LEN/2, 2.5])
            cube([1.0, BLADE_LEN, 16.0]);
}

robot_assembly();
