# Mechanical & Chassis Design Package

High-Speed Competition Line Following Robot Mechanical Specifications, CAD Assemblies, and 3D Printable STL Models.

---

## 1. Kinematic Dimensions & Parameters

| Metric | Nominal Value | Engineering Tolerance | Design Impact |
| :--- | :--- | :--- | :--- |
| **Wheel Diameter ($D$)** | **$42.0\text{ mm}$** | $\pm 0.2\text{ mm}$ | Determines linear distance per revolution |
| **Wheel Circumference ($C$)** | **$131.95\text{ mm}$** | $\pm 0.6\text{ mm}$ | $C = \pi \times 42.0\text{ mm}$ |
| **Track Width ($W$)** | **$110.0\text{ mm}$** | $\pm 2.0\text{ mm}$ | Centerline distance between left and right tires |
| **Wheelbase ($L$)** | **$100.0\text{ mm}$** | $\pm 5.0\text{ mm}$ | Rear drive axle to front ball caster pivot |
| **Sensor Overhang ($D_{\text{sensor}}$)** | **$40.0\text{ mm}$** | $\pm 2.0\text{ mm}$ | Front caster pivot to optical sensor centerline |
| **Total Sensor Advance** | **$140.0\text{ mm}$** | $\pm 5.0\text{ mm}$ | Rear axle to optical sensor centerline ($L + D_{\text{sensor}}$) |
| **Chassis Ground Clearance** | **$5.0\text{ mm}$** | $\pm 1.0\text{ mm}$ | Clearance between bottom plate and track |
| **Sensor Optical Clearance** | **$3.0\text{ mm}$** | $\pm 0.5\text{ mm}$ | Optimal optical focal distance for Vishay QRE1113GR |
| **Total Curb Weight** | **$\approx 185\text{ g}$** | With battery & electronics | Lightweight for high cornering $g$-forces |

---

## 2. 3D Assembly & Exploded Layout

The CAD architecture is structured into modular, interchangeable subassemblies in [`mechanical/cad/chassis_assembly.scad`](cad/chassis_assembly.scad):

```
       [Board 2: Front QTR Sensor Blade]
                     │  (M2.5 vertical slotted adjustment)
          [Cantilever Mounting Arm]
                     │
      ┌──────────────┴──────────────┐
      │  [8mm Delrin Ball Caster]   │  (Front nose pivot)
      │                             │
      │   [Board 1: Motherboard]    │  (Mounted on 4x M3 standoffs)
      │      (80mm x 50mm PCB)      │
      │                             │
      │   [3S LiPo Battery Pocket]  │  (Low center-of-gravity recess)
      │   (58mm x 32mm x 1.5mm)     │
      └──────────────┬──────────────┘
                     │
       ┌─────────────┴─────────────┐
 [Left N20 Motor]            [Right N20 Motor]
 [Encoder Cowl]              [Encoder Cowl]
 [42mm Left Wheel]           [42mm Right Wheel]
```

---

## 3. Production 3D Print STL Files (`mechanical/stl/`)

All parts are exported as production-ready, manifold STL files ready for slicing:

1. **[`chassis_base_plate.stl`](stl/chassis_base_plate.stl)**:
   - Rigid $3.0\text{ mm}$ base plate with motor cutouts, battery pocket, motherboard standoff pattern, and caster mount.
2. **[`n20_motor_bracket_left.stl`](stl/n20_motor_bracket_left.stl)** & **[`n20_motor_bracket_right.stl`](stl/n20_motor_bracket_right.stl)**:
   - High-rigidity motor clamping brackets with integrated $360^\circ$ rear encoder protective cowls and M2 mounting holes.
3. **[`sensor_blade_cantilever_mount.stl`](stl/sensor_blade_cantilever_mount.stl)**:
   - Cantilevered nose extension with dual vertical slots allowing optical focal height adjustment ($2.0\text{ mm}$ to $4.0\text{ mm}$).
4. **[`ball_caster_nose_socket.stl`](stl/ball_caster_nose_socket.stl)**:
   - Precision press-fit housing for an $8.0\text{ mm}$ Delrin or stainless steel ball transfer unit.
5. **[`wheel_42mm_hub.stl`](stl/wheel_42mm_hub.stl)**:
   - $42.0\text{ mm}$ diameter, $19.0\text{ mm}$ width lightweight spoked wheel hub with a $3.0\text{ mm}$ D-shaft motor bore and silicone tire retention groove.

---

## 4. 3D Printing & Slicer Recommendations

* **Recommended Filament**: **PETG** or **ABS/ASA** (PLA is susceptible to motor gearbox heat softening above $50^\circ\text{C}$).
* **Layer Height**: $0.20\text{ mm}$ (or $0.16\text{ mm}$ for motor brackets).
* **Perimeters / Wall Loops**: **4 perimeters** (ensures solid wall thickness around heat-set insert holes).
* **Top / Bottom Solid Layers**: 5 layers top, 5 layers bottom.
* **Infill**: **50% to 60% Gyroid** or **Cubic** infill (maximum torsional stiffness with minimum weight).
* **Print Orientation**: Flat on build plate; no support material required for base plate.

---

## 5. Mechanical Fasteners & Hardware Bill of Materials (BOM)

| Item | Specification | Quantity | Location / Purpose |
| :--- | :--- | :---: | :--- |
| **M3 × 6mm Standoffs** | Brass Hex Female-Female | 4 | Motherboard PCB mounting |
| **M3 × 6mm Screws** | Button Head Hex Drive (ISO 7380) | 8 | Securing Motherboard & Standoffs |
| **M3 × 10mm Screws** | Button Head Hex Drive (ISO 7380) | 2 | Cantilever arm to chassis attachment |
| **M3 Locknuts** | Nylon-Insert (DIN 985) | 2 | Cantilever arm clamp |
| **M2.5 × 8mm Screws** | Button Head Hex Drive | 2 | Sensor Blade vertical slot adjustment |
| **M2.5 Washers** | Stainless Steel Flat Washer | 2 | Sensor Blade slotted clamping |
| **M2 × 12mm Screws** | Socket Head Cap (DIN 912) | 8 | N20 motor clamping brackets |
| **M2 Heat-Set Inserts** | Brass Threaded Inserts (OD 3.2mm, L 4mm) | 8 | Melted into base plate motor boss holes |
| **Ball Caster** | 8mm Stainless / Delrin Ball Unit | 1 | Chassis nose ground contact |
| **Tires** | 42mm Silicone O-Rings or Molded Rubber | 2 | Drive wheels traction |
| **Battery Strap** | 150mm × 12mm Hook-and-Loop Velcro | 1 | 3S LiPo battery retention |
