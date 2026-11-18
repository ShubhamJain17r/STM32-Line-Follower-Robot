# Board 2: Front QTR Sensor Blade Specification (KiCad 8)

The Front Sensor Blade is a sacrificial, decoupled optical sensor array positioned ahead of the robot's front ball caster.

---

## 1. Physical & Mechanical Specs
* **Sensors**: 8× Vishay `QRE1113GR` miniature SMD optical reflectance phototransistors.
* **Pitch**: **7.5 mm** uniform pitch between optical centers.
  * Span: $(8 - 1) \times 7.5\text{ mm} = \mathbf{52.5\text{ mm}}$.
  * White line width typically: $15\text{ mm}$ to $19\text{ mm}$ (covers 2-3 sensors simultaneously for fine interpolation).
* **Operating Height (Ground Clearance)**: **3.0 mm $\pm$ 0.5 mm** from the track surface.
* **Optical Isolation**: Solder-mask black border or milled slots between sensors to eliminate lateral optical cross-talk.

---

## 2. Active Ambient Light Rejection Circuit (AutoDifferential)

```
       3.3V Logic Rail
          │
          ├───[ 100 Ω ]───(>| IR Emitter 1 )───┐
          ├───[ 100 Ω ]───(>| IR Emitter 2 )───┤
          │        ...                          │
          └───[ 100 Ω ]───(>| IR Emitter 8 )───┤
                                                │
                                            Drain (D)
   EMITTER_PB14 (from Mainboard) ──[ 1 kΩ ]──┤ 2N7002 N-MOSFET
                                 ──[ 100 kΩ ]┤ Source (S)
                                   (pull-down)  │
                                               GND
```

### Phototransistor Collector Pull-Up Network:
* Each sensor's phototransistor collector connects to `3.3V` through a $10\text{ k}\Omega$ (1%) SMD pull-up resistor.
* Each sensor's emitter connects to `GND`.
* The midpoint (Collector node) connects to the respective analog output line `S1` through `S8`.
* Dark line (absorbs IR) $\to$ phototransistor OFF $\to$ Output pulled HIGH towards 3.3V ($\approx 4095$ counts).
* White floor (reflects IR) $\to$ phototransistor ON $\to$ Output pulled LOW towards GND ($\approx 200\text{--}500$ counts).

---

## 3. PCB Layout Considerations
* **Board Dimensions**: Suggest $65\text{ mm} \times 15\text{ mm}$, double-sided FR4, $1.0\text{ mm}$ or $1.2\text{ mm}$ thickness (thinner reduces front overhang weight).
* **Mounting Holes**: 2× M2.5 / M3 mounting slots near the outer edges for slotted vertical height adjustment.
* **Connector Placement**: 10-pin / 11-pin horizontal JST-PH or JST-XH connector positioned centrally on the top edge facing rearward toward the mainboard.
