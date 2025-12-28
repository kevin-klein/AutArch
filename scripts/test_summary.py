import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

tokenizer = AutoTokenizer.from_pretrained(
    "google/pegasus-xsum"
)
model = AutoModelForSeq2SeqLM.from_pretrained(
    "google/pegasus-xsum",
    dtype=torch.bfloat16,
    device_map="auto",
)

input_text = """1p)\n\nBaltic-Pontic Studies\n\nvol. 22: 2017, 246-283\n\nISSN 1231-0344\n\nDOT 10.1515/bps-2017-0028\n\nPiotr Wiodarczak*\n\nKURGAN RITES IN THE ENEOLITHIC AND\n\nEARLY BRONZE AGE PODOLIA IN LIGHT\n\nOF MATERIALS FROM THE FUNERARY-\n\nCEREMONIAL CENTRE AT YAMPIL\n\nABSTRACT\n\nThe paper discusses the kurgan burial rites observed by communities\n\ninhabiting the eastern part of the Podolie Region in the second half\n\nof the 4th and first half of the 3rd millennia BC. The presented data\n\nconcern finds from four areas: Yampil, Kamienka, Mocra, and Tym-\n\nkove. The research made it possible to distinguish among the exam-\n\nined material assemblages linked with Late Eneolithic communities.\n\nThey included graves of the Zhivolitovka-Volchansk type, burials in\n\nthe extended position, as well as burials representing other cultural\n\ntraditions (Nizhnaya Mikhailovka, Post-Stog). Materials attributed to\n\nthe Yamnaya culture prevailed, and their analysis allowed us to trace\n\nchanges in funeral rituals, reflected in the architecture of graves, ar-\n\nrangement of burials, and grave goods. Materials linked with the late\n\nphase of this cultural unit have not been recorded.\n\nKey words: Eneolithic, Early Bronze Age, Yamnaya culture, Podolia,\n\nUkraine, funeral rite\n\nThe results of field research carried out by a Polish-Ukrainian expedition inves-\n\ntigating kurgans in the middle Dniester basin have already been published [Kosko\n\n(Ed.) 2014; 2015; 2017], and many specialist analyses connected with this research\n\nhave already been concluded as well [apart from the publications quoted above,\n\nInstitute of Archaeology and Ethnology of Polish Academy of Sciences, Centre for Mountains and\n\nUplands Archaeology, Stawkowska 17, 31-016 Krakéw, Poland; wlodarczak.piotr@ gmail.com\n\n© year of first publication Author(s). This is an open access article distributed under the Creative Commons Attribution-\n\nNonCommercial-NoDerivs license (http://creativecommons.org/licenses/by-nc-nd/3.0/)"""
input_ids = tokenizer(input_text, return_tensors="pt").to(model.device)

output = model.generate(**input_ids, cache_implementation="static")
print(tokenizer.decode(output[0], skip_special_tokens=True))
