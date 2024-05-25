class CreateBoneList < ActiveRecord::Migration[7.0]
  def change
    bones = "Calcaneus,Capitate Bone,Carpal,Cervical Vertebrae,Clavicle Or Collarbone,Coccyx,Cuboid Bone,Distal Phalanges,Distal Phalanges,Ethmoid Bone,Femur,Fibula,Frontal Bone,Gladiolus,Hamate Bone,Hip Bone,Humerus,Hyoid Bone,Incus,Inferior Nasal Conchae,Intermediate Cuneiform Bone,Intermediate Phalanges,Intermediate Phalanges,Lacrimal Bone,Lateral Cuneiform Bone,Lumbar Vertebrae,Lunate Bone,Malleus,Mandible,Manubrium,Maxilla,Medial Cuneiform Bone,Metacarpal Bones,Metatarsal Bone,Nasal Bone,Navicular Bone,Occipital Bone,Palatine Bone,Parietal Bone,Patella,Pisiform Bone,Proximal Phalanges,Proximal Phalanges,Radius,Ribs,Sacrum,Scaphoid Bone,Scapula Or Shoulder Blade,Sphenoid Bone,Stapes,Talus,Temporal Bone,Thoracic Vertebrae,Tibia,Trapezium,Trapezoid Bone,Triquetral Bone,Ulna,Vomer,Xiphoid Process,Zygomatic Bone"
    bones = bones.split(",").uniq
    bones.each { Bone.create!(name: _1) }
  end
end
