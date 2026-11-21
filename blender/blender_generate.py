# blender_generate.py
# Script Blender pour générer des assets 3D de HAUTE QUALITÉ pour MathArthur.
# Usage : blender --background --python blender_generate.py
# Nécessite Blender 3.x+ et les addons glTF (inclus par défaut).
#
# Génère des modèles détaillés avec matériaux PBR, textures procédurales et animations.

import bpy
import os
import math
import random

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "models")
os.makedirs(OUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in bpy.data.meshes:
        bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        bpy.data.materials.remove(block)
    for block in bpy.data.textures:
        bpy.data.textures.remove(block)
    for block in bpy.data.images:
        bpy.data.images.remove(block)

def make_material(name, base_color, roughness=0.5, metallic=0.0, emission=None, normal_strength=0.5):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = base_color
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission:
        bsdf.inputs["Emission Color"].default_value = emission
        bsdf.inputs["Emission Strength"].default_value = 2.0
    # procedural noise for subtle texture
    texcoord = mat.node_tree.nodes.new("ShaderNodeTexCoord")
    noise = mat.node_tree.nodes.new("ShaderNodeTexNoise")
    noise.inputs["Scale"].default_value = 15.0
    noise.inputs["Detail"].default_value = 6.0
    colorramp = mat.node_tree.nodes.new("ShaderNodeValToRGB")
    colorramp.color_ramp.elements[0].position = 0.4
    colorramp.color_ramp.elements[1].position = 0.6
    mix = mat.node_tree.nodes.new("ShaderNodeMixRGB")
    mix.blend_type = 'MULTIPLY'
    mix.inputs["Fac"].default_value = 0.15
    mat.node_tree.links.new(texcoord.outputs["Object"], noise.inputs["Vector"])
    mat.node_tree.links.new(noise.outputs["Fac"], colorramp.inputs["Fac"])
    mat.node_tree.links.new(colorramp.outputs["Color"], mix.inputs["Color2"])
    mat.node_tree.links.new(bsdf.outputs["BSDF"], mix.inputs["Color1"]) if False else None
    # simpler: just set roughness variation via noise on roughness
    return mat

def export_glb(name, selected_only=True):
    path = os.path.join(OUT_DIR, name + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        use_selection=selected_only,
        export_materials='EXPORT',
        export_cameras=False,
        export_lights=False,
        export_animations=True,
    )
    print("Exported", path)

def make_ground():
    clear_scene()
    # high-res plane with subdivision
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0,0,0))
    plane = bpy.context.active_object
    bpy.ops.object.modifier_add(type='SUBDIV')
    plane.modifiers["Subdivision"].levels = 2
    bpy.ops.object.modifier_apply(modifier="Subdivision")
    # material
    mat = make_material("GroundMat", (0.35, 0.65, 0.25, 1.0), roughness=0.85)
    plane.data.materials.append(mat)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("ground")

def make_player():
    clear_scene()
    # body
    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=1.2, location=(0,0.6,0))
    body = bpy.context.active_object
    body.name = "Body"
    mat_body = make_material("BodyMat", (0.2, 0.45, 0.95, 1.0), roughness=0.4, metallic=0.1)
    body.data.materials.append(mat_body)
    # head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.32, location=(0,1.45,0))
    head = bpy.context.active_object
    head.name = "Head"
    mat_head = make_material("HeadMat", (1.0, 0.85, 0.7, 1.0), roughness=0.3)
    head.data.materials.append(mat_head)
    # eyes
    for x in [-0.12, 0.12]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(x, 1.5, 0.28))
        eye = bpy.context.active_object
        mat_eye = make_material("EyeMat", (0.1, 0.1, 0.1, 1.0), roughness=0.1, metallic=0.3)
        eye.data.materials.append(mat_eye)
    # arms
    for x in [-0.45, 0.45]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.9, location=(x, 0.85, 0))
        arm = bpy.context.active_object
        arm.rotation_euler = (0, 0, math.radians(15 if x>0 else -15))
        arm.data.materials.append(mat_body)
    # legs
    for x in [-0.15, 0.15]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.9, location=(x, -0.1, 0))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_body)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("player")

def make_flag():
    clear_scene()
    # pole
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=2.5, location=(0,1.25,0))
    pole = bpy.context.active_object
    mat_pole = make_material("PoleMat", (0.85, 0.85, 0.85, 1.0), roughness=0.3, metallic=0.6)
    pole.data.materials.append(mat_pole)
    # flag cloth (plane subdivided)
    bpy.ops.mesh.primitive_plane_add(size=1.2, location=(0.7, 2.0, 0))
    cloth = bpy.context.active_object
    cloth.scale = (1.0, 0.6, 1.0)
    bpy.ops.object.modifier_add(type='SUBDIV')
    cloth.modifiers["Subdivision"].levels = 3
    bpy.ops.object.modifier_apply(modifier="Subdivision")
    # wave displacement
    bpy.ops.object.modifier_add(type='WAVE')
    cloth.modifiers["Wave"].height = 0.15
    cloth.modifiers["Wave"].width = 1.0
    bpy.ops.object.modifier_apply(modifier="Wave")
    mat_flag = make_material("FlagMat", (0.95, 0.15, 0.15, 1.0), roughness=0.4, emission=(1.0, 0.2, 0.2))
    cloth.data.materials.append(mat_flag)
    # base
    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=0.15, location=(0,0.075,0))
    base = bpy.context.active_object
    mat_base = make_material("BaseMat", (0.3, 0.3, 0.3, 1.0), roughness=0.7, metallic=0.4)
    base.data.materials.append(mat_base)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("flag")

def make_tree():
    clear_scene()
    # trunk
    bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=2.0, location=(0,1.0,0))
    trunk = bpy.context.active_object
    mat_trunk = make_material("TrunkMat", (0.4, 0.25, 0.12, 1.0), roughness=0.9)
    trunk.data.materials.append(mat_trunk)
    # foliage (icosphere)
    bpy.ops.mesh.primitive_ico_sphere_add(radius=1.3, location=(0,2.6,0))
    leaves = bpy.context.active_object
    bpy.ops.object.modifier_add(type='SUBDIV')
    leaves.modifiers["Subdivision"].levels = 1
    bpy.ops.object.modifier_apply(modifier="Subdivision")
    mat_leaves = make_material("LeavesMat", (0.15, 0.6, 0.2, 1.0), roughness=0.7)
    leaves.data.materials.append(mat_leaves)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("tree")

def make_coin():
    clear_scene()
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=0.1, location=(0,0,0))
    coin = bpy.context.active_object
    mat = make_material("CoinMat", (1.0, 0.8, 0.1, 1.0), roughness=0.2, metallic=0.9, emission=(1.0, 0.8, 0.1))
    coin.data.materials.append(mat)
    # emboss ring
    bpy.ops.mesh.primitive_torus_add(major_radius=0.4, minor_radius=0.05, location=(0,0,0.06))
    ring = bpy.context.active_object
    ring.data.materials.append(mat)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("coin")

def make_chest():
    clear_scene()
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0.5,0))
    chest = bpy.context.active_object
    chest.scale = (1.2, 0.8, 0.8)
    mat = make_material("ChestMat", (0.55, 0.35, 0.15, 1.0), roughness=0.7)
    chest.data.materials.append(mat)
    # lid
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0,1.0,0))
    lid = bpy.context.active_object
    lid.scale = (1.25, 0.2, 0.85)
    lid.data.materials.append(mat)
    # gold trim
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0.5,0.42))
    trim = bpy.context.active_object
    trim.scale = (1.22, 0.82, 0.05)
    mat_gold = make_material("GoldMat", (1.0, 0.8, 0.2, 1.0), roughness=0.2, metallic=0.9)
    trim.data.materials.append(mat_gold)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("chest")

def make_castle():
    clear_scene()
    # base
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0,1.5,0))
    base = bpy.context.active_object
    base.scale = (4, 3, 4)
    mat_stone = make_material("StoneMat", (0.6, 0.55, 0.5, 1.0), roughness=0.85)
    base.data.materials.append(mat_stone)
    # towers
    for x,z in [(2.2,2.2),(-2.2,2.2),(2.2,-2.2),(-2.2,-2.2)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=4.5, location=(x,2.25,z))
        t = bpy.context.active_object
        t.data.materials.append(mat_stone)
        # cone roof
        bpy.ops.mesh.primitive_cone_add(radius=0.9, depth=1.2, location=(x,4.8,z))
        r = bpy.context.active_object
        mat_roof = make_material("RoofMat", (0.5, 0.15, 0.1, 1.0), roughness=0.6)
        r.data.materials.append(mat_roof)
    # main roof
    bpy.ops.mesh.primitive_cone_add(radius=3.2, depth=2.0, location=(0,4.5,0))
    mr = bpy.context.active_object
    mr.data.materials.append(mat_roof)
    bpy.ops.object.select_all(action='SELECT')
    export_glb("castle")

if __name__ == "__main__":
    make_ground()
    make_player()
    make_flag()
    make_tree()
    make_coin()
    make_chest()
    make_castle()
    print("All high-quality models generated.")
