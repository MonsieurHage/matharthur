# blender_generate.py
# Script Blender pour générer les modèles 3D de MathArthur et les exporter en GLB.
# Usage : blender --background --python blender_generate.py
# Nécessite Blender 3.x+

import bpy
import os
import math

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "models")
os.makedirs(OUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in bpy.data.meshes:
        bpy.data.meshes.remove(block)

def export_glb(name):
    path = os.path.join(OUT_DIR, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True)
    print("Exported", path)

def make_castle():
    clear_scene()
    # base
    bpy.ops.mesh.primitive_cube_add(size=2, location=(0,1,0))
    base = bpy.context.active_object
    base.scale = (2, 1.5, 2)
    # tours
    for x,z in [(2,2),(-2,2),(2,-2),(-2,-2)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=3, location=(x,1.5,z))
    # toit
    bpy.ops.mesh.primitive_cone_add(radius=2.8, depth=1.5, location=(0,3.5,0))
    bpy.ops.object.select_all(action='SELECT')
    export_glb("castle")

def make_avatar_magician():
    clear_scene()
    # corps
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=1.5, location=(0,0.75,0))
    # tête
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.4, location=(0,1.9,0))
    # chapeau
    bpy.ops.mesh.primitive_cone_add(radius=0.5, depth=0.8, location=(0,2.5,0))
    bpy.ops.object.select_all(action='SELECT')
    export_glb("avatar_magician")

def make_coin():
    clear_scene()
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=0.1, location=(0,0,0))
    bpy.ops.object.select_all(action='SELECT')
    export_glb("coin")

def make_chest():
    clear_scene()
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0.5,0))
    bpy.ops.object.select_all(action='SELECT')
    export_glb("chest")

if __name__ == "__main__":
    make_castle()
    make_avatar_magician()
    make_coin()
    make_chest()
    print("All models generated.")
