# Mechanical & Chassis Design Package

High-Speed Competition Line Following Robot Mechanical Specifications, CAD Assemblies, and 3D Printable STL Models.

---

## 1. Kinematic Dimensions & Parameters

| Metric | Nominal Value | Engineering Tolerance | Design Impact |
| :--- | :--- | :--- | :--- |
| **Wheel Diameter ($D$)** | **$42.0\text{ mm}$** | $\pm 0.2\text{ mm}$ | High-traction rubber / silicone tires on N20 D-shafts |
| **Wheel Circumference ($C$)** | **$131.95\text{ mm}$** | $\pm 0.6\text{ mm}$ | $C = \pi \times 42.0\text{ mm}$ |
| **Track Width ($W$)** | **$110.0\text{ mm}$** | $\pm 2.0\text{ mm}$ | Centerline distance between left and right tires |
| **Wheelbase ($L$)** | **$100.0\text{ mm}$** | $\pm 5.0\text{ mm}$ | Rear drive axle to front COTS ball caster pivot |
| **Sensor Overhang ($D_{\text{sensor}}$)** | **$40.0\text{ mm}$** | $\pm 2.0\text{ mm}$ | Front caster pivot to optical sensor centerline |
| **Total Sensor Advance** | **$140.0\text{ mm}$** | $\pm 5.0\text{ mm}$ | Rear axle to optical sensor centerline ($L + D_{\text{sensor}}$) |
| **Chassis Ground Clearance** | **$13.0\text{ mm}$** | Bottom of chassis plate to track | Ample clearance over track joints & ramp transitions |
| **Sensor Optical Clearance** | **$3.0\text{ mm}$** | $\pm 0.5\text{ mm}$ | Optimal optical focal distance for Vishay QRE1113GR |
| **Total Curb Weight** | **$\approx 175\text{ g}$** | With 3S LiPo & electronics | Ultra-low yaw moment of inertia ($I_z$) |

---

## 2. Unibody Mechanical Architecture

The chassis is engineered specifically for autonomous line tracking at high cornering velocities ($> 1.3\text{ m/s}$):

```
       [Board 2: Front QTR Sensor Blade]
                     │  (M2.5 vertical slotted adjustment, 2.0mm - 4.0mm)
        [Slotted Cantilever Mount]
                     │
      ┌──────────────┴──────────────┐
      │  [COTS Online Ball Caster]  │  (2x M3 mounting holes @ 24mm pitch)
      │                             │
      │   [Board 1: Motherboard]    │  (Mounted on 4x M3 6mm standoffs)
      │      (80mm x 50mm PCB)      │
      │                             │
      │   [Drop-In Battery Pocket]  │  (Through-pocket over rear axle;
      │   (58mm x 32mm cavity)      │   bottom tabs retain pack 13mm off track)
      └──────────────┬──────────────┘
                     │
       ┌─────────────┴─────────────┐
 [Left N20 Motor]            [Right N20 Motor]
 [Clamping Saddle]           [Clamping Saddle]
 [Encoder Cowl]              [Encoder Cowl]
 [42mm COTS Wheel]           [42mm COTS Wheel]
```

### Why this configuration dominates:
1. **Zero-Inertia Battery Placement**:
   - The 3S LiPo pack drops in from the **top** directly between the drive wheels and rests on bottom perimeter tabs flush with the base plate ($13.0\text{ mm}$ above the floor).
   - This keeps the vertical Center of Gravity low while placing the heavy battery mass ($~55\text{ g}$) directly over the rear drive axle, minimizing **Yaw Moment of Inertia ($I_z = \sum m r^2$)** for razor-sharp steering agility.
2. **5-Second Pit Battery Swaps**:
   - Battery is accessible instantly from the top via a quick-release velcro strap. No flipping the robot or removing screws during heats.
3. **COTS Commercial Ball Caster Mounting**:
   - Includes standard $2\times\text{M3}$ mounting holes at $24.0\text{ mm}$ pitch with a $16.0\text{ mm}$ central clearance cutout.
   - Compatible with standard off-the-shelf ball transfer units (Pololu 1/2" Ball Caster, CY-15A, or CY-8H).
4. **Sacrificial Height-Adjustable Sensor Mount**:
   - Isolates the front sensor blade from chassis impact shocks.
   - Vertical slots allow continuous optical height calibration between $2.0\text{ mm}$ and $4.0\text{ mm}$.

---

## 3. Chassis Structural Parts & Geometry Specifications

1. **Unibody Chassis Base Plate**:
   - Rigid $3.2\text{ mm}$ plate with drop-in battery through-pocket ($58.0\text{ mm} \times 32.0\text{ mm}$) centered over the rear drive axle.
   - Dual N20 motor clamping channels with M2 heat-set insert bosses ($OD = 3.2\text{ mm}$, depth $= 4.0\text{ mm}$).
   - Motherboard standoff mounting pattern: 4× M3 holes on $72.0\text{ mm} \times 42.0\text{ mm}$ grid.
   - Front COTS ball caster mount: 2× M3 holes @ $24.0\text{ mm}$ pitch with $16.0\text{ mm}$ center clearance cutout.
   - Dual $13.0\text{ mm} \times 2.5\text{ mm}$ lateral slots for hook-and-loop battery retention velcro strap.

2. **N20 Motor Clamping Saddles (Left & Right Pairs)**:
   - Precision $12.0\text{ mm} \times 10.0\text{ mm}$ cross-section contoured to clamp N20 micro gearmotors rigidly against vibration.
   - Integrated $360^\circ$ rear magnetic encoder cowl ($12.5\text{ mm}$ diameter $\times 6.0\text{ mm}$ depth) protecting delicate hall sensors from track debris and mechanical impact.
   - Fastened via 4× M2 × 12mm socket head cap screws per motor.

3. **Front Cantilever Sensor Blade Mount**:
   - Extended nose cantilever positioning optical sensors $40.0\text{ mm}$ ahead of front ball caster ($140.0\text{ mm}$ total sensor advance from rear drive axle).
   - Dual vertical slots for M2.5 screws spaced $58.0\text{ mm}$ center-to-center, providing continuous height calibration between $2.0\text{ mm}$ and $4.0\text{ mm}$ ground clearance.

---

## 4. 3D Printing & Slicer Guidelines

* **Filament**: **PETG** or **ABS/ASA** (resists motor heat up to $70^\circ\text{C}$).
* **Layer Height**: $0.20\text{ mm}$.
* **Perimeters**: **4 wall loops** (solid material around threaded insert holes).
* **Infill**: **50% Gyroid** or **Cubic** infill.
* **Print Orientation**: Flat on build plate; zero support material required.

---

## 5. Commercial Hardware & Fasteners BOM

| Item | Specification | Quantity | Location / Purpose |
| :--- | :--- | :---: | :--- |
| **Front Caster Wheel** | COTS 1/2" / 15mm Ball Transfer Unit (e.g. Pololu / CY-15A) | 1 | Chassis nose ground contact (online purchase) |
| **42mm Wheels** | 42mm × 19mm Rubber / Silicone N20 D-Shaft Wheels | 2 | Drive wheel traction (online purchase) |
| **M3 × 6mm Standoffs** | Brass Hex Female-Female | 4 | Motherboard PCB mounting |
| **M3 × 6mm Screws** | Button Head Hex Drive (ISO 7380) | 8 | Securing Motherboard & Standoffs |
| **M3 × 8mm Screws** | Button Head Hex Drive | 2 | COTS Ball Caster mounting |
| **M3 × 10mm Screws** | Button Head Hex Drive | 2 | Cantilever mount to chassis |
| **M2.5 × 8mm Screws** | Button Head Hex Drive | 2 | Sensor Blade vertical slot adjustment |
| **M2 × 12mm Screws** | Socket Head Cap (DIN 912) | 8 | N20 motor clamping saddles |
| **M2 Heat-Set Inserts** | Brass Threaded Inserts (OD 3.2mm, L 4mm) | 8 | Melted into base plate motor boss holes |
| **Battery Strap** | 150mm × 12mm Hook-and-Loop Velcro | 1 | 3S LiPo battery retention |
