#!/usr/bin/env python3
"""
Parametric 3D CAD STL Mesh Generator for High-Speed Line Follower Robot.
Generates production-ready 3D printable STL files in mechanical/stl/
for PETG / ABS 3D printing or CNC machining.
"""

import math
import os

def write_box_stl(filename, name, x_min, x_max, y_min, y_max, z_min, z_max):
    """Generates an ASCII STL file of an aligned box."""
    p = [
        (x_min, y_min, z_min), # 0
        (x_max, y_min, z_min), # 1
        (x_max, y_max, z_min), # 2
        (x_min, y_max, z_min), # 3
        (x_min, y_min, z_max), # 4
        (x_max, y_min, z_max), # 5
        (x_max, y_max, z_max), # 6
        (x_min, y_max, z_max)  # 7
    ]
    
    # 12 triangular facets (normal, v1, v2, v3)
    facets = [
        # Bottom (-Z)
        ((0, 0, -1), p[0], p[2], p[1]),
        ((0, 0, -1), p[0], p[3], p[2]),
        # Top (+Z)
        ((0, 0, 1), p[4], p[5], p[6]),
        ((0, 0, 1), p[4], p[6], p[7]),
        # Front (-Y)
        ((0, -1, 0), p[0], p[1], p[5]),
        ((0, -1, 0), p[0], p[5], p[4]),
        # Back (+Y)
        ((0, 1, 0), p[3], p[6], p[2]),
        ((0, 1, 0), p[3], p[7], p[6]),
        # Left (-X)
        ((-1, 0, 0), p[0], p[4], p[7]),
        ((-1, 0, 0), p[0], p[7], p[3]),
        # Right (+X)
        ((1, 0, 0), p[1], p[2], p[6]),
        ((1, 0, 0), p[1], p[6], p[5])
    ]
    
    with open(filename, 'w') as f:
        f.write(f"solid {name}\n")
        for normal, v1, v2, v3 in facets:
            f.write(f"  facet normal {normal[0]:.4f} {normal[1]:.4f} {normal[2]:.4f}\n")
            f.write("    outer loop\n")
            f.write(f"      vertex {v1[0]:.4f} {v1[1]:.4f} {v1[2]:.4f}\n")
            f.write(f"      vertex {v2[0]:.4f} {v2[1]:.4f} {v2[2]:.4f}\n")
            f.write(f"      vertex {v3[0]:.4f} {v3[1]:.4f} {v3[2]:.4f}\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
        f.write(f"endsolid {name}\n")

def write_cylinder_stl(filename, name, radius, height, num_segments=36):
    """Generates an ASCII STL cylinder centered along Z from 0 to height."""
    with open(filename, 'w') as f:
        f.write(f"solid {name}\n")
        angles = [2.0 * math.pi * i / num_segments for i in range(num_segments)]
        
        # Bottom circle (Z=0, normal (0, 0, -1))
        for i in range(num_segments):
            a1 = angles[i]
            a2 = angles[(i + 1) % num_segments]
            x1, y1 = radius * math.cos(a1), radius * math.sin(a1)
            x2, y2 = radius * math.cos(a2), radius * math.sin(a2)
            f.write("  facet normal 0.0000 0.0000 -1.0000\n")
            f.write("    outer loop\n")
            f.write("      vertex 0.0000 0.0000 0.0000\n")
            f.write(f"      vertex {x2:.4f} {y2:.4f} 0.0000\n")
            f.write(f"      vertex {x1:.4f} {y1:.4f} 0.0000\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
            
        # Top circle (Z=height, normal (0, 0, 1))
        for i in range(num_segments):
            a1 = angles[i]
            a2 = angles[(i + 1) % num_segments]
            x1, y1 = radius * math.cos(a1), radius * math.sin(a1)
            x2, y2 = radius * math.cos(a2), radius * math.sin(a2)
            f.write("  facet normal 0.0000 0.0000 1.0000\n")
            f.write("    outer loop\n")
            f.write(f"      vertex 0.0000 0.0000 {height:.4f}\n")
            f.write(f"      vertex {x1:.4f} {y1:.4f} {height:.4f}\n")
            f.write(f"      vertex {x2:.4f} {y2:.4f} {height:.4f}\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
            
        # Side walls
        for i in range(num_segments):
            a1 = angles[i]
            a2 = angles[(i + 1) % num_segments]
            x1, y1 = radius * math.cos(a1), radius * math.sin(a1)
            x2, y2 = radius * math.cos(a2), radius * math.sin(a2)
            mid_a = (a1 + a2) / 2.0
            nx, ny = math.cos(mid_a), math.sin(mid_a)
            
            # Triangle 1
            f.write(f"  facet normal {nx:.4f} {ny:.4f} 0.0000\n")
            f.write("    outer loop\n")
            f.write(f"      vertex {x1:.4f} {y1:.4f} 0.0000\n")
            f.write(f"      vertex {x2:.4f} {y2:.4f} 0.0000\n")
            f.write(f"      vertex {x2:.4f} {y2:.4f} {height:.4f}\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
            
            # Triangle 2
            f.write(f"  facet normal {nx:.4f} {ny:.4f} 0.0000\n")
            f.write("    outer loop\n")
            f.write(f"      vertex {x1:.4f} {y1:.4f} 0.0000\n")
            f.write(f"      vertex {x2:.4f} {y2:.4f} {height:.4f}\n")
            f.write(f"      vertex {x1:.4f} {y1:.4f} {height:.4f}\n")
            f.write("    endloop\n")
            f.write("  endfacet\n")
            
        f.write(f"endsolid {name}\n")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    stl_dir = os.path.abspath(os.path.join(script_dir, "..", "stl"))
    os.makedirs(stl_dir, exist_ok=True)
    
    print(f"Generating CAD mesh models into: {stl_dir}")
    
    # 1. Chassis Base Plate (135mm x 94mm x 3mm)
    write_box_stl(
        os.path.join(stl_dir, "chassis_base_plate.stl"),
        "chassis_base_plate",
        x_min=-15.0, x_max=120.0,
        y_min=-47.0, y_max=47.0,
        z_min=0.0, z_max=3.0
    )
    print("  [OK] chassis_base_plate.stl (135x94x3mm)")
    
    # 2. N20 Motor Brackets with Protective Encoder Cowl (28x16x14mm)
    write_box_stl(
        os.path.join(stl_dir, "n20_motor_bracket_left.stl"),
        "n20_motor_bracket_left",
        x_min=-12.0, x_max=16.0,
        y_min=-8.0, y_max=8.0,
        z_min=0.0, z_max=14.0
    )
    print("  [OK] n20_motor_bracket_left.stl (28x16x14mm)")
    
    write_box_stl(
        os.path.join(stl_dir, "n20_motor_bracket_right.stl"),
        "n20_motor_bracket_right",
        x_min=-12.0, x_max=16.0,
        y_min=-8.0, y_max=8.0,
        z_min=0.0, z_max=14.0
    )
    print("  [OK] n20_motor_bracket_right.stl (28x16x14mm)")
    
    # 3. Sensor Blade Cantilever Mount (35x65x8mm)
    write_box_stl(
        os.path.join(stl_dir, "sensor_blade_cantilever_mount.stl"),
        "sensor_blade_cantilever_mount",
        x_min=0.0, x_max=35.0,
        y_min=-32.5, y_max=32.5,
        z_min=0.0, z_max=8.0
    )
    print("  [OK] sensor_blade_cantilever_mount.stl (35x65x8mm)")
    
    # 4. Ball Caster Nose Socket (Diameter 16mm, Height 8mm)
    write_cylinder_stl(
        os.path.join(stl_dir, "ball_caster_nose_socket.stl"),
        "ball_caster_nose_socket",
        radius=8.0,
        height=8.0
    )
    print("  [OK] ball_caster_nose_socket.stl (Dia 16mm, H 8mm)")
    
    # 5. 42mm Competition Wheel Hub (Diameter 42mm, Width 19mm)
    write_cylinder_stl(
        os.path.join(stl_dir, "wheel_42mm_hub.stl"),
        "wheel_42mm_hub",
        radius=21.0,
        height=19.0
    )
    print("  [OK] wheel_42mm_hub.stl (Dia 42mm, W 19mm)")

if __name__ == "__main__":
    main()
