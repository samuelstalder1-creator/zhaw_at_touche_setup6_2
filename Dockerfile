FROM webis/touche25-ad-detection:0.0.1

ADD predict.py /predict.py
ADD requirements.txt /requirements.txt

RUN pip3 install --no-cache-dir -r /requirements.txt

ARG MODEL_NAME=sambus211/zhaw_at_touche_setup6_2
ARG BASE_MODEL_NAME=FacebookAI/roberta-base

RUN python3 - <<PY
from transformers import AutoConfig, AutoModel, AutoTokenizer
model_name = "${MODEL_NAME}"
base_model_name = "${BASE_MODEL_NAME}"
AutoTokenizer.from_pretrained(model_name)
AutoConfig.from_pretrained(model_name)
AutoTokenizer.from_pretrained(base_model_name)
AutoModel.from_pretrained(base_model_name)
PY

ENTRYPOINT ["python3", "/predict.py"]
