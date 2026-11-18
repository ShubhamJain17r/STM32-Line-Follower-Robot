# Mechanical & Chassis Specification

High-Speed Competition Line Following Robot Mechanical Specifications.

---

## 1. Kinematic Dimensions & Parameters
* **Chassis Layout**: Differential rear-wheel drive with low-friction front support.
* **Wheel Diameter ($D$)**: **EXACTLY 42 mm** (Rubber tire on plastic hub).
* **Wheel Circumference**: $\pi \times 42\text{ mm} \approx 131.95\text{ mm}$.
* **Wheelbase ($L$)**: $100\text{ mm} \pm 10\text{ mm}$ (center of rear axle to front caster).
* **Track Width ($W$)**: $110\text{ mm} \pm 5\text{ mm}$ (center of left tire to center of right tire).
* **Sensor Overhang ($D_{\text{sensor}}$)**: $40\text{ mm}$ ahead of front caster for anticipatory steering lead.

---

## 2. Motors & Drive Assemblies
* **Motors**: 2× N20 12V 600 RPM Micro Metal Gearmotors.
* **Gearbox Ratio**: 30:1.
* **Rear Encoders**: Integrated magnetic hall-effect encoder disk (12 CPR per channel, 4x quadrature $\to$ 1440 counts per wheel rotation).
* **Motor Brackets**: 3D printed PETG / PLA brackets (M1.6 mounting screws).
* **Tires**: High-traction soft silicone or Neoprene O-ring tires.

---

## 3. Front Ground Contact
* **Primary**: Low-friction Teflon (PTFE) skid pad or miniature Delrin ball transfer unit (6 mm / 8 mm stainless steel ball).
* **Ground Clearance**:
  * Chassis: $5\text{ mm} - 7\text{ mm}$.
  * Sensor Blade: $3.0\text{ mm} \pm 0.5\text{ mm}$.

---

## 4. 3D Printing Recommendations
* **Material**: PETG or ABS (greater rigidity and heat tolerance near motor mounts).
* **Infill**: 40% - 60% triangular / gyroid infill for high torsional rigidity.
* **Wall Thickness**: At least 3 perimeters ($1.2\text{ mm}$).
