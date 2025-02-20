from dataset import dfg_dataset
import argparse
from collections import Counter

def pdf_name(img):
  return ''.join(img.split('-')[:-1]).split('/')[-1]

def list_pdfs():
  pdfs = [pdf_name(img) for img in dfg_dataset.imgs]
  pdfs = sorted(list(set(pdfs)))

  for item in pdfs:
    print('"' + item + '"')

qualities = {
  "129_168_Franculeasa, The children of the steppe.pdf": 'digital',
  "2013_Frinculeasa_A_Preda_B_Negrea_O_Sof.pdf": 'scan',
  "2014_Frinculeasa_Alin_Preda_Bianca_Nica.pdf": 'digital',
  "2015_Frinculeasa_A_Preda_B_Heyd_V_Pit_G.pdf": 'digital',
  "2017_Frinculeasa_Mirea_Trohani_Local_cu.pdf": 'digital',
  "2017_Frinculeasa_Simalcsik_Preda_Garvan.pdf": 'digital',
  "2018_Frinculeasa_Preda_Simalcsik_Negrea.pdf": 'digital',
  "2019_Frinculeasa_PredaBalanica_Garvan.pdf": 'digital',
  "2019_Frinculeasa_Preda-Balanica_Garvan.pdf": 'digital',
  "2019_Frinculeasa_Preda_Balanica_Simalcs.pdf": 'digital',
  "2020_Frinculeasa_Contributions_regardin.pdf": 'digital',
  "2020_Frinculeasa_Endangered_monuments_i.pdf": 'digital',
  "2021_Frinculeasa_Negrea_Disca_Simalcsik.pdf": 'digital',
  "2021_Frinculeasa_The_Yamnaya_mounds_and Locals Moara Vlasiei.pdf": 'digital',
  "2022_Frinculeasa_et_al_Yamnaya_si_mormi.pdf": 'digital',
  "44981319.pdf": 'hand',
  "55731778.pdf": 'hand',
  "55907071.pdf": 'hand',
  "5ec762c.pdf": 'scan',
  "7017.pdf": 'digital',
  "Arkheologia_Sssr_Pamyatniki_Fatyanovskoy_Kultury_IvanovskoGorkovskaya_Gruppa.pdf": 'scan',
  "Arkheologia_Sssr_Pamyatniki_Fatyanovskoy_Kultury_Ivanovsko-Gorkovskaya_Gruppa": 'scan',
  "Dobes & Limbursky_2013_VlinevesKSK": 'digital',
  "Dobes et al. 2011 Vlineves": 'digital',
  "Dobeš & Limburský_2013_VlinevesKSK": 'digital',
  "Dobes & Limbursky_2013_Vlineves-KSK": 'digital',
  "Dobeš & Limburský_2013_Vlineves-KSK": 'digital',
  "Haak et al. Forthcoming": 'digital',
  "Langova 2009 Vlineves": 'digital',
  "Limbursky 2012 Bell Beaker Vlineves Chapter 1": 'digital',
  "Limbursky 2012 Bell Beaker Vlineves Chapter 3": 'digital',
  "Limbursky 2012 Bell Beaker Vlineves Chapter 4": 'digital',
  "Limbursky 2013 Vlineves": 'digital',
  "Limbursky and Kostova 2014 Vlineves": 'digital',
  "Limbursky et al. 2013": 'digital',
  "Papac et al. 2021 Supplementary Material": 'digital',
  "Plan_site": 'digital',
  "bader_on_balanovskii_mogilnik_iz_istorii_lesnogo_povolzhia_v.pdf": 'scan',
  "drevnosti_stepnogo_prichernomoria_i_kryma_iv.pdf": 'scan'
}


def count_objects(dataset = dfg_dataset):
  labels = {v: k for k, v in dfg_dataset.labels.items()}

  result = { v: 0 for k, v in labels.items() }

  for item in dfg_dataset:
    item_labels = item[1]['labels'].tolist()
    names = [labels[id] for id in item_labels]
    for name in names:
      result[name] += 1

  return result

def count_objects_by_quality():
  all_imgs = dfg_dataset.imgs.copy()

  result = {
    'digital': Counter(),
    'scan': Counter(),
    'hand': Counter()
  }
  datasets = set([])
  for (pdf, quality) in qualities.items():
    pdf_imgs = [img for img in all_imgs if pdf in img]
    datasets.update(pdf_imgs)
    dfg_dataset.imgs = pdf_imgs

    objects = count_objects()
    objects = Counter(objects)
    result[quality] = result[quality] + objects

  print(result)

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('action', nargs=1)
  args = parser.parse_args()

  if args.action[0] == 'pdfs':
    list_pdfs()
  elif args.action[0] == 'count_objects':
    print(count_objects())
  elif args.action[0] == 'count_objects_quality':
    count_objects_by_quality()
